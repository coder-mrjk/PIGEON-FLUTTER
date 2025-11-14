import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isProfileComplete;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isProfileComplete = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isProfileComplete,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<User?>? _authSub;

  @override
  AuthState build() {
    ref.onDispose(() {
      _authSub?.cancel();
    });
    _init();
    return const AuthState();
  }

  Future<void> _init() async {
    _authSub?.cancel();
    _authSub = _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        final isProfileComplete = await _checkProfileComplete(user.uid);
        state = state.copyWith(
          user: user,
          isProfileComplete: isProfileComplete,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          user: null,
          isProfileComplete: false,
          isLoading: false,
        );
      }
    });
  }

  Future<bool> _checkProfileComplete(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists && doc.data()?['displayName'] != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e.code));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e.code));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      try {
        await _auth.signInWithPopup(GoogleAuthProvider());
      } on UnsupportedError {
        await _auth.signInWithProvider(GoogleAuthProvider());
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Google sign-in failed');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      state = state.copyWith(error: 'Sign out failed');
    }
  }

  Future<void> completeProfile(String displayName, String bio) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = _auth.currentUser;
      if (user == null) return;

      // Validate inputs
      final trimmedName = displayName.trim();
      final trimmedBio = bio.trim();
      
      if (trimmedName.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Display name cannot be empty',
        );
        return;
      }
      
      if (trimmedName.length < 2) {
        state = state.copyWith(
          isLoading: false,
          error: 'Display name must be at least 2 characters',
        );
        return;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'displayName': trimmedName,
        'bio': trimmedBio,
        'email': user.email,
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });

      state = state.copyWith(isLoading: false, isProfileComplete: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to complete profile',
      );
    }
  }

  Future<void> updateProfile({String? displayName, String? bio}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final user = _auth.currentUser;
      if (user == null) return;

      final data = <String, dynamic>{};
      if (displayName != null) data['displayName'] = displayName;
      if (bio != null) data['bio'] = bio;
      data['lastSeen'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(user.uid).update(data);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile',
      );
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters)';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'requires-recent-login':
        return 'Please sign in again to continue';
      case 'account-exists-with-different-credential':
        return 'Account exists with different sign-in method';
      default:
        return 'Authentication failed: $errorCode';
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
