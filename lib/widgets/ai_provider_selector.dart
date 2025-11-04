import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/ai_provider.dart';

class AIProviderSelector extends ConsumerWidget {
  const AIProviderSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final aiState = ref.watch(aiProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Provider',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProviderCard(
                  context,
                  'OpenAI',
                  'GPT-4',
                  Icons.psychology,
                  AIProvider.openai,
                  aiState.selectedProvider,
                  () {
                    ref
                        .read(aiProvider.notifier)
                        .setProvider(AIProvider.openai);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProviderCard(
                  context,
                  'Google',
                  'Gemini',
                  Icons.g_mobiledata,
                  AIProvider.google,
                  aiState.selectedProvider,
                  () {
                    ref
                        .read(aiProvider.notifier)
                        .setProvider(AIProvider.google);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProviderCard(
                  context,
                  'Perplexity',
                  'Sonar',
                  Icons.search,
                  AIProvider.perplexity,
                  aiState.selectedProvider,
                  () {
                    ref
                        .read(aiProvider.notifier)
                        .setProvider(AIProvider.perplexity);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    AIProvider provider,
    AIProvider selectedProvider,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isSelected = provider == selectedProvider;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AIProviderInfo extends StatelessWidget {
  final AIProvider provider;

  const AIProviderInfo({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getProviderIcon(provider),
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getProviderName(provider),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  _getProviderDescription(provider),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getProviderIcon(AIProvider provider) {
    switch (provider) {
      case AIProvider.auto:
        return Icons.auto_awesome;
      case AIProvider.openai:
        return Icons.psychology;
      case AIProvider.google:
        return Icons.g_mobiledata;
      case AIProvider.perplexity:
        return Icons.search;
    }
  }

  String _getProviderName(AIProvider provider) {
    switch (provider) {
      case AIProvider.auto:
        return 'Auto (Smart)';
      case AIProvider.openai:
        return 'OpenAI GPT-4';
      case AIProvider.google:
        return 'Google Gemini';
      case AIProvider.perplexity:
        return 'Perplexity Sonar';
    }
  }

  String _getProviderDescription(AIProvider provider) {
    switch (provider) {
      case AIProvider.auto:
        return 'Automatically selects the best provider for your query';
      case AIProvider.openai:
        return 'Advanced reasoning and creativity';
      case AIProvider.google:
        return 'Multimodal AI with image understanding';
      case AIProvider.perplexity:
        return 'Real-time information and research';
    }
  }
}
