import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_models;
import '../services/firebase_auth_service.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  User? _firebaseUser;
  app_models.User? _appUser;
  bool _isLoading = false;
  String? _error;

  UserProvider() {
    // Listen to Firebase auth state changes and update user accordingly
    _authService.authStateChange.listen((user) {
      _firebaseUser = user;
      if (_firebaseUser != null && _appUser == null) {
        _createAppUserFromFirebase();
      }
      notifyListeners();
    });
    // Initialize user on provider creation
    _firebaseUser = _authService.currentUser;
    _loadUserFromPrefs();
  }

  // Load user data from shared preferences
  Future<void> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        final Map<String, dynamic> userMap = jsonDecode(userData);
        _appUser = app_models.User.fromJson(userMap);
        notifyListeners();
      } else if (_firebaseUser != null) {
        await _createAppUserFromFirebase();
      }
    } catch (e) {
      print('Error loading user from preferences: $e');
    }
  }

  // Save user data to shared preferences
  Future<void> _saveUserToPrefs(app_models.User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));
    } catch (e) {
      print('Error saving user to preferences: $e');
    }
  }

  // Clear user data from shared preferences
  Future<void> _clearUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
    } catch (e) {
      print('Error clearing user from preferences: $e');
    }
  }

  // Create app user from Firebase user data
  Future<void> _createAppUserFromFirebase() async {
    if (_firebaseUser == null) return;

    try {
      final userEmail = _firebaseUser!.email;
      if (userEmail == null) return;

      // Firebase displayName may contain both first and last name
      final displayName = _firebaseUser!.displayName ?? '';
      final names = displayName.split(' ');
      final firstName = names.isNotEmpty ? names.first : '';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
      final phoneNumber = _firebaseUser!.phoneNumber ?? '';
      // If you store whatsappLink elsewhere, fetch it here (e.g., from Firestore)

      // Use the Firebase user's unique ID as the app user ID (hashCode fallback for int)
      final userId = _firebaseUser!.uid.hashCode.abs();

      _appUser = app_models.User(
        id: userId,
        email: userEmail,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        whatsappLink: '', // Set if you store it elsewhere
      );

      await _saveUserToPrefs(_appUser!);
      notifyListeners();
    } catch (e) {
      print('Error creating app user from Firebase metadata: $e');
    }
  }

  // Getters
  User? get user => _firebaseUser;
  app_models.User? get appUser => _appUser;
  bool get isLoggedIn => _appUser != null || _firebaseUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _authService.loginUser(
        email: email,
        password: password,
      );
      _firebaseUser = userCredential?.user;
      await _createAppUserFromFirebase();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        _error = 'Invalid email or password. Please try again.';
      } else if (e.code == 'network-request-failed') {
        _error = 'Network error. Please check your internet connection and try again.';
      } else {
        _error = e.message ?? 'Authentication failed. Please try again.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Authentication failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login with Google
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signInWithGoogle();
      
      // User canceled the sign-in
      if (userCredential == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      _firebaseUser = userCredential.user;
      await _createAppUserFromFirebase();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Google sign-in failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Google sign-in failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register with email and password
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String whatsappLink,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _authService.registerUser(
        email: email,
        password: password,
      );
      _firebaseUser = userCredential?.user;

      // Update display name
      await _authService.updateUserProfile(
        displayName: '$firstName $lastName',
      );
      
      // Optionally, update phone number and whatsappLink in Firestore

      if (_firebaseUser != null) {
        final userId = _firebaseUser!.uid.hashCode.abs();
        _appUser = app_models.User(
          id: userId,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          whatsappLink: whatsappLink,
        );
        await _saveUserToPrefs(_appUser!);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _error = 'This email is already registered. Please try signing in instead.';
      } else if (e.code == 'network-request-failed') {
        _error = 'Network error. Please check your internet connection and try again.';
      } else if (e.code == 'weak-password') {
        _error = 'Password is too weak. Please use a stronger password.';
      } else {
        _error = e.message ?? 'Registration failed. Please try again.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _appUser = null;
    await _clearUserFromPrefs();

    try {
      await _authService.logout();
      _firebaseUser = null;
    } catch (e) {
      print('Firebase sign-out error: $e');
    }
    notifyListeners();
  }

  app_models.User? getCurrentUser() {
    return _appUser;
  }

  bool isAuthenticated() {
    return _appUser != null || _authService.isAuthenticated;
  }

  Stream<User?> get authStateChange {
    return _authService.authStateChange;
  }
}