import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../config/api_config.dart';
import 'ai_provider.dart';

/// Enhanced Gemini provider with streaming responses and multimodal support
class GeminiAdvancedNotifier extends Notifier<AIState> {
  late final GenerativeModel _model;

  @override
  AIState build() {
    if (APIConfig.isGoogleConfigured) {
      _model = GenerativeModel(
        model: APIConfig.googleModel,
        apiKey: APIConfig.googleAPIKey,
      );
    }
    return const AIState();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    if (!APIConfig.isGoogleConfigured) {
      state = state.copyWith(
        error: 'Google API key not configured',
        isLoading: false,
      );
      return;
    }

    final userMessage = AIMessage(
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      // Build chat history for context
      final history = state.messages
          .take(state.messages.length - 1)
          .map((m) => Content(
                m.isUser ? 'user' : 'model',
                [TextPart(m.content)],
              ))
          .toList();

      final chat = _model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(message));

      final aiMessage = AIMessage(
        content: response.text ?? '',
        isUser: false,
        timestamp: DateTime.now(),
        provider: AIProvider.google,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gemini error: ${e.toString()}',
      );
    }
  }

  Future<void> sendMessageStreaming(String message) async {
    if (message.trim().isEmpty) return;
    if (!APIConfig.isGoogleConfigured) {
      state = state.copyWith(
        error: 'Google API key not configured',
        isLoading: false,
      );
      return;
    }

    final userMessage = AIMessage(
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final history = state.messages
          .take(state.messages.length - 1)
          .map((m) => Content(
                m.isUser ? 'user' : 'model',
                [TextPart(m.content)],
              ))
          .toList();

      final chat = _model.startChat(history: history);
      final responseStream = chat.sendMessageStream(Content.text(message));

      String accumulatedText = '';
      await for (final chunk in responseStream) {
        accumulatedText += chunk.text ?? '';

        // Update with accumulated response
        final aiMessage = AIMessage(
          content: accumulatedText,
          isUser: false,
          timestamp: DateTime.now(),
          provider: AIProvider.google,
        );

        state = state.copyWith(
          messages: [
            ...state.messages.take(state.messages.length - 1),
            userMessage,
            aiMessage,
          ],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gemini streaming error: ${e.toString()}',
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(messages: []);
  }
}

final geminiAdvancedProvider =
    NotifierProvider<GeminiAdvancedNotifier, AIState>(
  GeminiAdvancedNotifier.new,
);
