import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/glassmorphic_container.dart';
import 'auth_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Profile',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Avatar
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.pigeonBlue,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // User Info Card
                      SizedBox(
                        width: double.infinity,
                        // Constrain the card height to avoid infinite constraints in scroll views
                        height: (MediaQuery.sizeOf(context).height * 0.35)
                            .clamp(220.0, 420.0)
                            .toDouble(),
                        child: GlassmorphicContainer(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 20,
                          blur: 20,
                          alignment: Alignment.bottomCenter,
                          border: 2,
                          gradientColors: [
                            AppTheme.glassBackground,
                            AppTheme.glassBackground.withValues(alpha: 0.1),
                          ],
                          borderGradientColors: [
                            AppTheme.glassBorder,
                            AppTheme.glassBorder.withValues(alpha: 0.1),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(
                                    context,
                                    Icons.email,
                                    'Email',
                                    user?.email ?? 'Not available',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    context,
                                    Icons.person,
                                    'User ID',
                                    user?.uid ?? 'Not available',
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    context,
                                    Icons.verified_user,
                                    'Email Verified',
                                    user?.emailVerified == true ? 'Yes' : 'No',
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Email verification coming soon',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      CustomButton(
                        text: 'Edit Profile',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                        icon: Icons.edit,
                        width: double.infinity,
                      ),

                      const SizedBox(height: 16),

                      CustomButton(
                        text: 'Sign Out',
                        onPressed: () {
                          _showSignOutDialog(context, ref);
                        },
                        icon: Icons.logout,
                        backgroundColor: AppTheme.pigeonRed,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                // Pop back to home and then navigate to auth screen
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (context) => const AuthScreen(),
                  ),
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
