import 'package:flutter/foundation.dart';
import 'package:mipripity/api/user_api.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  
  Map<String, dynamic>? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get user ID
  int? get userId => _user?['id'];
  String? get userEmail => _user?['email'];
  String? get userFullName => _user?['firstName'] != null && _user?['lastName'] != null 
      ? '${_user!['firstName']} ${_user!['lastName']}' 
      : null;

  UserProvider() {
    _initializeAuthState();
  }

  // Initialize authentication state
  Future<void> _initializeAuthState() async {
    setLoading(true);
    
    try {
      // Check if user is already authenticated
      final isAuth = await _userService.isAuthenticated();
      
      if (isAuth) {
        // Get current user profile
        final userData = await _userService.getCurrentUserProfile();
        if (userData != null) {
          _user = userData;
          _isLoggedIn = true;
        } else {
          // Clear session if user data can't be retrieved
          await _userService.clearUserSession();
          _user = null;
          _isLoggedIn = false;
        }
      } else {
        _user = null;
        _isLoggedIn = false;
      }
    } catch (e) {
      print('Error initializing auth state: $e');
      _user = null;
      _isLoggedIn = false;
    } finally {
      setLoading(false);
    }
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
    required String whatsappLink,
  }) async {
    setLoading(true);
    setError(null);
    notifyListeners();

    final result = await UserApi.registerUser(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      whatsappLink: whatsappLink,
    );

    setLoading(false);
    if (result['success']) {
      // Optionally store user info from result['body']
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } else {
      setError(result['body']['error'] ?? 'Registration failed');
      return false;
    }
  }

  // Login with email and password
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    setLoading(true);
    setError(null);
    notifyListeners();

    final result = await UserApi.loginUser(
      email: email,
      password: password,
    );

    setLoading(false);
    if (result['success']) {
      // Optionally store user info/token from result['body']
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } else {
      setError(result['body']['error'] ?? 'Login failed');
      notifyListeners();
      return false;
    }
  }

  // Login with Google (placeholder - you'll need to implement Google OAuth)
  Future<bool> loginWithGoogle() async {
    setLoading(true);
    clearError();

    try {
      // TODO: Implement Google OAuth flow
      // This would typically involve:
      // 1. Google Sign In to get OAuth token
      // 2. Send token to your backend for verification
      // 3. Backend returns user data and JWT token
      
      setError('Google login not yet implemented');
      return false;
    } catch (e) {
      setError('An error occurred during Google login: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Register with Google (placeholder)
  Future<bool> registerWithGoogle({
    String? phoneNumber,
    String? whatsappLink,
  }) async {
    setLoading(true);
    clearError();

    try {
      // TODO: Implement Google OAuth registration
      setError('Google registration not yet implemented');
      return false;
    } catch (e) {
      setError('An error occurred during Google sign up: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Reset password (placeholder - depends on your backend implementation)
  Future<bool> resetPassword(String email) async {
    setLoading(true);
    clearError();

    try {
      // TODO: Implement password reset with your backend
      // This would typically send a reset email or SMS
      
      setError('Password reset not yet implemented');
      return false;
    } catch (e) {
      setError('An error occurred: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Update user data
  Future<bool> updateUserData(Map<String, dynamic> data) async {
    if (_user == null || userId == null) return false;

    setLoading(true);
    clearError();

    try {
      final updatedUser = await _userService.updateUserProfile(
        userId: userId!,
        firstName: data['firstName'],
        lastName: data['lastName'],
        phoneNumber: data['phoneNumber'],
        whatsappLink: data['whatsappLink'],
        avatarUrl: data['avatarUrl'],
      );
      
      if (updatedUser != null) {
        // Update local user data
        _user = {..._user!, ...updatedUser};
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

  // Update specific user fields
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? whatsappLink,
    String? avatarUrl,
  }) async {
    if (_user == null || userId == null) return false;

    setLoading(true);
    clearError();

    try {
      final updatedUser = await _userService.updateUserProfile(
        userId: userId!,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        whatsappLink: whatsappLink,
        avatarUrl: avatarUrl,
      );
      
      if (updatedUser != null) {
        // Update local user data
        _user = {..._user!, ...updatedUser};
        notifyListeners();
        return true;
      } else {
        setError('Failed to update profile');
        return false;
      }
    } catch (e) {
      setError('An error occurred while updating profile: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Refresh user data
  Future<bool> refreshUserData() async {
    if (!_isLoggedIn) return false;

    setLoading(true);
    clearError();

    try {
      final userData = await _userService.getCurrentUserProfile();
      
      if (userData != null) {
        _user = userData;
        notifyListeners();
        return true;
      } else {
        setError('Failed to refresh user data');
        return false;
      }
    } catch (e) {
      setError('An error occurred while refreshing: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    setLoading(true);
    
    try {
      await _userService.logoutUser();
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

  // Check authentication status
  Future<bool> checkAuthStatus() async {
    try {
      return await _userService.isAuthenticated();
    } catch (e) {
      print('Error checking auth status: $e');
      return false;
    }
  }

  // Get or create default user (for demo purposes)
  Future<bool> initializeDefaultUser() async {
    setLoading(true);
    clearError();

    try {
      final userId = await _userService.getOrCreateDefaultUser();
      
      if (userId > 0) {
        final userData = await _userService.getUserById(userId);
        
        if (userData != null) {
          _user = userData;
          _isLoggedIn = true;
          notifyListeners();
          return true;
        }
      }
      
      setError('Failed to initialize default user');
      return false;
    } catch (e) {
      setError('An error occurred while initializing: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Helper method to check if user has complete profile
  bool get hasCompleteProfile {
    if (_user == null) return false;
    
    return _user!['firstName'] != null &&
           _user!['lastName'] != null &&
           _user!['phoneNumber'] != null &&
           _user!['email'] != null;
  }

  // Helper method to get user initials
  String get userInitials {
    if (_user == null) return '';
    
    final firstName = _user!['firstName'] ?? '';
    final lastName = _user!['lastName'] ?? '';
    
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0].toUpperCase();
    if (lastName.isNotEmpty) initials += lastName[0].toUpperCase();
    
    return initials.isNotEmpty ? initials : 'U';
  }

  // Helper method to get display name
  String get displayName {
    if (_user == null) return 'User';
    
    final firstName = _user!['firstName'] ?? '';
    final lastName = _user!['lastName'] ?? '';
    
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (firstName.isNotEmpty) {
      return firstName;
    } else if (_user!['email'] != null) {
      return _user!['email'].toString().split('@').first;
    }
    
    return 'User';
  }
}