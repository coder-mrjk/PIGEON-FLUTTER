import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glassmorphic_container.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loadingProfile = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? {};
      _displayNameController.text = (data['displayName'] ?? '').toString();
      _bioController.text = (data['bio'] ?? '').toString();
    } catch (_) {
      // ignore: avoid_print
      print('Failed to load profile');
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildForm(context, authState),
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
          width: 90,
          height: 90,
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
          child: const Icon(Icons.edit, size: 44, color: AppTheme.pigeonBlue),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Update your name and bio. Your bio tells your story! ✨',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, AuthState authState) {
    final boxHeight = (MediaQuery.sizeOf(context).height * 0.7)
        .clamp(360.0, 560.0)
        .toDouble();

    if (_loadingProfile) {
      return SizedBox(
        width: double.infinity,
        height: boxHeight,
        child: const Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: boxHeight,
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: _displayNameController,
                    hintText: 'Display Name',
                    prefixIcon: Icons.person_outline,
                    autofillHints: const [AutofillHints.name],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your display name';
                      }
                      if (value.trim().length < 2) {
                        return 'Display name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Save Changes',
                          isLoading: authState.isLoading,
                          onPressed: authState.isLoading ? null : _handleSave,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Cancel',
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).updateProfile(
            displayName: _displayNameController.text.trim(),
            bio: _bioController.text.trim(),
          );
      if (!mounted) return;
      final error = ref.read(authProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profile updated')));
        Navigator.of(context).pop();
      }
    }
  }
}
