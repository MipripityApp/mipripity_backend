import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class UserApi {
  // Use the central API configuration
  static String get baseUrl => ApiConfig.getBaseUrl();

  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  static Future<bool> addUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    return response.statusCode == 200;
  }
}