import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/ui_chat_message.dart';
import '../core/providers/auth_provider.dart';
import '../core/providers/chat_provider.dart' as core;
import '../widgets/custom_text_field.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final core.Chat chat;
  const ChatScreen({super.key, required this.chat});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Ensure messages stream is attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(core.chatProvider.notifier).loadMessages(widget.chat.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            // Chat Header
            _buildChatHeader(context),

            // Messages List
            Expanded(
              child: _buildMessagesList(context),
            ),

            // Message Input
            _buildMessageInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),

          // Chat Avatar (fallback initials)
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              (widget.chat.name.isNotEmpty ? widget.chat.name[0] : 'C')
                  .toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Chat Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name.isNotEmpty ? widget.chat.name : 'Chat',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.chat.isGroupChat ? 'Group' : 'Direct',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // More Options
          IconButton(
            onPressed: () {
              _showChatOptions(context);
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context) {
    final chatState = ref.watch(core.chatProvider);
    final theme = Theme.of(context);

    if (chatState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (chatState.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        final uiMsg = UIChatMessage(
          content: message.content,
          isUser: message.senderId == ref.read(authProvider).user?.uid,
          timestamp: message.timestamp,
          senderName: message.senderName,
        );
        return MessageBubble(
          message: uiMsg,
          onTap: () {
            _showMessageOptions(context, message);
          },
        ).animate().slideX(
              begin: message.senderId == ref.read(authProvider).user?.uid
                  ? 0.3
                  : -0.3,
              end: 0,
              duration: 300.ms,
              delay: (index * 100).ms,
            );
      },
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment Button
          IconButton(
            onPressed: () {
              _showAttachmentOptions(context);
            },
            icon: Icon(
              Icons.attach_file,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),

          // Message Input
          Expanded(
            child: MessageTextField(
              controller: _messageController,
              onSend: _sendMessage,
              onAttachment: () {
                _showAttachmentOptions(context);
              },
              onEmoji: () {
                _showEmojiPicker(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    ref.read(core.chatProvider.notifier).sendMessage(
          widget.chat.id,
          _messageController.text.trim(),
        );

    _messageController.clear();

    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.of(context).pop();
                // Navigate to profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.of(context).pop();
                // Toggle notifications
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block User'),
              onTap: () {
                Navigator.of(context).pop();
                // Block user
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context, core.ChatMessage message) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.of(context).pop();
                // Copy message
              },
            ),
            if (message.senderId == ref.read(authProvider).user?.uid) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.of(context).pop();
                  _editMessage(message);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteMessage(message);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              title: Row(
                children: [
                  Text(
                    'Photo',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: null,
            ),
            ListTile(
              leading: Icon(
                Icons.videocam,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              title: Row(
                children: [
                  Text(
                    'Video',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: null,
            ),
            ListTile(
              leading: Icon(
                Icons.attach_file,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              title: Row(
                children: [
                  Text(
                    'File',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: null,
            ),
            ListTile(
              leading: Icon(
                Icons.storage,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              title: Row(
                children: [
                  Text(
                    'Storage',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Coming Soon',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker(BuildContext context) {
    // Implement emoji picker
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emoji Picker'),
        content: const Text('Emoji picker will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editMessage(core.ChatMessage message) {
    // Implement message editing
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: TextEditingController(text: message.content),
          decoration: const InputDecoration(
            hintText: 'Edit your message...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final controller = TextEditingController(text: message.content);
              Navigator.of(context).pop();
              // Update message via provider
              ref.read(core.chatProvider.notifier).editMessage(
                    widget.chat.id,
                    message.id,
                    controller.text.trim(),
                  );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(core.ChatMessage message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(core.chatProvider.notifier)
                  .deleteMessage(widget.chat.id, message.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
