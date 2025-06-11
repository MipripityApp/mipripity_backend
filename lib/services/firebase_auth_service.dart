import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<Map<String, dynamic>?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? whatsappLink,
  }) async {
    try {
      // Create user with Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName('$firstName $lastName');

        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'whatsappLink': whatsappLink ?? 'https://wa.me/${phoneNumber.replaceAll(RegExp(r'[^0-9]'), '')}',
          'displayName': '$firstName $lastName',
          'photoURL': user.photoURL,
          'userType': 'regular',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return {
          'uid': user.uid,
          'email': user.email,
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'whatsappLink': whatsappLink,
          'displayName': '$firstName $lastName',
          'photoURL': user.photoURL,
          'userType': 'regular',
          'isActive': true,
        };
      }
      return {'error': 'Failed to create user'};
    } on FirebaseAuthException catch (e) {
      return {'error': _getFirebaseAuthErrorMessage(e.code)};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Get user data from Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          
          // Update last login
          await _firestore.collection('users').doc(user.uid).update({
            'lastLoginAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          return {
            'uid': user.uid,
            'email': user.email,
            'firstName': userData['firstName'],
            'lastName': userData['lastName'],
            'phoneNumber': userData['phoneNumber'],
            'whatsappLink': userData['whatsappLink'],
            'displayName': userData['displayName'],
            'photoURL': user.photoURL,
            'userType': userData['userType'] ?? 'regular',
            'isActive': userData['isActive'] ?? true,
          };
        } else {
          // Create user document if it doesn't exist (for existing Firebase users)
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'firstName': user.displayName?.split(' ').first ?? '',
            'lastName': user.displayName?.split(' ').skip(1).join(' ') ?? '',
            'phoneNumber': user.phoneNumber ?? '',
            'whatsappLink': '',
            'displayName': user.displayName ?? '',
            'photoURL': user.photoURL,
            'userType': 'regular',
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          return {
            'uid': user.uid,
            'email': user.email,
            'firstName': user.displayName?.split(' ').first ?? '',
            'lastName': user.displayName?.split(' ').skip(1).join(' ') ?? '',
            'phoneNumber': user.phoneNumber ?? '',
            'whatsappLink': '',
            'displayName': user.displayName ?? '',
            'photoURL': user.photoURL,
            'userType': 'regular',
            'isActive': true,
          };
        }
      }
      return {'error': 'Failed to sign in'};
    } on FirebaseAuthException catch (e) {
      return {'error': _getFirebaseAuthErrorMessage(e.code)};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Sign in with Google (handles both sign-in and sign-up)
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'error': 'Google sign in was cancelled'};
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        // Check if this is a new user (sign-up) or existing user (sign-in)
        bool isNewUser = result.additionalUserInfo?.isNewUser ?? false;
        
        // Check if user document exists
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists || isNewUser) {
          // Create user document for new Google users
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'firstName': user.displayName?.split(' ').first ?? '',
            'lastName': user.displayName?.split(' ').skip(1).join(' ') ?? '',
            'phoneNumber': user.phoneNumber ?? '',
            'whatsappLink': '',
            'displayName': user.displayName ?? '',
            'photoURL': user.photoURL,
            'userType': 'regular',
            'isActive': true,
            'signUpMethod': 'google',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Update last login for existing users
          await _firestore.collection('users').doc(user.uid).update({
            'lastLoginAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        // Get the latest user data
        DocumentSnapshot updatedUserDoc = await _firestore.collection('users').doc(user.uid).get();
        Map<String, dynamic> userData = updatedUserDoc.data() as Map<String, dynamic>;

        return {
          'uid': user.uid,
          'email': user.email,
          'firstName': userData['firstName'],
          'lastName': userData['lastName'],
          'phoneNumber': userData['phoneNumber'],
          'whatsappLink': userData['whatsappLink'],
          'displayName': userData['displayName'],
          'photoURL': user.photoURL,
          'userType': userData['userType'] ?? 'regular',
          'isActive': userData['isActive'] ?? true,
          'isNewUser': isNewUser,
        };
      }
      return {'error': 'Failed to sign in with Google'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Sign up with Google (specifically for registration flow)
  Future<Map<String, dynamic>?> signUpWithGoogle({
    String? phoneNumber,
    String? whatsappLink,
  }) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'error': 'Google sign up was cancelled'};
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        // Check if user document exists
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists) {
          // Create user document for new Google users with additional info
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'firstName': user.displayName?.split(' ').first ?? '',
            'lastName': user.displayName?.split(' ').skip(1).join(' ') ?? '',
            'phoneNumber': phoneNumber ?? user.phoneNumber ?? '',
            'whatsappLink': whatsappLink ?? (phoneNumber != null ? 'https://wa.me/${phoneNumber.replaceAll(RegExp(r'[^0-9]'), '')}' : ''),
            'displayName': user.displayName ?? '',
            'photoURL': user.photoURL,
            'userType': 'regular',
            'isActive': true,
            'signUpMethod': 'google',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          return {
            'uid': user.uid,
            'email': user.email,
            'firstName': user.displayName?.split(' ').first ?? '',
            'lastName': user.displayName?.split(' ').skip(1).join(' ') ?? '',
            'phoneNumber': phoneNumber ?? user.phoneNumber ?? '',
            'whatsappLink': whatsappLink ?? '',
            'displayName': user.displayName ?? '',
            'photoURL': user.photoURL,
            'userType': 'regular',
            'isActive': true,
            'isNewUser': true,
          };
        } else {
          // User already exists, just sign them in
          await _firestore.collection('users').doc(user.uid).update({
            'lastLoginAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          return {
            'uid': user.uid,
            'email': user.email,
            'firstName': userData['firstName'],
            'lastName': userData['lastName'],
            'phoneNumber': userData['phoneNumber'],
            'whatsappLink': userData['whatsappLink'],
            'displayName': userData['displayName'],
            'photoURL': user.photoURL,
            'userType': userData['userType'] ?? 'regular',
            'isActive': userData['isActive'] ?? true,
            'isNewUser': false,
          };
        }
      }
      return {'error': 'Failed to sign up with Google'};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {'success': true, 'message': 'Password reset email sent'};
    } on FirebaseAuthException catch (e) {
      return {'error': _getFirebaseAuthErrorMessage(e.code)};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user data in Firestore
  Future<bool> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
      return true;
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }

  // Helper method to get user-friendly error messages
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Signing in with Email and Password is not enabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
