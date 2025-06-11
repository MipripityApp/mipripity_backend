import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _baseUrl = 'https://square-moon-79559388.neon.tech';
  static const String _apiKey = 'napi_ey0x7whnbwh6024joqs9d81tptipkqb1v7kuscv3vv1bnts2gg7mt27nnngh083h';
  
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
  };

  // Get current user ID from shared preferences
  Future<int?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('user_id');
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  // Save user ID to shared preferences
  Future<void> saveCurrentUserId(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', userId);
    } catch (e) {
      print('Error saving current user ID: $e');
    }
  }

  // Create a new user
  Future<Map<String, dynamic>?> createUser({
    required String email,
    required String passwordHash,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? whatsappLink,
    String? avatarUrl,
    String userType = 'regular',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/users'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password_hash': passwordHash,
          'first_name': firstName,
          'last_name': lastName,
          'full_name': '$firstName $lastName',
          'phone_number': phoneNumber,
          'whatsapp_link': whatsappLink,
          'avatar_url': avatarUrl,
          'user_type': userType,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Error creating user: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception creating user: $e');
      return null;
    }
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users?email=$email'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        return users.isNotEmpty ? users.first : null;
      } else {
        print('Error getting user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception getting user: $e');
      return null;
    }
  }

  // For demo purposes, create a default user if none exists
  Future<int> getOrCreateDefaultUser() async {
    try {
      // Try to get existing user
      final existingUser = await getUserByEmail('demo@mipripity.com');
      if (existingUser != null) {
        final userId = existingUser['id'] as int;
        await saveCurrentUserId(userId);
        return userId;
      }

      // Create default user
      final newUser = await createUser(
        email: 'demo@mipripity.com',
        passwordHash: 'demo_hash', // In real app, use proper password hashing
        firstName: 'Demo',
        lastName: 'User',
        phoneNumber: '+2348000000000',
        whatsappLink: 'https://wa.me/2348000000000',
        userType: 'regular',
      );

      if (newUser != null) {
        final userId = newUser['id'] as int;
        await saveCurrentUserId(userId);
        return userId;
      }

      // Fallback to ID 1 if creation fails
      await saveCurrentUserId(1);
      return 1;
    } catch (e) {
      print('Exception getting or creating default user: $e');
      // Fallback to ID 1
      await saveCurrentUserId(1);
      return 1;
    }
  }
}
