import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Register user with email/password
  Future<UserCredential?> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase registration error: ${e.message}');
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Registration error occurred',
      );
    }
  }

  // Login user with email/password
  Future<UserCredential?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase login error: ${e.message}');
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Authentication error occurred',
      );
    }
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in flow
        return null;
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credentials for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Google sign-in error: ${e.message}');
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Google sign-in error occurred',
      );
    } catch (e) {
      print('Unexpected Google sign-in error: $e');
      throw FirebaseAuthException(
        code: 'google_sign_in_error',
        message: 'An error occurred during Google sign-in',
      );
    }
  }

  // Sign out
  Future<void> logout() async {
    await _auth.signOut();
    // Also sign out from Google
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;
  
  // Stream for auth state changes
  Stream<User?> get authStateChange => _auth.authStateChanges();

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Firebase reset password error: ${e.message}');
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Password reset error occurred',
      );
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        if (displayName != null) await user.updateDisplayName(displayName);
        if (photoURL != null) await user.updatePhotoURL(photoURL);
        await user.reload();
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase update profile error: ${e.message}');
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Profile update error occurred',
      );
    }
  }

  // Delete user account
  Future<void> deleteUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase delete user error: ${e.message}');
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Account deletion error occurred',
      );
    }
  }

  // Get user ID
  String? get userId {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  // Get user email
  String? get userEmail {
    User? user = _auth.currentUser;
    return user?.email;
  }

  // Get user display name
  String? get userDisplayName {
    User? user = _auth.currentUser;
    return user?.displayName;
  }

  // Get user photo URL
  String? get userPhotoURL {
    User? user = _auth.currentUser;
    return user?.photoURL;
  }
}