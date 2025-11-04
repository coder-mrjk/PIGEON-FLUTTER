import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AssetUtils {
  static Map<String, dynamic>? _manifest;

  static Future<void> _ensureManifest() async {
    if (_manifest != null) return;
    try {
      final raw = await rootBundle.loadString('AssetManifest.json');
      final data = json.decode(raw);
      if (data is Map<String, dynamic>) {
        _manifest = data;
      } else {
        _manifest = <String, dynamic>{};
      }
    } catch (_) {
      _manifest = <String, dynamic>{};
    }
  }

  static Future<bool> exists(String key) async {
    await _ensureManifest();
    return _manifest!.containsKey(key);
  }

  static Future<String?> firstExisting(List<String> keys) async {
    await _ensureManifest();
    for (final k in keys) {
      if (_manifest!.containsKey(k)) return k;
    }
    return null;
  }
}
