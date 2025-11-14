import 'dart:async';

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/google_drive_service.dart';

class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final String type;
  final bool isEdited;
  final DateTime? editedAt;
  final List<String> reactions;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    this.type = 'text',
    this.isEdited = false,
    this.editedAt,
    this.reactions = const [],
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      content: data['text'] as String? ?? '',
      senderId: data['uid'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'Unknown',
      timestamp: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      type: data['type'] as String? ?? 'text',
      isEdited: data['isEdited'] as bool? ?? false,
      editedAt: data['editedAt'] != null
          ? (data['editedAt'] as Timestamp).toDate()
          : null,
      reactions: List<String>.from(data['reactions'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': content,
      'uid': senderId,
      'senderName': senderName,
      'createdAt': Timestamp.fromDate(timestamp),
      'type': type,
      'isEdited': isEdited,
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
      'reactions': reactions,
    };
  }
}

class Chat {
  final String id;
  final String name;
  final List<String> members;
  final bool isGroupChat;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSender;
  final Map<String, dynamic> metadata;

  const Chat({
    required this.id,
    required this.name,
    required this.members,
    required this.isGroupChat,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSender,
    this.metadata = const {},
  });

  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown Chat',
      members: List<String>.from(data['members'] as List<dynamic>? ?? []),
      isGroupChat: data['isGroupChat'] as bool? ?? false,
      lastMessage: data['lastMessage'] as String?,
      lastMessageTime: data['lastMessageTime'] != null
          ? (data['lastMessageTime'] as Timestamp).toDate()
          : null,
      lastMessageSender: data['lastMessageSender'] as String?,
      metadata: Map<String, dynamic>.from(
          data['metadata'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class ChatState {
  final List<Chat> chats;
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String? selectedChatId;

  const ChatState({
    this.chats = const [],
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.selectedChatId,
  });

  ChatState copyWith({
    List<Chat>? chats,
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? selectedChatId,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedChatId: selectedChatId ?? this.selectedChatId,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _messagesSub;

  @override
  ChatState build() {
    // Ensure listeners are cleaned up when provider is disposed
    ref.onDispose(() {
      _chatsSub?.cancel();
      _messagesSub?.cancel();
    });

    // Schedule initialization after the first frame to avoid circular dependency
    Future.microtask(() => _init());
    return const ChatState();
  }

  void _init() {
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = _auth.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // Query without orderBy to avoid requiring a composite index
      // We'll sort the results in memory instead
      final chatsQuery = _firestore
          .collection('chats')
          .where('members', arrayContains: user.uid);

      // Cancel and wait for previous subscription to fully close
      await _chatsSub?.cancel();
      _chatsSub = chatsQuery.snapshots().listen(
        (snapshot) {
          final chats =
              snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList();

          // Sort in memory by lastMessageTime
          chats.sort((a, b) {
            if (a.lastMessageTime == null && b.lastMessageTime == null) {
              return 0;
            }
            if (a.lastMessageTime == null) return 1;
            if (b.lastMessageTime == null) return -1;
            return b.lastMessageTime!.compareTo(a.lastMessageTime!);
          });

          state = state.copyWith(chats: chats, isLoading: false);
        },
        onError: (Object error) {
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to load chats: ${error.toString()}',
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load chats: ${e.toString()}',
      );
    }
  }

  Future<void> loadMessages(String chatId) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        selectedChatId: chatId,
      );

      final messagesQuery = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(50);

      _messagesSub?.cancel();
      _messagesSub = messagesQuery.snapshots().listen((snapshot) {
        final messages = snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList()
            .reversed
            .toList();
        state = state.copyWith(messages: messages, isLoading: false);
      }, onError: (Object error) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load messages: ${error.toString()}',
        );
      });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load messages: ${e.toString()}',
      );
    }
  }

  Future<void> sendMessage(String chatId, String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final message = ChatMessage(
        id: '', // Will be set by Firestore
        content: content,
        senderId: user.uid,
        senderName: user.displayName ?? 'Unknown',
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toFirestore());

      // Update chat's last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'lastMessageTime': Timestamp.now(),
        'lastMessageSender': user.displayName ?? 'Unknown',
      });
    } catch (e) {
      state = state.copyWith(error: 'Failed to send message: ${e.toString()}');
    }
  }

  Future<void> editMessage(
    String chatId,
    String messageId,
    String newContent,
  ) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'text': newContent,
        'isEdited': true,
        'editedAt': Timestamp.now(),
      });
    } catch (e) {
      state = state.copyWith(error: 'Failed to edit message: ${e.toString()}');
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete message: ${e.toString()}',
      );
    }
  }

  Future<void> addReaction(
    String chatId,
    String messageId,
    String reaction,
  ) async {
    try {
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);

      await messageRef.update({
        'reactions': FieldValue.arrayUnion([reaction]),
      });
    } catch (e) {
      state = state.copyWith(error: 'Failed to add reaction: ${e.toString()}');
    }
  }

  Future<void> createDirectChat(String otherUserId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      if (otherUserId == user.uid) {
        state = state.copyWith(error: 'You cannot chat with yourself');
        return;
      }

      // Deterministic key for direct chats (avoids unsupported array equality query)
      final keyParts = [user.uid, otherUserId]..sort();
      final chatKey = '${keyParts[0]}_${keyParts[1]}';
      final members = keyParts; // sorted members list

      // Check if chat already exists via chatKey
      final existingChatQuery = await _firestore
          .collection('chats')
          .where('chatKey', isEqualTo: chatKey)
          .where('isGroupChat', isEqualTo: false)
          .limit(1)
          .get();

      if (existingChatQuery.docs.isNotEmpty) {
        state = state.copyWith(selectedChatId: existingChatQuery.docs.first.id);
        return;
      }

      // Fetch other user's name
      final otherUserDoc =
          await _firestore.collection('users').doc(otherUserId).get();
      final otherUserData = otherUserDoc.data();
      final otherUserName = (otherUserData?['displayName'] as String?) ??
          (otherUserData?['email'] as String?) ??
          'Unknown';

      // Create new direct chat
      final chatRef = await _firestore.collection('chats').add({
        'name': otherUserName,
        'members': members,
        'isGroupChat': false,
        'chatKey': chatKey,
        'createdAt': Timestamp.now(),
        'lastMessageTime': Timestamp.now(),
        'creator': user.uid,
      });

      state = state.copyWith(selectedChatId: chatRef.id);
    } catch (e) {
      state = state.copyWith(error: 'Failed to create chat: ${e.toString()}');
    }
  }

  Future<void> createDirectChatByEmail(String email) async {
    try {
      state = state.copyWith(error: null);
      final user = _auth.currentUser;
      if (user == null) return;

      final normalized = email.trim();
      if (normalized.isEmpty) {
        state = state.copyWith(error: 'Please enter an email');
        return;
      }
      if (normalized.toLowerCase() == (user.email ?? '').toLowerCase()) {
        state = state.copyWith(error: 'You cannot chat with yourself');
        return;
      }

      // Look up user by email
      final q = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalized)
          .limit(1)
          .get();

      if (q.docs.isEmpty) {
        state = state.copyWith(error: 'No user found with this email');
        return;
      }

      final other = q.docs.first.data();
      final otherUid = other['uid'] as String?;
      final otherName = (other['displayName'] as String?) ??
          (other['email'] as String? ?? 'Unknown');
      if (otherUid == null || otherUid.isEmpty) {
        state = state.copyWith(error: 'User record is missing UID');
        return;
      }

      // Deterministic direct chat key
      final keyParts = [user.uid, otherUid]..sort();
      final chatKey = '${keyParts[0]}_${keyParts[1]}';

      // Check if chat already exists
      final existing = await _firestore
          .collection('chats')
          .where('chatKey', isEqualTo: chatKey)
          .where('isGroupChat', isEqualTo: false)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        state = state.copyWith(selectedChatId: existing.docs.first.id);
        return;
      }

      // Create chat with a friendly name for the current user
      final chatRef = await _firestore.collection('chats').add({
        'name': otherName,
        'members': keyParts,
        'isGroupChat': false,
        'chatKey': chatKey,
        'createdAt': Timestamp.now(),
        'lastMessageTime': Timestamp.now(),
        'creator': user.uid,
      });

      state = state.copyWith(selectedChatId: chatRef.id);
    } catch (e) {
      state = state.copyWith(error: 'Failed to create chat: ${e.toString()}');
    }
  }

  Future<void> createGroupChat(String name, List<String> memberIds) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final members = {user.uid, ...memberIds}.toList();

      final chatRef = await _firestore.collection('chats').add({
        'name': name,
        'members': members,
        'isGroupChat': true,
        'chatKey': '',
        'createdAt': Timestamp.now(),
        'lastMessageTime': Timestamp.now(),
        'creator': user.uid,
      });

      state = state.copyWith(selectedChatId: chatRef.id);
    } catch (e) {
      state = state.copyWith(error: 'Failed to create group: ${e.toString()}');
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Export currently selected chat messages as JSON
  String exportSelectedChatToJson() {
    final chatId = state.selectedChatId;
    if (chatId == null || chatId.isEmpty) {
      throw Exception('No chat selected for export');
    }
    
    final messages = state.messages;
    final meta = state.chats.firstWhere(
      (c) => c.id == chatId,
      orElse: () => Chat(
        id: chatId,
        name: 'Chat',
        members: const [],
        isGroupChat: false,
      ),
    );
    final map = {
      'chat': {
        'id': meta.id,
        'name': meta.name,
        'isGroupChat': meta.isGroupChat,
        'members': meta.members,
      },
      'messages': messages
          .map((m) => {
                'id': m.id,
                'text': m.content,
                'senderId': m.senderId,
                'senderName': m.senderName,
                'createdAt': m.timestamp.toIso8601String(),
                'type': m.type,
                'isEdited': m.isEdited,
                'editedAt': m.editedAt?.toIso8601String(),
                'reactions': m.reactions,
              })
          .toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  Future<bool> backupSelectedChatToDrive() async {
    try {
      final json = exportSelectedChatToJson();
      final folderId = await GoogleDriveService.instance.ensureAppFolder();
      final ok = await GoogleDriveService.instance.uploadTextFile(
        fileName:
            'chat_${state.selectedChatId ?? 'unknown'}_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json',
        content: json,
        folderId: folderId,
      );
      return ok;
    } catch (_) {
      return false;
    }
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
