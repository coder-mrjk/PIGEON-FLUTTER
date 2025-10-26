import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      timestamp: (data['createdAt'] as Timestamp).toDate(),
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
    String? selectedChatId,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedChatId: selectedChatId ?? this.selectedChatId,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState()) {
    _init();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _init() {
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = _auth.currentUser;
      if (user == null) return;

      final chatsQuery = _firestore
          .collection('chats')
          .where('members', arrayContains: user.uid)
          .orderBy('lastMessageTime', descending: true);

      chatsQuery.snapshots().listen((snapshot) {
        final chats =
            snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList();
        state = state.copyWith(chats: chats, isLoading: false);
      });
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

      messagesQuery.snapshots().listen((snapshot) {
        final messages = snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList()
            .reversed
            .toList();
        state = state.copyWith(messages: messages, isLoading: false);
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

      final members = [user.uid, otherUserId].toSet().toList();

      // Check if chat already exists
      final existingChatQuery = await _firestore
          .collection('chats')
          .where('members', isEqualTo: members)
          .where('isGroupChat', isEqualTo: false)
          .get();

      if (existingChatQuery.docs.isNotEmpty) {
        state = state.copyWith(selectedChatId: existingChatQuery.docs.first.id);
        return;
      }

      // Create new chat
      final chatRef = await _firestore.collection('chats').add({
        'members': members,
        'isGroupChat': false,
        'createdAt': Timestamp.now(),
        'lastMessageTime': Timestamp.now(),
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

      final members = [user.uid, ...memberIds].toSet().toList();

      final chatRef = await _firestore.collection('chats').add({
        'name': name,
        'members': members,
        'isGroupChat': true,
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
    state = state.copyWith(error: null);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
