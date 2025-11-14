import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

bool _firebaseReady = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    ui.channelBuffers.allowOverflow('flutter/lifecycle', true);
  }
  // Load .env (optional). If missing, proceed silently.
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {}
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    _firebaseReady = false;
  }
  runApp(const ProviderScope(child: PigeonApp()));
}

class PigeonApp extends ConsumerWidget {
  const PigeonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Pigeon - Premium Chat App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home:
          _firebaseReady ? const SplashScreen() : const _FirebaseConfigScreen(),
    );
  }
}

class _FirebaseConfigScreen extends StatelessWidget {
  const _FirebaseConfigScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.error, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Firebase not configured',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Run the following commands to generate lib/firebase_options.dart:',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const SelectableText(
                  'dart pub global activate flutterfire_cli\nflutterfire configure',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'After configuration, restart the app.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
