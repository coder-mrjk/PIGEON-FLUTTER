/// API Configuration
///
/// IMPORTANT: Replace these placeholder API keys with your actual keys
///
/// To get your API keys:
/// 1. OpenAI: https://platform.openai.com/api-keys
/// 2. Google (Gemini): https://makersuite.google.com/app/apikey
/// 3. Perplexity: https://www.perplexity.ai/settings/api
///
/// SECURITY NOTE: In production, store these in environment variables
/// or use Flutter's secure storage instead of hardcoding them.
library;

import 'package:flutter_dotenv/flutter_dotenv.dart' as dtenv;

class APIConfig {
  // Prefer .env values; fall back to --dart-define; then placeholders.
  static String get openAIApiKey =>
      dtenv.dotenv.env['OPENAI_API_KEY'] ??
      const String.fromEnvironment(
        'OPENAI_API_KEY',
        defaultValue: 'YOUR_OPENAI_API_KEY_HERE',
      );
  static String get openAIModel => const String.fromEnvironment(
        'OPENAI_MODEL',
        defaultValue: 'gpt-4o-mini',
      );
  static String get openAIEndpoint => const String.fromEnvironment(
        'OPENAI_ENDPOINT',
        defaultValue: 'https://api.openai.com/v1/chat/completions',
      );

  // Google Gemini API Configuration
  static String get googleAPIKey =>
      dtenv.dotenv.env['GOOGLE_API_KEY'] ??
      const String.fromEnvironment(
        'GOOGLE_API_KEY',
        defaultValue: 'YOUR_GOOGLE_GEMINI_API_KEY_HERE',
      );
  static String get googleModel => const String.fromEnvironment(
        'GOOGLE_MODEL',
        defaultValue: 'gemini-1.5-flash',
      );
  static String get googleEndpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$googleModel:generateContent?key=$googleAPIKey';

  // Gemini Image Generation (Imagen)
  static String get googleImageModel => const String.fromEnvironment(
        'GOOGLE_IMAGE_MODEL',
        defaultValue: 'imagen-3.0-fast',
      );
  static String get googleImageEndpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$googleImageModel:generateImage?key=$googleAPIKey';

  // Perplexity API Configuration
  static String get perplexityApiKey =>
      dtenv.dotenv.env['PERPLEXITY_API_KEY'] ??
      const String.fromEnvironment(
        'PERPLEXITY_API_KEY',
        defaultValue: 'YOUR_PERPLEXITY_API_KEY_HERE',
      );
  static String get perplexityModel => const String.fromEnvironment(
        'PERPLEXITY_MODEL',
        defaultValue: 'llama-3.1-sonar-small-128k-online',
      );
  static String get perplexityEndpoint => const String.fromEnvironment(
        'PERPLEXITY_ENDPOINT',
        defaultValue: 'https://api.perplexity.ai/chat/completions',
      );

  // Check if API keys are configured
  static bool get isOpenAIConfigured =>
      openAIApiKey.isNotEmpty && !openAIApiKey.contains('YOUR_');

  static bool get isGoogleConfigured =>
      googleAPIKey.isNotEmpty && !googleAPIKey.contains('YOUR_');

  static bool get isPerplexityConfigured =>
      perplexityApiKey.isNotEmpty && !perplexityApiKey.contains('YOUR_');
}
