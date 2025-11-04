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

class APIConfig {
  // Prefer compile-time env via --dart-define; falls back to placeholders.
  static const String openAIApiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: 'YOUR_OPENAI_API_KEY_HERE',
  );
  static const String openAIModel = String.fromEnvironment(
    'OPENAI_MODEL',
    defaultValue: 'gpt-4o-mini',
  );
  static const String openAIEndpoint = String.fromEnvironment(
    'OPENAI_ENDPOINT',
    defaultValue: 'https://api.openai.com/v1/chat/completions',
  );

  // Google Gemini API Configuration
  static const String googleAPIKey = String.fromEnvironment(
    'GOOGLE_API_KEY',
    defaultValue: 'YOUR_GOOGLE_GEMINI_API_KEY_HERE',
  );
  static const String googleModel = String.fromEnvironment(
    'GOOGLE_MODEL',
    defaultValue: 'gemini-1.5-flash',
  );
  static String get googleEndpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$googleModel:generateContent?key=$googleAPIKey';

  // Gemini Image Generation (Imagen)
  static const String googleImageModel = String.fromEnvironment(
    'GOOGLE_IMAGE_MODEL',
    defaultValue: 'imagen-3.0-fast',
  );
  static String get googleImageEndpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$googleImageModel:generateImage?key=$googleAPIKey';

  // Perplexity API Configuration
  static const String perplexityApiKey = String.fromEnvironment(
    'PERPLEXITY_API_KEY',
    defaultValue: 'YOUR_PERPLEXITY_API_KEY_HERE',
  );
  static const String perplexityModel = String.fromEnvironment(
    'PERPLEXITY_MODEL',
    defaultValue: 'llama-3.1-sonar-small-128k-online',
  );
  static const String perplexityEndpoint = String.fromEnvironment(
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
