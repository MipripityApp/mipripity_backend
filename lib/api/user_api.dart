import 'dart:convert';
import 'package:http/http.dart' as http;

class UserApi {
  static const String baseUrl = 'https://mipripity-api-1.onrender.com';

  // Register user
  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String whatsappLink,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'whatsapp_link': whatsappLink,
      }),
    );
    return {
      'success': response.statusCode == 200 || response.statusCode == 201,
      'body': jsonDecode(response.body),
      'statusCode': response.statusCode,
    };
  }

  // Login user
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return {
      'success': response.statusCode == 200,
      'body': jsonDecode(response.body),
      'statusCode': response.statusCode,
    };
  }

  // Google login
  static Future<Map<String, dynamic>> loginWithGoogle({
    String? idToken,
    String? accessToken,
    String? email,
    String? displayName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_token': idToken,
        'access_token': accessToken,
        'email': email,
        'display_name': displayName,
      }),
    );
    return {
      'success': response.statusCode == 200,
      'body': jsonDecode(response.body),
      'statusCode': response.statusCode,
    };
  }

  // Google register
  static Future<Map<String, dynamic>> registerWithGoogle({
    String? idToken,
    String? accessToken,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? whatsappLink,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google-register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_token': idToken,
        'access_token': accessToken,
        'email': email,
        'display_name': displayName,
        'phone_number': phoneNumber,
        'whatsapp_link': whatsappLink,
      }),
    );
    return {
      'success': response.statusCode == 200,
      'body': jsonDecode(response.body),
      'statusCode': response.statusCode,
    };
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
    if (response.statusCode == 200) {
      return {
        'success': true,
        'body': jsonDecode(response.body),
      };
    } else {
      return {
        'success': false,
        'body': jsonDecode(response.body),
        'statusCode': response.statusCode,
      };
    }
  }
}