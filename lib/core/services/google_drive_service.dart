import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class GoogleDriveService {
  GoogleDriveService._();
  static final GoogleDriveService instance = GoogleDriveService._();

  static const String _folderName = 'Pigeon Backups';

  Future<String?> _getAccessToken() async {
    try {
      // Request Drive scope using Firebase Auth's Google provider (web-friendly)
      final provider = GoogleAuthProvider()
        ..addScope('https://www.googleapis.com/auth/drive.file');
      UserCredential cred;
      try {
        cred = await FirebaseAuth.instance.signInWithPopup(provider);
      } on UnsupportedError {
        cred = await FirebaseAuth.instance.signInWithProvider(provider);
      }
      final oauth = cred.credential as OAuthCredential?;
      return oauth?.accessToken;
    } catch (_) {
      return null;
    }
  }

  Future<String?> ensureAppFolder() async {
    final token = await _getAccessToken();
    if (token == null) return null;

    const query =
        "name='$_folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";
    final listUri = Uri.https('www.googleapis.com', '/drive/v3/files', {
      'q': query,
      'spaces': 'drive',
      'fields': 'files(id,name)',
      'pageSize': '1',
    });

    final listRes = await http.get(listUri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (listRes.statusCode == 200) {
      final data = jsonDecode(listRes.body) as Map<String, dynamic>;
      final files = (data['files'] as List?) ?? const [];
      if (files.isNotEmpty) {
        return (files.first as Map)['id'] as String?;
      }
    }

    // Create folder
    final createRes = await http.post(
      Uri.https('www.googleapis.com', '/drive/v3/files'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': _folderName,
        'mimeType': 'application/vnd.google-apps.folder',
      }),
    );

    if (createRes.statusCode == 200) {
      final data = jsonDecode(createRes.body) as Map<String, dynamic>;
      return data['id'] as String?;
    }
    return null;
  }

  Future<bool> uploadTextFile({
    required String fileName,
    required String content,
    String? folderId,
  }) async {
    final token = await _getAccessToken();
    if (token == null) return false;

    final uri = Uri.parse(
        'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    final metadata = {
      'name': fileName,
      if (folderId != null) 'parents': [folderId],
    };

    request.fields['metadata'] = jsonEncode(metadata);

    // Build multipart body manually to control parts order
    final boundary = 'pigeon_${DateTime.now().millisecondsSinceEpoch}';
    final meta = utf8.encode(jsonEncode(metadata));
    final mediaBytes = Uint8List.fromList(utf8.encode(content));
    const mediaType = 'application/json; charset=utf-8';

    final body = BytesBuilder();
    void write(String s) => body.add(utf8.encode(s));

    write('--$boundary\r\n');
    write('Content-Type: application/json; charset=UTF-8\r\n\r\n');
    body.add(meta);
    write('\r\n');

    write('--$boundary\r\n');
    write('Content-Type: $mediaType\r\n\r\n');
    body.add(mediaBytes);
    write('\r\n');

    write('--$boundary--\r\n');

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/related; boundary=$boundary',
      },
      body: body.takeBytes(),
    );

    return res.statusCode == 200;
  }
}
