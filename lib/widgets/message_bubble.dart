import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/models/ui_chat_message.dart';
import '../core/theme/app_theme.dart';
import '../widgets/glassmorphic_container.dart';

class MessageBubble extends StatelessWidget {
  final UIChatMessage message;
  final VoidCallback? onTap;

  const MessageBubble({super.key, required this.message, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bubbleContent = Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            // Sender Avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                message.senderName?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Message Bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: GlassmorphicContainer(
                borderRadius: message.isUser ? 20 : 20,
                blur: 10,
                alignment: Alignment.center,
                border: 1,
                gradientColors: message.isUser
                    ? [AppTheme.pigeonBlue, AppTheme.pigeonAccent]
                    : [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withValues(alpha: 0.8),
                      ],
                borderGradientColors: message.isUser
                    ? [
                        AppTheme.pigeonBlue.withValues(alpha: 0.3),
                        AppTheme.pigeonAccent.withValues(alpha: 0.3),
                      ]
                    : [
                        theme.colorScheme.outline.withValues(alpha: 0.2),
                        theme.colorScheme.outline.withValues(alpha: 0.1),
                      ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sender Name (for received messages)
                      if (!message.isUser && message.senderName != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            message.senderName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      // Message Content
                      Text(
                        message.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: message.isUser
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Timestamp
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(message.timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: message.isUser
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                              fontSize: 11,
                            ),
                          ),
                          if (message.isUser) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.done_all,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (message.isUser) ...[
            const SizedBox(width: 8),
            // User Avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: bubbleContent,
      );
    }
    return bubbleContent;
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.psychology, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeInOut,
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 600.ms, delay: (index * 200).ms)
        .then()
        .fadeOut(duration: 600.ms);
  }
}

class MessageReactions extends StatelessWidget {
  final List<String> reactions;
  final ValueChanged<String>? onReactionTap;

  const MessageReactions({
    super.key,
    required this.reactions,
    this.onReactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: reactions.map((reaction) {
          return GestureDetector(
            onTap: () => onReactionTap?.call(reaction),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                reaction,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
