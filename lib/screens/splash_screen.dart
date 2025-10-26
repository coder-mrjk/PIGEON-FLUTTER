import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:glassmorphism/glassmorphism.dart';

import '../core/providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'profile_setup_screen.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Navigate based on auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!authState.isLoading) {
        if (authState.user == null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthScreen()),
          );
        } else if (!authState.isProfileComplete) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.pigeonBlue,
              AppTheme.pigeonAccent,
              AppTheme.pigeonPurple,
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pigeon Logo/Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.flight,
                    size: 40,
                    color: AppTheme.pigeonBlue,
                  ),
                ).animate().scale(
                      duration: 1.seconds,
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 24),

                // App Name
                Text(
                  'PIGEON',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                ).animate().fadeIn(duration: 1.seconds, delay: 500.ms).slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 1.seconds,
                      delay: 500.ms,
                    ),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Premium Chat Experience',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                ).animate().fadeIn(duration: 1.seconds, delay: 1.seconds),

                const SizedBox(height: 40),

                // Loading indicator
                if (authState.isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ).animate().fadeIn(duration: 500.ms, delay: 1.5.seconds),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
