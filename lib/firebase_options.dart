// File generated manually based on Firebase web app SDK config.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform. Only web is configured.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDBZ5GTGaAD_89kAElasOBLT7SLNUvoJX0',
    appId: '1:409382502517:web:6f94de861def12f565783c',
    messagingSenderId: '409382502517',
    projectId: 'pigeon--7',
    authDomain: 'pigeon--7.firebaseapp.com',
    storageBucket: 'pigeon--7.firebasestorage.app',
    measurementId: 'G-9RST1JS6Q4',
  );

}