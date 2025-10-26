import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../core/providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Show error dialog if there's an error
    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context, authState.error!);
        ref.read(authProvider.notifier).state = authState.copyWith(error: null);
      });
    }

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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  _buildHeader(context),

                  const SizedBox(height: 48),

                  // Profile Form
                  _buildProfileForm(context, authState),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add,
            size: 50,
            color: AppTheme.pigeonBlue,
          ),
        ).animate().scale(duration: 1.seconds, curve: Curves.elasticOut),

        const SizedBox(height: 24),

        Text(
          'Complete Your Profile',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 1.seconds, delay: 300.ms),

        const SizedBox(height: 8),

        Text(
          'Tell us a bit about yourself',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(duration: 1.seconds, delay: 600.ms),
      ],
    );
  }

  Widget _buildProfileForm(BuildContext context, AuthState authState) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 400,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.bottomCenter,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.glassBackground,
          AppTheme.glassBackground.withOpacity(0.1),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppTheme.glassBorder, AppTheme.glassBorder.withOpacity(0.1)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Display Name Field
              CustomTextField(
                controller: _displayNameController,
                hintText: 'Display Name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your display name';
                  }
                  if (value.trim().length < 2) {
                    return 'Display name must be at least 2 characters';
                  }
                  return null;
                },
              ).animate().slideX(
                begin: -0.3,
                end: 0,
                duration: 600.ms,
                delay: 200.ms,
              ),

              const SizedBox(height: 16),

              // Bio Field
              CustomTextField(
                controller: _bioController,
                hintText: 'Bio (optional)',
                prefixIcon: Icons.info_outline,
                maxLines: 3,
                maxLength: 150,
                validator: (value) {
                  if (value != null && value.length > 150) {
                    return 'Bio must be under 150 characters';
                  }
                  return null;
                },
              ).animate().slideX(
                begin: 0.3,
                end: 0,
                duration: 600.ms,
                delay: 400.ms,
              ),

              const SizedBox(height: 32),

              // Complete Profile Button
              CustomButton(
                text: 'Complete Profile',
                onPressed: authState.isLoading ? null : _handleSubmit,
                isLoading: authState.isLoading,
                width: double.infinity,
              ).animate().slideY(
                begin: 0.3,
                end: 0,
                duration: 600.ms,
                delay: 600.ms,
              ),

              const SizedBox(height: 16),

              // Skip Button
              TextButton(
                onPressed: () {
                  // Skip profile setup and go to home
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
            ],
          ),
        ),
      ),
    ).animate().scale(duration: 800.ms, delay: 100.ms);
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(authProvider.notifier)
          .completeProfile(
            _displayNameController.text.trim(),
            _bioController.text.trim(),
          );
    }
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
