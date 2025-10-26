import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/simple_theme.dart';
import 'core/providers/theme_provider.dart';
import 'screens/simple_auth_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: PigeonApp()));
}

class PigeonApp extends ConsumerWidget {
  const PigeonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Pigeon - Premium Chat',
      debugShowCheckedModeBanner: false,
      theme: SimpleTheme.lightTheme,
      darkTheme: SimpleTheme.darkTheme,
      themeMode: themeMode,
      home: const SimpleAuthScreen(),
    );
  }
}
