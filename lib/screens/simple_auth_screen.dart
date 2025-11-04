import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/auth_provider.dart';
import '../core/theme/simple_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SimpleAuthScreen extends ConsumerStatefulWidget {
  const SimpleAuthScreen({super.key});

  @override
  ConsumerState<SimpleAuthScreen> createState() => _SimpleAuthScreenState();
}

class _SimpleAuthScreenState extends ConsumerState<SimpleAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              SimpleTheme.pigeonBlue,
              SimpleTheme.pigeonPurple,
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 400,
            height: 500,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title
                    const Icon(
                      Icons.message,
                      size: 64,
                      color: Colors.white,
                    ).animate().scale(delay: 200.ms),

                    const SizedBox(height: 16),

                    Text(
                      'Pigeon',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 32),

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ).animate().slideX(delay: 600.ms),

                    const SizedBox(height: 16),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      autofillHints: _isLogin
                          ? const [AutofillHints.password]
                          : const [AutofillHints.newPassword],
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter your password';
                        }
                        if (value!.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ).animate().slideX(delay: 800.ms),

                    const SizedBox(height: 24),

                    // Auth Button
                    CustomButton(
                      text: _isLogin ? 'Sign In' : 'Sign Up',
                      onPressed: authState.isLoading ? null : _handleAuth,
                      isLoading: authState.isLoading,
                    ).animate().fadeIn(delay: 1000.ms),

                    const SizedBox(height: 16),

                    // Google Sign In
                    CustomButton(
                      text: 'Continue with Google',
                      onPressed:
                          authState.isLoading ? null : _handleGoogleSignIn,
                      backgroundColor: Colors.white,
                      textColor: SimpleTheme.pigeonBlue,
                      icon: Icons.login,
                    ).animate().fadeIn(delay: 1200.ms),

                    const SizedBox(height: 16),

                    // Toggle Auth Mode
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin
                            ? "Don't have an account? Sign up"
                            : "Already have an account? Sign in",
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ).animate().fadeIn(delay: 1400.ms),

                    // Error Message
                    if (authState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          authState.error!,
                          style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().shake(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isLogin) {
      await ref.read(authProvider.notifier).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
    } else {
      await ref.read(authProvider.notifier).signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  void _handleGoogleSignIn() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
  }
}
