# Pigeon Flutter - Premium Chat App 🕊️

A premium Flutter web chat application with advanced AI integration, featuring OpenAI GPT-4, Google Gemini, and Perplexity AI.

## ✨ Features

### 🎨 Premium UI/UX
- **Glassmorphic Design**: Modern glass-effect UI with blur effects
- **Animated Backgrounds**: Dynamic gradient and particle animations
- **Dark/Light Themes**: Automatic theme switching with system preference
- **Responsive Design**: Optimized for web, mobile, and tablet
- **Smooth Animations**: Flutter Animate for premium feel

### 🤖 AI Integration
- **Multiple AI Providers**: OpenAI GPT-4, Google Gemini, Perplexity Sonar
- **Real-time Responses**: Fast AI chat with streaming responses
- **Provider Switching**: Easy switching between AI models
- **Context Awareness**: Maintains conversation context

### 💬 Advanced Chat Features
- **Real-time Messaging**: Firebase Firestore integration
- **Group Chats**: Create and manage group conversations
- **Message Actions**: Edit, delete, react to messages
- **Typing Indicators**: See when others are typing
- **Message Status**: Read receipts and delivery status
- **File Sharing**: Support for images, documents, and media

### 🔐 Authentication & Security
- **Firebase Auth**: Email/password and Google sign-in
- **Profile Management**: Custom display names and bios
- **Secure Storage**: Encrypted data storage
- **Privacy Controls**: Message encryption and privacy settings

### 🚀 Performance
- **Optimized Rendering**: Efficient list virtualization
- **Caching**: Smart caching for better performance
- **Lazy Loading**: Load content as needed
- **Web Optimized**: Fast loading and smooth scrolling

## 🛠️ Tech Stack

- **Framework**: Flutter 3.10+
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Storage)
- **AI APIs**: OpenAI, Google AI, Perplexity
- **UI Libraries**: 
  - `glassmorphism` - Glass effect containers
  - `flutter_animate` - Smooth animations
  - `google_fonts` - Typography
- **HTTP Client**: Dio for API calls
- **Storage**: SharedPreferences for local data

## 📦 Installation

### Prerequisites
- Flutter SDK 3.10 or higher
- Dart SDK 3.0 or higher
- Web browser (Chrome, Safari, Firefox, Edge)

### Setup

1. **Clone the repository**
   ```bash
   cd PIGEON-FOLDER
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Update `lib/firebase_options.dart` with your Firebase config
   - Enable Authentication and Firestore in Firebase Console

4. **Configure AI APIs**
   - Add your API keys in `lib/core/config/api_config.dart`:
     ```dart
     static const String openAIApiKey = 'YOUR_OPENAI_API_KEY';
     static const String googleAPIKey = 'YOUR_GOOGLE_API_KEY';
     static const String perplexityApiKey = 'YOUR_PERPLEXITY_API_KEY';
     ```
   - See [API Keys Setup](#-api-keys-setup) for detailed instructions

5. **Run the app**
   ```bash
   flutter run -d chrome
   ```

## 🔑 API Keys Setup

### OpenAI API
1. Visit [OpenAI Platform](https://platform.openai.com/api-keys)
2. Create an account and generate an API key (starts with `sk-`)
3. Add to `lib/core/config/api_config.dart`
4. The app will validate the key before making requests

### Google AI (Gemini)
1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a project and get API key
3. Add to `lib/core/config/api_config.dart`
4. Enable Gemini API in your Google Cloud project

### Perplexity AI
1. Visit [Perplexity AI Settings](https://www.perplexity.ai/settings/api)
2. Sign up and get API key (starts with `pplx-`)
3. Add to `lib/core/config/api_config.dart`
4. Note: Perplexity provides real-time web search capabilities

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/         # App constants and configurations
│   ├── providers/         # Riverpod state management
│   ├── theme/            # App theming and styles
│   └── utils/            # Utility functions and validators
├── screens/              # Main app screens
│   ├── auth_screen.dart
│   ├── home_screen.dart
│   ├── chat_screen.dart
│   ├── ai_chat_screen.dart
│   └── profile_setup_screen.dart
├── widgets/              # Reusable UI components
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── message_bubble.dart
│   ├── glassmorphic_container.dart
│   └── animated_background.dart
└── main.dart            # App entry point
```

## 🎯 Key Features Implementation

### AI Chat Integration
```dart
// Switch between AI providers
ref.read(aiProvider.notifier).setProvider(AIProvider.openai);

// Send message to AI
ref.read(aiProvider.notifier).sendMessage("Hello AI!");
```

### Real-time Chat
```dart
// Listen to messages
final chatState = ref.watch(chatProvider);

// Send message
ref.read(chatProvider.notifier).sendMessage(chatId, message);
```

### Theme Management
```dart
// Toggle theme
ref.read(themeProvider.notifier).toggleTheme();

// Get current theme
final themeMode = ref.watch(themeProvider);
```

## 🎨 Customization

### Colors
Update colors in `lib/core/theme/app_theme.dart`:
```dart
static const Color pigeonBlue = Color(0xFF1a56db);
static const Color pigeonAccent = Color(0xFF60a5fa);
```

### Animations
Modify animations in widget files using Flutter Animate:
```dart
widget.animate().fadeIn(duration: 500.ms).slideX(begin: 0.3);
```

### Glass Effects
Customize glass morphism in `glassmorphic_container.dart`:
```dart
GlassmorphicContainer(
  blur: 20,
  borderRadius: 16,
  // ... other properties
)
```

## 🚀 Deployment

### Web Deployment
```bash
flutter build web --release
```

### Firebase Hosting
```bash
firebase deploy --only hosting
```

## 📱 Features Roadmap

- [ ] Voice Messages
- [ ] Video Calls
- [ ] Screen Sharing
- [ ] File Encryption
- [ ] Push Notifications
- [ ] Offline Support
- [ ] Multi-language Support
- [ ] Custom Themes
- [ ] Message Scheduling
- [ ] AI Image Generation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- OpenAI, Google, and Perplexity for AI APIs
- Community packages and contributors

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Email: support@pigeon-chat.com
- Documentation: [docs.pigeon-chat.com](https://docs.pigeon-chat.com)

---

**Made with ❤️ using Flutter**
