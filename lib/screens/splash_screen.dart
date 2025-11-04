import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:glassmorphism/glassmorphism.dart';

import '../core/providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/asset_utils.dart';
import '../widgets/animated_background.dart';
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
      if (!context.mounted) return;
      if (!authState.isLoading) {
        if (authState.user == null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (context) => const AuthScreen()),
          );
        } else if (!authState.isProfileComplete) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
                builder: (context) => const ProfileSetupScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (context) => const HomeScreen()),
          );
        }
      }
    });

    return Scaffold(
      body: AnimatedBackground(
        colors: const [
          AppTheme.pigeonBlue,
          AppTheme.pigeonAccent,
          AppTheme.pigeonPurple,
        ],
        duration: const Duration(seconds: 12),
        showParticles: true,
        brandLightAsset: 'assets/branding/backgrounds/light.png',
        brandDarkAsset: 'assets/branding/backgrounds/dark.png',
        brandOverlayOpacity: 0.08,
        child: Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand Logo
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _BrandLogo(),
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
                        color: Colors.white.withValues(alpha: 0.9),
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

class _BrandLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AssetUtils.firstExisting(const [
        'assets/branding/logo/pigeon_logo.png',
        'assets/branding/logo/pigeon_logo.jpg',
      ]),
      builder: (context, snapshot) {
        final path = snapshot.data;
        if (path != null) {
          return Image.asset(path, fit: BoxFit.contain);
        }
        return Center(
          child: Icon(
            Icons.flight,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}
