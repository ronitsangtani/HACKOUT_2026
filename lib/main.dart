import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the official FlutterFire options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Graceful fallback for local development before running `flutterfire configure`
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(
    const ProviderScope(
      child: EcoLoopApp(),
    ),
  );
}
