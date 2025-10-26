# 🚀 Pigeon Flutter - Quick Setup Guide

## 📋 Prerequisites
- ✅ Flutter SDK installed (you mentioned you have it)
- ✅ Web browser (Chrome recommended)
- 🔑 API Keys (optional for basic testing)

## 🏃‍♂️ Quick Start

### Option 1: Use Launch Script (Recommended)
```bash
cd PIGEON-FOLDER
./launch.sh
```

### Option 2: Manual Launch
```bash
cd PIGEON-FOLDER
flutter pub get
flutter run -d chrome
```

## 🔧 Configuration

### 1. Firebase Setup (Required for full functionality)
The app is pre-configured with the existing Firebase project, but you can:
- Use the existing configuration (already set up)
- Or replace with your own Firebase project in `lib/firebase_options.dart`

### 2. AI API Keys (Optional - for AI chat features)
Edit `lib/core/providers/ai_provider.dart` and replace:

```dart
// Replace these with your actual API keys
static const String _openaiApiKey = 'sk-your-openai-api-key-here';
static const String _googleApiKey = 'your-google-ai-api-key-here';
static const String _perplexityApiKey = 'pplx-your-perplexity-api-key-here';
```

**Get API Keys:**
- **OpenAI**: https://platform.openai.com/api-keys
- **Google AI**: https://makersuite.google.com/app/apikey
- **Perplexity**: https://www.perplexity.ai/settings/api

## 🎯 What You'll See

### 1. **Splash Screen**
- Animated Pigeon logo
- Loading animation
- Premium gradient background

### 2. **Authentication**
- Email/Password login
- Google Sign-in
- Beautiful glassmorphic design
- Smooth animations

### 3. **Profile Setup**
- Display name and bio
- Glassmorphic form design
- Validation

### 4. **Home Screen**
- Chat list with real-time updates
- AI Assistant tab
- Settings
- Premium UI with animations

### 5. **Chat Features**
- Real-time messaging
- Message editing/deletion
- Typing indicators
- Group chats
- Premium message bubbles

### 6. **AI Chat**
- Multiple AI providers
- Provider switching
- Real-time responses
- Context awareness

## 🎨 Features Included

### ✨ Premium UI/UX
- **Glassmorphic Design**: Modern glass effects
- **Animated Backgrounds**: Dynamic gradients and particles
- **Dark/Light Themes**: Auto-switching with system
- **Smooth Animations**: Flutter Animate integration
- **Responsive Design**: Works on all screen sizes

### 🤖 AI Integration
- **OpenAI GPT-4**: Advanced reasoning
- **Google Gemini**: Multimodal capabilities
- **Perplexity Sonar**: Real-time information
- **Easy Provider Switching**: Toggle between AIs
- **Context Preservation**: Maintains conversation flow

### 💬 Advanced Chat
- **Real-time Messaging**: Firebase Firestore
- **Group Chats**: Create and manage groups
- **Message Actions**: Edit, delete, react
- **File Sharing**: Images and documents
- **Typing Indicators**: See when others type
- **Message Status**: Read receipts

### 🔐 Security & Auth
- **Firebase Authentication**: Secure login
- **Google Sign-in**: One-click authentication
- **Profile Management**: Custom display names
- **Data Encryption**: Secure message storage

## 🛠️ Customization

### Colors & Themes
Edit `lib/core/theme/app_theme.dart`:
```dart
static const Color pigeonBlue = Color(0xFF1a56db);
static const Color pigeonAccent = Color(0xFF60a5fa);
```

### Animations
Modify animations using Flutter Animate:
```dart
widget.animate().fadeIn(duration: 500.ms).slideX(begin: 0.3);
```

### Glass Effects
Customize in `lib/widgets/glassmorphic_container.dart`:
```dart
GlassmorphicContainer(
  blur: 20,
  borderRadius: 16,
  // ... customize properties
)
```

## 🚨 Troubleshooting

### Common Issues:

1. **Flutter not found**
   ```bash
   export PATH="$PATH:[PATH_TO_FLUTTER_GIT_DIRECTORY]/flutter/bin"
   ```

2. **Dependencies issues**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Web not enabled**
   ```bash
   flutter config --enable-web
   ```

4. **Chrome not found**
   ```bash
   flutter devices  # Check available devices
   flutter run -d web-server  # Use web server instead
   ```

## 📱 Testing Without API Keys

The app works perfectly without AI API keys! You can:
- ✅ Create accounts and login
- ✅ Send regular chat messages
- ✅ Create group chats
- ✅ Use all UI features
- ✅ Test animations and themes
- ❌ AI chat will show error (expected)

## 🎯 Next Steps

1. **Test Basic Features**: Login, chat, UI
2. **Add AI Keys**: For full AI functionality
3. **Customize**: Colors, themes, animations
4. **Deploy**: Build for production

## 📞 Need Help?

- 📖 Check the main README.md
- 🐛 Create GitHub issues
- 💬 Test the chat features first!

---

**🕊️ Enjoy your premium chat experience with Pigeon!**
