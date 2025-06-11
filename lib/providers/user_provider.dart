import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  
  Map<String, dynamic>? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserProvider() {
    _initializeAuthState();
  }

  // Initialize authentication state
  void _initializeAuthState() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        // User is signed in, get user data from Firestore
        final userData = await _authService.getUserData(user.uid);
        if (userData != null) {
          _user = userData;
          _user!['uid'] = user.uid;
          _user!['email'] = user.email;
          _user!['photoURL'] = user.photoURL;
          _isLoggedIn = true;
        }
      } else {
        // User is signed out
        _user = null;
        _isLoggedIn = false;
      }
      notifyListeners();
    });
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Register with email and password
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? whatsappLink,
  }) async {
    setLoading(true);
    clearError();

    try {
      final result = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        whatsappLink: whatsappLink,
      );

      if (result != null && result['error'] == null) {
        _user = result;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        setError(result?['error'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      setError('An error occurred during registration: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    setLoading(true);
    clearError();

    try {
      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result != null && result['error'] == null) {
        _user = result;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        setError(result?['error'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      setError('An error occurred during login: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Login with Google
  Future<bool> loginWithGoogle() async {
    setLoading(true);
    clearError();

    try {
      final result = await _authService.signInWithGoogle();

      if (result != null && result['error'] == null) {
        _user = result;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        setError(result?['error'] ?? 'Google login failed');
        return false;
      }
    } catch (e) {
      setError('An error occurred during Google login: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Register with Google
  Future<bool> registerWithGoogle({
    String? phoneNumber,
    String? whatsappLink,
  }) async {
    setLoading(true);
    clearError();

    try {
      final result = await _authService.signUpWithGoogle(
        phoneNumber: phoneNumber,
        whatsappLink: whatsappLink,
      );

      if (result != null && result['error'] == null) {
        _user = result;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        setError(result?['error'] ?? 'Google sign up failed');
        return false;
      }
    } catch (e) {
      setError('An error occurred during Google sign up: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    setLoading(true);
    clearError();

    try {
      final result = await _authService.resetPassword(email);

      if (result['error'] == null) {
        return true;
      } else {
        setError(result['error']);
        return false;
      }
    } catch (e) {
      setError('An error occurred: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Update user data
  Future<bool> updateUserData(Map<String, dynamic> data) async {
    if (_user == null) return false;

    setLoading(true);
    clearError();

    try {
      final success = await _authService.updateUserData(_user!['uid'], data);
      
      if (success) {
        // Update local user data
        _user = {..._user!, ...data};
        notifyListeners();
        return true;
      } else {
        setError('Failed to update user data');
        return false;
      }
    } catch (e) {
      setError('An error occurred while updating: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    setLoading(true);
    
    try {
      await _authService.signOut();
      _user = null;
      _isLoggedIn = false;
      clearError();
      notifyListeners();
    } catch (e) {
      setError('Error signing out: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }
}
