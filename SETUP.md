# Pigeon - Setup Guide

## ✅ What's Working

Your Pigeon Flutter app is now **FULLY FUNCTIONAL** with the following features:

### 🔐 Authentication
- ✅ Email/Password Sign In & Sign Up
- ✅ Google Sign In (Firebase Auth)
- ✅ Profile Setup Flow
- ✅ Session Management
- ✅ Error Handling & Validation

### 💬 Chat System
- ✅ Real-time Chat List (Firestore)
- ✅ Real-time Messaging (Firestore Snapshots)
- ✅ Message Sending & Receiving
- ✅ Direct & Group Chat Support
- ✅ Empty State Handling

### 🤖 AI Assistant
- ✅ Multi-Provider Support (OpenAI, Google Gemini, Perplexity)
- ✅ Auto Provider Routing (Smart Selection)
- ✅ Chat History
- ✅ Error Handling
- ✅ Loading States

### 🎨 UI/UX
- ✅ Light & Dark Theme Support
- ✅ Glassmorphic Design
- ✅ Smooth Animations (flutter_animate)
- ✅ Responsive Layout
- ✅ Custom Components

### 🔧 Technical
- ✅ State Management (Riverpod)
- ✅ Firebase Integration (Auth, Firestore)
- ✅ No Analysis Errors
- ✅ Null Safety
- ✅ SVG Assets Support

---

## 🚀 Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
# Run on Chrome (default)
flutter run -d chrome

# Or use the simple demo flow
flutter run -d chrome -t lib/simple_main.dart
```

The app will start automatically!

---

## 🔑 API Configuration (Optional)

The AI features require API keys. You have **two options**:

### Option A: Environment Variables (Recommended)
```bash
flutter run -d chrome \
  --dart-define=OPENAI_API_KEY=your_openai_key \
  --dart-define=GOOGLE_API_KEY=your_google_key \
  --dart-define=PERPLEXITY_API_KEY=your_perplexity_key
```

### Option B: Edit Config File
Edit `lib/core/config/api_config.dart` and replace placeholders:
```dart
static const String openAIApiKey = 'sk-your-actual-key-here';
static const String googleAPIKey = 'your-google-api-key-here';
static const String perplexityApiKey = 'pplx-your-key-here';
```

### Get API Keys:
- **OpenAI**: https://platform.openai.com/api-keys
- **Google Gemini**: https://makersuite.google.com/app/apikey
- **Perplexity**: https://www.perplexity.ai/settings/api

**Note:** The app works WITHOUT AI keys - you just won't be able to use the AI Assistant feature.

---

## 📱 Features Overview

### Authentication Flow
1. **Splash Screen** → Checks auth state
2. **Auth Screen** → Sign In / Sign Up
3. **Profile Setup** → Complete profile (skippable)
4. **Home Screen** → Main app interface

### Home Screen Tabs
- **Chats**: View and manage conversations
- **AI Assistant**: Chat with AI (requires API keys)
- **Settings**: Theme, profile, logout

### Creating New Chats
1. Click the **+ FAB** button on Chats tab
2. Choose "New Direct Chat" or "Create Group"
3. Start chatting!

### Using AI Assistant
1. Go to **AI Assistant** tab
2. Select provider (Auto/OpenAI/Google/Perplexity)
3. Use quick actions or type your message
4. Click the **AI FAB** button to open full chat

---

## 🛠️ Development Commands

### Lint & Format
```bash
# Analyze code
flutter analyze

# Format code
dart format .
```

### Build for Production
```bash
# Build web release
flutter build web --release

# Deploy to Firebase (if configured)
firebase deploy --only hosting
```

### Testing
```bash
# Run all tests (when added)
flutter test

# Run specific test file
flutter test test/some_test.dart
```

---

## 📦 Project Structure

```
lib/
├── main.dart                    # Main entry point
├── simple_main.dart            # Simple demo entry
├── firebase_options.dart       # Firebase config (DO NOT DELETE)
├── core/
│   ├── config/
│   │   └── api_config.dart    # API keys config
│   ├── providers/             # Riverpod state management
│   │   ├── auth_provider.dart
│   │   ├── chat_provider.dart
│   │   ├── ai_provider.dart
│   │   └── theme_provider.dart
│   ├── theme/                 # Theme configuration
│   └── utils/                 # Utility functions
├── screens/                   # All app screens
├── widgets/                   # Reusable widgets
└── assets/                    # Images, icons, etc.
```

---

## 🔥 Firebase Setup (Already Configured!)

Your Firebase is **already configured** with:
- Project ID: `pigeon--7`
- Authentication enabled
- Firestore database ready
- Web app registered

### Firestore Structure
```
users/
  {userId}/
    - displayName: string
    - bio: string
    - email: string
    - createdAt: timestamp

chats/
  {chatId}/
    - name: string
    - members: array
    - isGroupChat: boolean
    - lastMessage: string
    - lastMessageTime: timestamp
    
    messages/
      {messageId}/
        - text: string
        - uid: string
        - senderName: string
        - createdAt: timestamp
```

---

## 🎨 Customization

### Change Theme Colors
Edit `lib/core/theme/app_theme.dart`:
```dart
static const Color pigeonBlue = Color(0xFF1A56DB);
static const Color pigeonAccent = Color(0xFF60A5FA);
static const Color pigeonPurple = Color(0xFF8B5CF6);
```

### Change App Name
1. Edit `web/index.html` - Change `<title>Pigeon</title>`
2. Edit `web/manifest.json` - Update app name

---

## 🐛 Troubleshooting

### Issue: White screen on startup
**Solution**: Clear browser cache or use incognito mode

### Issue: Firebase errors
**Solution**: Make sure `firebase_options.dart` exists and hasn't been modified

### Issue: AI not working
**Solution**: Add API keys (see API Configuration section)

### Issue: Chats not showing
**Solution**: 
1. Sign in with an account
2. Create a new chat using the + button
3. Send a message to see it in the list

---

## 🚢 Deployment

### Firebase Hosting (Recommended)
```bash
# Build web app
flutter build web --release

# Deploy
firebase deploy --only hosting
```

### Other Platforms
```bash
# Vercel
vercel deploy

# Netlify
netlify deploy --dir=build/web
```

---

## 📝 Notes

- **Web is the primary target** (mobile builds not included)
- **Firebase is required** for authentication and chat
- **AI keys are optional** - app works without them
- **All linting passes** with no errors
- **State management** via Riverpod providers

---

## 🎯 Next Steps

Want to extend the app? Consider adding:
- [ ] Voice messages
- [ ] File uploads (images, documents)
- [ ] Message reactions
- [ ] Read receipts
- [ ] Push notifications
- [ ] Video calls
- [ ] User search
- [ ] Chat encryption

---

## 📞 Support

If you encounter any issues:
1. Check this guide
2. Run `flutter analyze` to check for errors
3. Check Firebase console for backend issues
4. Clear browser cache and try again

---

**✨ Your app is ready to use! Just run `flutter run -d chrome` and start chatting!**
