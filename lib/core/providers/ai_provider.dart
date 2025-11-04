import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

enum AIProvider { auto, openai, google, perplexity }

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
    this.selectedProvider = AIProvider.auto,
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

class AINotifier extends Notifier<AIState> {
  @override
  AIState build() => const AIState();

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
      // Decide provider (auto routes based on message intent)
      final chosen = state.selectedProvider == AIProvider.auto
          ? _chooseProvider(message)
          : state.selectedProvider;

      switch (chosen) {
        case AIProvider.openai:
          response = await _callOpenAI(message);
          break;
        case AIProvider.google:
          response = await _callGoogleAI(message);
          break;
        case AIProvider.perplexity:
          response = await _callPerplexity(message);
          break;
        case AIProvider.auto:
          // Unreachable due to above selection, but keep for exhaustiveness
          response = await _callOpenAI(message);
          break;
      }

      final aiMessage = AIMessage(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        provider: chosen,
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
    if (!APIConfig.isOpenAIConfigured) {
      throw Exception(
        'OpenAI API key not configured. Please add your API key in lib/core/config/api_config.dart',
      );
    }

    final response = await http.post(
      Uri.parse(APIConfig.openAIEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${APIConfig.openAIApiKey}',
      },
      body: jsonEncode({
        'model': APIConfig.openAIModel,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are JARVIS, a premium assistant inside Pigeon. Be precise, fast, and proactive. Use clear formatting and ask clarifying questions when needed.',
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
    if (!APIConfig.isGoogleConfigured) {
      throw Exception(
        'Google Gemini API key not configured. Please add your API key in lib/core/config/api_config.dart',
      );
    }

    final response = await http.post(
      Uri.parse(APIConfig.googleEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    'You are JARVIS, a premium assistant. Be clear, helpful, and structured.\n\nUser: $message'
              },
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
    if (!APIConfig.isPerplexityConfigured) {
      throw Exception(
        'Perplexity API key not configured. Please add your API key in lib/core/config/api_config.dart',
      );
    }

    final response = await http.post(
      Uri.parse(APIConfig.perplexityEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${APIConfig.perplexityApiKey}',
      },
      body: jsonEncode({
        'model': APIConfig.perplexityModel,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are JARVIS with real-time web awareness. Cite sources concisely and give up-to-date answers.',
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

  // Generate image using Gemini Imagen endpoint; returns raw bytes (PNG/JPEG)
  Future<Uint8List> generateImageWithGemini(
    String prompt, {
    int width = 1024,
    int height = 1024,
    String? negativePrompt,
  }) async {
    if (!APIConfig.isGoogleConfigured) {
      throw Exception(
        'Google Gemini API key not configured. Please add your API key in lib/core/config/api_config.dart',
      );
    }

    final uri = Uri.parse(APIConfig.googleImageEndpoint);

    final body = {
      // Some Imagen endpoints expect this shape; adjust per latest docs if needed
      'prompt': {
        'text': prompt,
      },
      'image': {
        'width': width,
        'height': height,
      },
      if (negativePrompt != null && negativePrompt.trim().isNotEmpty)
        'safetySettings': {
          'negativePrompt': negativePrompt,
        },
      'imageGenerationConfig': {
        'numberOfImages': 1,
      }
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('Gemini image API error: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body);

    // Try common response shapes
    // 1) generatedImages[0].image.bytesBase64
    if (data is Map && data['generatedImages'] != null) {
      final img = data['generatedImages'][0]['image'];
      final b64 = img['bytesBase64'] as String;
      return base64Decode(b64);
    }

    // 2) candidates[0].content.parts[0].inlineData.data
    try {
      final b64 = data['candidates'][0]['content']['parts'][0]['inlineData']
          ['data'] as String;
      return base64Decode(b64);
    } catch (_) {}

    throw Exception('Unexpected image response format');
  }

  AIProvider _chooseProvider(String message) {
    final lower = message.toLowerCase();

    // Real-time or web questions
    final webCues = [
      'news',
      'latest',
      'today',
      'current',
      'breaking',
      'who is',
      'what happened',
      'stock',
      'price',
      'twitter',
      'reddit',
      'url',
      'http',
      'https',
      'search'
    ];
    if (webCues.any((w) => lower.contains(w))) return AIProvider.perplexity;

    // Coding, debugging, technical content
    final codeCues = [
      'code',
      'bug',
      'error',
      'exception',
      'stack trace',
      'dart',
      'flutter',
      'react',
      'typescript',
      'python',
      'java',
      'regex',
      'compile',
      'build',
      'stack overflow'
    ];
    if (codeCues.any((w) => lower.contains(w))) return AIProvider.openai;

    // Creative/structured/writing tasks or long form
    final creativeCues = [
      'write',
      'draft',
      'outline',
      'summarize',
      'brainstorm',
      'explain',
      'compare',
      'analyze',
      'design',
      'idea'
    ];
    if (creativeCues.any((w) => lower.contains(w))) return AIProvider.google;

    // Default
    return AIProvider.openai;
  }

  void clearMessages() {
    state = state.copyWith(messages: []);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final aiProvider = NotifierProvider<AINotifier, AIState>(
  AINotifier.new,
);
