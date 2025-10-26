import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../core/providers/ai_provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/message_bubble.dart';
import '../widgets/custom_text_field.dart';
import 'chat_screen.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiState = ref.watch(aiProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.pigeonBlue.withOpacity(0.1),
              AppTheme.pigeonAccent.withOpacity(0.1),
              AppTheme.pigeonPurple.withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            // AI Chat Header
            _buildAIHeader(context, aiState),

            // Messages List
            Expanded(child: _buildMessagesList(context, aiState)),

            // Message Input
            _buildMessageInput(context, aiState),
          ],
        ),
      ),
    );
  }

  Widget _buildAIHeader(BuildContext context, AIState aiState) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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

          // AI Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.pigeonBlue, AppTheme.pigeonAccent],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
          ),

          const SizedBox(width: 12),

          // AI Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getAIProviderName(aiState.selectedProvider),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'AI Assistant',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Provider Selector
          PopupMenuButton<AIProvider>(
            icon: Icon(
              Icons.settings,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            onSelected: (provider) {
              ref.read(aiProvider.notifier).setProvider(provider);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: AIProvider.openai,
                child: Row(
                  children: [
                    const Icon(Icons.psychology, size: 20),
                    const SizedBox(width: 8),
                    const Text('OpenAI GPT-4'),
                    if (aiState.selectedProvider == AIProvider.openai)
                      const Icon(Icons.check, color: Colors.green),
                  ],
                ),
              ),
              PopupMenuItem(
                value: AIProvider.google,
                child: Row(
                  children: [
                    const Icon(Icons.g_mobiledata, size: 20),
                    const SizedBox(width: 8),
                    const Text('Google Gemini'),
                    if (aiState.selectedProvider == AIProvider.google)
                      const Icon(Icons.check, color: Colors.green),
                  ],
                ),
              ),
              PopupMenuItem(
                value: AIProvider.perplexity,
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 20),
                    const SizedBox(width: 8),
                    const Text('Perplexity Sonar'),
                    if (aiState.selectedProvider == AIProvider.perplexity)
                      const Icon(Icons.check, color: Colors.green),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, AIState aiState) {
    if (aiState.messages.isEmpty) {
      return _buildWelcomeMessage(context);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: aiState.messages.length,
      itemBuilder: (context, index) {
        final message = aiState.messages[index];
        return MessageBubble(
          message: ChatMessage(
            content: message.content,
            isUser: message.isUser,
            timestamp: message.timestamp,
            senderName: message.isUser
                ? null
                : _getAIProviderName(aiState.selectedProvider),
          ),
        ).animate().slideX(
              begin: message.isUser ? 0.3 : -0.3,
              end: 0,
              duration: 300.ms,
              delay: (index * 100).ms,
            );
      },
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.pigeonBlue, AppTheme.pigeonAccent],
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 40),
            ).animate().scale(duration: 1.seconds, curve: Curves.elasticOut),

            const SizedBox(height: 24),

            Text(
              'Welcome to Pigeon AI',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 800.ms, delay: 300.ms),

            const SizedBox(height: 8),

            Text(
              'I\'m your AI assistant. Ask me anything!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 800.ms, delay: 500.ms),

            const SizedBox(height: 32),

            // Quick Actions
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickActionChip(context, 'Help me with code', Icons.code),
                _buildQuickActionChip(context, 'Write an email', Icons.email),
                _buildQuickActionChip(context, 'Explain something', Icons.help),
                _buildQuickActionChip(context, 'Creative writing', Icons.edit),
              ],
            ).animate().fadeIn(duration: 800.ms, delay: 700.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(
    BuildContext context,
    String text,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      labelStyle: TextStyle(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, AIState aiState) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Error Message
          if (aiState.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.pigeonRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.pigeonRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppTheme.pigeonRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      aiState.error!,
                      style: TextStyle(color: AppTheme.pigeonRed, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(aiProvider.notifier).clearError();
                    },
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.pigeonRed,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

          // Message Input
          Row(
            children: [
              // Clear Chat Button
              IconButton(
                onPressed: aiState.messages.isEmpty
                    ? null
                    : () {
                        _showClearChatDialog(context);
                      },
                icon: Icon(
                  Icons.clear_all,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),

              // Message Input
              Expanded(
                child: MessageTextField(
                  controller: _messageController,
                  onSend: aiState.isLoading ? null : _sendMessage,
                  isLoading: aiState.isLoading,
                  hintText: 'Ask me anything...',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    ref.read(aiProvider.notifier).sendMessage(_messageController.text.trim());
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

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(aiProvider.notifier).clearMessages();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  String _getAIProviderName(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return 'OpenAI GPT-4';
      case AIProvider.google:
        return 'Google Gemini';
      case AIProvider.perplexity:
        return 'Perplexity Sonar';
    }
  }
}
