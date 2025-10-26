import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../core/providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  // Logo and Title
                  _buildHeader(context),

                  const SizedBox(height: 48),

                  // Auth Form
                  _buildAuthForm(context, authState),

                  const SizedBox(height: 32),

                  // Google Sign In
                  _buildGoogleSignIn(context, authState),

                  const SizedBox(height: 24),

                  // Footer
                  _buildFooter(context),
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
          child: const Icon(Icons.flight, size: 50, color: AppTheme.pigeonBlue),
        ).animate().scale(duration: 1.seconds, curve: Curves.elasticOut),

        const SizedBox(height: 24),

        Text(
          'PIGEON',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ).animate().fadeIn(duration: 1.seconds, delay: 300.ms),

        const SizedBox(height: 8),

        Text(
          'Premium Chat Experience',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(duration: 1.seconds, delay: 600.ms),
      ],
    );
  }

  Widget _buildAuthForm(BuildContext context, AuthState authState) {
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
              // Form Title
              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 200.ms),

              const SizedBox(height: 32),

              // Email Field
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ).animate().slideX(
                begin: -0.3,
                end: 0,
                duration: 600.ms,
                delay: 400.ms,
              ),

              const SizedBox(height: 16),

              // Password Field
              CustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (!_isLogin && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ).animate().slideX(
                begin: 0.3,
                end: 0,
                duration: 600.ms,
                delay: 500.ms,
              ),

              const SizedBox(height: 24),

              // Submit Button
              CustomButton(
                text: _isLogin ? 'Sign In' : 'Sign Up',
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

              // Toggle Login/Signup
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Sign In",
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

  Widget _buildGoogleSignIn(BuildContext context, AuthState authState) {
    return CustomButton(
      text: 'Continue with Google',
      onPressed: authState.isLoading
          ? null
          : () {
              ref.read(authProvider.notifier).signInWithGoogle();
            },
      icon: Icons.g_mobiledata,
      backgroundColor: Colors.white,
      textColor: AppTheme.pigeonBlue,
      width: double.infinity,
    ).animate().slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 800.ms);
  }

  Widget _buildFooter(BuildContext context) {
    return Text(
      'For password reset, please contact support',
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.7)),
      textAlign: TextAlign.center,
    ).animate().fadeIn(duration: 600.ms, delay: 1.seconds);
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_isLogin) {
        ref
            .read(authProvider.notifier)
            .signInWithEmail(
              _emailController.text.trim(),
              _passwordController.text,
            );
      } else {
        ref
            .read(authProvider.notifier)
            .signUpWithEmail(
              _emailController.text.trim(),
              _passwordController.text,
            );
      }
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
