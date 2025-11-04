# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Common commands

- Install dependencies
  ```bash
  flutter pub get
  ```
- Run (web, default entry)
  ```bash
  flutter run -d chrome
  ```
- Run with alternate entry (simple demo flow)
  ```bash
  flutter run -d chrome -t lib/simple_main.dart
  ```
- Lint (uses analysis_options.yaml + flutter_lints)
  ```bash
  flutter analyze
  ```
- Format code
  ```bash
  dart format .
  ```
- Test (no tests present yet, examples below)
  ```bash
  # all tests
  flutter test
  # single file
  flutter test test/some_test.dart
  # by name pattern
  flutter test --name "pattern"
  ```
- Build for web (release)
  ```bash
  flutter build web --release
  ```
- Deploy to Firebase Hosting (if configured locally)
  ```bash
  firebase deploy --only hosting
  ```

## Setup highlights (from README)

Before running:
- Configure Firebase in `lib/firebase_options.dart` (FlutterFire-generated file).
- Add API keys/endpoints in `lib/core/config/api_config.dart` (OpenAI, Google Gemini, Perplexity).

## High-level architecture

- Entry & app shell
  - `lib/main.dart`: Initializes Firebase (`DefaultFirebaseOptions.currentPlatform`), wraps app in `ProviderScope`, wires `AppTheme.light/dark` and `ThemeMode` from `themeProvider`, starts at `SplashScreen`.
  - `lib/simple_main.dart`: Alternate lightweight entry using `SimpleTheme` and `SimpleAuthScreen`.

- State management (Riverpod + StateNotifier)
  - `core/providers/theme_provider.dart`: Persists `ThemeMode` via SharedPreferences; exposes `toggleTheme()` and `setTheme()`.
  - `core/providers/auth_provider.dart`: Auth state (`User?`, loading, error, profile completeness). Listens to `FirebaseAuth.authStateChanges()`, checks Firestore `users/{uid}`; email/password and Google sign-in flows; profile completion writer.
  - `core/providers/chat_provider.dart`: Chat list and message list state. Real-time listeners via Firestore `snapshots()` for chats and messages; CRUD for messages; direct/group chat creators; lightweight `Chat` and `ChatMessage` models.
  - `core/providers/ai_provider.dart`: AI chat state and routing. Sends messages through selected provider (OpenAI, Google, Perplexity) using `http`; provider auto-selection via heuristics; optional Gemini image generation returns `Uint8List`.

- Configuration & theming
  - `core/config/api_config.dart`: Central place for AI API keys, endpoints, and model names; boolean guards like `isOpenAIConfigured`.
  - `core/theme/app_theme.dart` and `core/theme/simple_theme.dart`: Centralized color roles and themes for light/dark/simple.
  - `core/constants/` and `core/utils/`: App-wide constants and helpers (e.g., validators).

- UI composition
  - `screens/`
    - `home_screen.dart`: Primary scaffold with gradient background, `PageView`-backed bottom navigation (Chats, AI Assistant, Settings). Hooks into `themeProvider` and `authProvider` actions.
    - `ai_chat_screen.dart`: Full AI chat experience: header with provider switcher, scrolling message list, composer with error surface and clear-chat; delegates to `aiProvider` for actions.
    - `chat_screen.dart`: Demonstrative chat UI and interaction patterns (message bubble list, composer, menus) to be wired to `chatProvider`.
    - Additional screens: auth, splash, profile setup, simple auth.
  - `widgets/`: Reusable UI (message bubble, text field, buttons, glassmorphic container, animated background) leveraging `flutter_animate` and custom styling.

## Notes for developing in this repo

- Linting is strict (see `analysis_options.yaml`); prefer running `flutter analyze` regularly; apply safe fixes with `dart fix --apply` when available.
- Web is the primary target per README; mobile/desktop build files are not included here.
- Use the `-t` flag to switch entrypoints when running locally (e.g., to try the simple flow).
