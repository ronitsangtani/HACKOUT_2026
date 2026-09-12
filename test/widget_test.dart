import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecoloop/app/theme.dart';
import 'package:ecoloop/features/auth/screens/forgot_password_screen.dart';
import 'package:ecoloop/features/auth/screens/login_screen.dart';
import 'package:ecoloop/features/auth/screens/register_screen.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('LoginScreen Form Validation Tests', () {
    testWidgets('Renders all login inputs and links', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));

      expect(find.text('Welcome to EcoLoop'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('Validates empty email and password submission', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));

      // Tap Log In button without entering credentials
      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);
    });

    testWidgets('Validates invalid email format', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginScreen()));

      // Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'invalid-email',
      );

      // Enter password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address.'), findsOneWidget);
    });
  });

  group('RegisterScreen Form Validation Tests', () {
    testWidgets('Renders all registration inputs', (tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));

      expect(find.text('Join EcoLoop'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Create Account'), findsOneWidget);
    });

    testWidgets('Validates password mismatch', (tester) async {
      await tester.pumpWidget(createTestWidget(const RegisterScreen()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'Alex Green',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'alex@ecoloop.org',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secure123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'mismatch123',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('ForgotPasswordScreen Validation Tests', () {
    testWidgets('Renders forgot password form and validates email', (tester) async {
      await tester.pumpWidget(createTestWidget(const ForgotPasswordScreen()));

      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Send Reset Link'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });
  });
}
