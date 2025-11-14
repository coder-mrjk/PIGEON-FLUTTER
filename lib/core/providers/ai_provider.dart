import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/ai_prompts.dart';
import '../config/api_config.dart';
import '../services/google_drive_service.dart';

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
  final bool autoBackupEnabled;
  final double temperature; // 0.0 - 1.0
  final int maxTokens; // output tokens
  final bool storeAIInCloud; // consent flag persisted in users/{uid}.storeAI

  const AIState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.selectedProvider = AIProvider.auto,
    this.autoBackupEnabled = false,
    this.temperature = 0.7,
    this.maxTokens = 1000,
    this.storeAIInCloud = false,
  });

  AIState copyWith({
    List<AIMessage>? messages,
    bool? isLoading,
    String? error,
    bool clearError = false,
    AIProvider? selectedProvider,
    bool? autoBackupEnabled,
    double? temperature,
    int? maxTokens,
    bool? storeAIInCloud,
  }) {
    return AIState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedProvider: selectedProvider ?? this.selectedProvider,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      storeAIInCloud: storeAIInCloud ?? this.storeAIInCloud,
    );
  }
}

class AINotifier extends Notifier<AIState> {
  @override
  AIState build() => const AIState();

  Future<void> setStoreAIInCloud(bool value) async {
    state = state.copyWith(storeAIInCloud: value);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'storeAI': value}, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  // Export messages to a portable JSON format for backups
  String exportMessagesJson() {
    final data = state.messages
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.content,
              'timestamp': m.timestamp.toIso8601String(),
              'provider': m.provider?.name,
            })
        .toList();
    return const JsonEncoder.withIndent('  ').convert({'messages': data});
  }

  Future<bool> backupToGoogleDrive() async {
    final json = exportMessagesJson();
    final folderId = await GoogleDriveService.instance.ensureAppFolder();
    final ok = await GoogleDriveService.instance.uploadTextFile(
      fileName:
          'ai_chat_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json',
      content: json,
      folderId: folderId,
    );
    return ok;
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = AIMessage(
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Persist user message if opted in
    try {
      await _persistAIMessage(role: 'user', content: message);
    } catch (e) {
      // Log error but don't block the user experience
      debugPrint('Warning: Failed to persist user message: $e');
    }

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

      // Optional AI chat persistence if opted in
      try {
        await _persistAIMessage(role: 'assistant', content: response);
      } catch (e) {
        // Log error but don't block the user experience
        debugPrint('Warning: Failed to persist AI response: $e');
      }

      // Optional auto backup to Google Drive
      if (state.autoBackupEnabled) {
        try {
          await backupToGoogleDrive();
        } catch (e) {
          debugPrint('Warning: Auto backup to Google Drive failed: $e');
        }
      }
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
            'content': AIPrompts.openAISystemPrompt,
          },
          {'role': 'user', 'content': message},
        ],
        'max_tokens': state.maxTokens,
        'temperature': state.temperature,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Validate response structure
      if (data['choices'] == null || 
          (data['choices'] as List).isEmpty ||
          data['choices'][0]['message'] == null ||
          data['choices'][0]['message']['content'] == null) {
        throw Exception('Invalid response format from OpenAI');
      }
      return data['choices'][0]['message']['content'] as String;
    } else {
      final errorBody = response.body;
      throw Exception('OpenAI API error (${response.statusCode}): $errorBody');
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
                'text': '${AIPrompts.googleSystemPrompt}\n\nUser: $message'
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': state.temperature,
          'maxOutputTokens': state.maxTokens
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Validate response structure
      if (data['candidates'] == null ||
          (data['candidates'] as List).isEmpty ||
          data['candidates'][0]['content'] == null ||
          data['candidates'][0]['content']['parts'] == null ||
          (data['candidates'][0]['content']['parts'] as List).isEmpty ||
          data['candidates'][0]['content']['parts'][0]['text'] == null) {
        throw Exception('Invalid response format from Google AI');
      }
      return data['candidates'][0]['content']['parts'][0]['text'] as String;
    } else {
      final errorBody = response.body;
      throw Exception('Google AI API error (${response.statusCode}): $errorBody');
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
            'content': AIPrompts.perplexitySystemPrompt,
          },
          {'role': 'user', 'content': message},
        ],
        'max_tokens': state.maxTokens,
        'temperature': state.temperature,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Validate response structure
      if (data['choices'] == null ||
          (data['choices'] as List).isEmpty ||
          data['choices'][0]['message'] == null ||
          data['choices'][0]['message']['content'] == null) {
        throw Exception('Invalid response format from Perplexity');
      }
      return data['choices'][0]['message']['content'] as String;
    } else {
      final errorBody = response.body;
      throw Exception('Perplexity API error (${response.statusCode}): $errorBody');
    }
  }

  void setProvider(AIProvider provider) {
    state = state.copyWith(selectedProvider: provider);
  }

  Future<void> _persistAIMessage(
      {required String role, required String content}) async {
    if (!state.storeAIInCloud) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final sessionId = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    final col = FirebaseFirestore.instance
        .collection('ai_chats')
        .doc(uid)
        .collection('sessions')
        .doc(sessionId)
        .collection('messages');
    await col.add({
      'role': role,
      'text': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void toggleAutoBackup() {
    state = state.copyWith(autoBackupEnabled: !state.autoBackupEnabled);
  }

  void setTemperature(double value) {
    final clamped = value.clamp(0.0, 1.0);
    state = state.copyWith(temperature: clamped);
  }

  void setMaxTokens(int value) {
    final clamped = value.clamp(1, 8192);
    state = state.copyWith(maxTokens: clamped);
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
    state = state.copyWith(clearError: true);
  }
}

final aiProvider = NotifierProvider<AINotifier, AIState>(
  AINotifier.new,
);
