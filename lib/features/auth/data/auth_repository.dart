import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Repository handling all Firebase Authentication and Firestore user profile operations.
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently authenticated Firebase user.
  User? get currentUser => _auth.currentUser;

  /// Register a new user with email, password, and full name.
  /// Creates the auth record in Firebase Auth and the user document in Firestore.
  Future<UserModel> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Registration succeeded, but failed to retrieve user account.');
      }

      // Update Firebase Auth profile display name
      await user.updateDisplayName(name.trim());

      // Create Firestore user document in users/{uid}
      final userModel = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseErrorMessage(e));
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseErrorMessage(e));
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Send password reset link to user email.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseErrorMessage(e));
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw AuthFailure('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign out current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseErrorMessage(e));
    } catch (e) {
      throw AuthFailure('Failed to sign out: ${e.toString()}');
    }
  }

  /// Retrieve the Firestore profile document for a user.
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Translates Firebase Auth error codes into beginner-friendly messages.
  static String _mapFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in Firebase Console.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An authentication error occurred. Please try again.';
    }
  }
}

/// Custom failure object for authentication errors.
class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);

  @override
  String toString() => message;
}
