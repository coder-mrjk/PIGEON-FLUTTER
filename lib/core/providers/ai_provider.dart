import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

enum AIProvider { openai, google, perplexity }

class AIMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final AIProvider? provider;

  const AIMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.provider,
  });
}

class AIState {
  final List<AIMessage> messages;
  final bool isLoading;
  final String? error;
  final AIProvider selectedProvider;

  const AIState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.selectedProvider = AIProvider.openai,
  });

  AIState copyWith({
    List<AIMessage>? messages,
    bool? isLoading,
    String? error,
    AIProvider? selectedProvider,
  }) {
    return AIState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedProvider: selectedProvider ?? this.selectedProvider,
    );
  }
}

class AINotifier extends StateNotifier<AIState> {
  AINotifier() : super(const AIState());

  // API Keys - Replace with your actual API keys
  // In production, store these securely using environment variables or secure storage
  static const String _openaiApiKey = 'sk-your-openai-api-key-here';
  static const String _googleApiKey = 'your-google-ai-api-key-here';
  static const String _perplexityApiKey = 'pplx-your-perplexity-api-key-here';

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
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
      String response = '';
      switch (state.selectedProvider) {
        case AIProvider.openai:
          response = await _callOpenAI(message);
          break;
        case AIProvider.google:
          response = await _callGoogleAI(message);
          break;
        case AIProvider.perplexity:
          response = await _callPerplexity(message);
          break;
      }

      final aiMessage = AIMessage(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        provider: state.selectedProvider,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get AI response: ${e.toString()}',
      );
    }
  }

  Future<String> _callOpenAI(String message) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openaiApiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are Pigeon AI, a helpful and friendly assistant. Provide concise, accurate, and helpful responses.',
          },
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('OpenAI API error: ${response.statusCode}');
    }
  }

  Future<String> _callGoogleAI(String message) async {
    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_googleApiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': 'You are Pigeon AI, a helpful assistant. $message'},
            ],
          },
        ],
        'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 1000},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } else {
      throw Exception('Google AI API error: ${response.statusCode}');
    }
  }

  Future<String> _callPerplexity(String message) async {
    final response = await http.post(
      Uri.parse('https://api.perplexity.ai/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_perplexityApiKey',
      },
      body: jsonEncode({
        'model': 'llama-3.1-sonar-small-128k-online',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are Pigeon AI, a helpful assistant with access to real-time information.',
          },
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('Perplexity API error: ${response.statusCode}');
    }
  }

  void setProvider(AIProvider provider) {
    state = state.copyWith(selectedProvider: provider);
  }

  void clearMessages() {
    state = state.copyWith(messages: []);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final aiProvider = StateNotifierProvider<AINotifier, AIState>((ref) {
  return AINotifier();
});
