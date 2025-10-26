class AppConstants {
  // App Information
  static const String appName = 'Pigeon';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Premium Chat Experience with AI Integration';

  // API Endpoints
  static const String openaiApiUrl =
      'https://api.openai.com/v1/chat/completions';
  static const String googleApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  static const String perplexityApiUrl =
      'https://api.perplexity.ai/chat/completions';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String aiChatsCollection = 'ai_chats';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String chatImagesPath = 'chat_images';
  static const String chatFilesPath = 'chat_files';

  // Message Types
  static const String textMessageType = 'text';
  static const String imageMessageType = 'image';
  static const String fileMessageType = 'file';
  static const String audioMessageType = 'audio';
  static const String videoMessageType = 'video';

  // AI Models
  static const String openaiModel = 'gpt-4';
  static const String googleModel = 'gemini-pro';
  static const String perplexityModel = 'llama-3.1-sonar-small-128k-online';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // UI Constants
  static const double borderRadius = 12.0;
  static const double largeBorderRadius = 20.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;

  // Message Limits
  static const int maxMessageLength = 4000;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB

  // Pagination
  static const int messagesPerPage = 50;
  static const int chatsPerPage = 20;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 24);
  static const Duration imageCacheDuration = Duration(days: 7);

  // Error Messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unknown error occurred';
  static const String authError = 'Authentication failed';
  static const String permissionError = 'Permission denied';

  // Success Messages
  static const String messageSent = 'Message sent successfully';
  static const String profileUpdated = 'Profile updated successfully';
  static const String chatCreated = 'Chat created successfully';
  static const String messageDeleted = 'Message deleted successfully';

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength =
      'Password must be at least 6 characters';
  static const String nameRequired = 'Name is required';
  static const String nameMinLength = 'Name must be at least 2 characters';
  static const String messageRequired = 'Message is required';
  static const String messageMaxLength = 'Message is too long';

  // Feature Flags
  static const bool enableDarkMode = true;
  static const bool enableNotifications = true;
  static const bool enableFileSharing = true;
  static const bool enableVoiceMessages = false;
  static const bool enableVideoCalls = false;
  static const bool enableScreenSharing = false;

  // AI Features
  static const bool enableOpenAI = true;
  static const bool enableGoogleAI = true;
  static const bool enablePerplexity = true;
  static const bool enableImageGeneration = false;
  static const bool enableCodeExecution = false;

  // Security
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const Duration sessionTimeout = Duration(hours: 24);

  // Performance
  static const int maxConcurrentRequests = 5;
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration retryDelay = Duration(seconds: 2);
  static const int maxRetries = 3;

  // Analytics
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePerformanceMonitoring = true;

  // Development
  static const bool enableDebugMode = false;
  static const bool enableLogging = true;
  static const bool enableHotReload = true;

  // Localization
  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'zh',
    'ja',
    'ko',
  ];

  // Themes
  static const List<String> availableThemes = ['light', 'dark', 'system'];
  static const String defaultTheme = 'system';

  // Notifications
  static const String notificationChannelId = 'pigeon_notifications';
  static const String notificationChannelName = 'Pigeon Notifications';
  static const String notificationChannelDescription =
      'Chat and AI notifications';

  // File Types
  static const List<String> allowedImageTypes = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];
  static const List<String> allowedFileTypes = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'zip',
    'rar',
  ];
  static const List<String> allowedAudioTypes = ['mp3', 'wav', 'm4a', 'aac'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi', 'mkv'];

  // Emoji Categories
  static const List<String> emojiCategories = [
    'recent',
    'smileys',
    'people',
    'animals',
    'food',
    'travel',
    'activities',
    'objects',
    'symbols',
    'flags',
  ];

  // Quick Actions
  static const List<Map<String, dynamic>> quickActions = [
    {
      'title': 'Ask Question',
      'icon': 'help_outline',
      'description': 'Get help with any question',
    },
    {
      'title': 'Code Help',
      'icon': 'code',
      'description': 'Get assistance with programming',
    },
    {
      'title': 'Writing',
      'icon': 'edit',
      'description': 'Help with writing and editing',
    },
    {
      'title': 'Research',
      'icon': 'search',
      'description': 'Research and find information',
    },
  ];

  // AI Prompts
  static const Map<String, String> aiPrompts = {
    'help':
        'You are Pigeon AI, a helpful and friendly assistant. Provide concise, accurate, and helpful responses.',
    'code':
        'You are Pigeon AI, a programming assistant. Help with code, debugging, and best practices.',
    'writing':
        'You are Pigeon AI, a writing assistant. Help with grammar, style, and content creation.',
    'research':
        'You are Pigeon AI, a research assistant. Provide accurate, up-to-date information and sources.',
  };
}
