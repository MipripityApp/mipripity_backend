import 'dart:convert';
import 'package:http/http.dart' as http;

class PropertyApi {
  static const String baseUrl = 'https://mipripity-api-1.onrender.com';

  static Future<List<dynamic>> getResidentialProperties() async {
    final response = await http.get(Uri.parse('$baseUrl/properties/residential'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch properties');
    }
  }

  static Future<bool> createResidentialProperty(Map<String, dynamic> propertyData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/properties'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(propertyData),
    );
    return response.statusCode == 200;
  }
}