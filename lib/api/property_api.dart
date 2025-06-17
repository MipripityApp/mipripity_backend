import 'dart:convert';
import 'package:http/http.dart' as http;

class PropertyApi {
  static const String baseUrl = 'https://mipripity-api-1.onrender.com';

  // Fetch residential properties from the backend
  static Future<List<Map<String, dynamic>>> getResidentialProperties() async {
    final response = await http.get(Uri.parse('$baseUrl/properties/residential'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Ensure each item is a Map<String, dynamic>
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch residential properties');
    }
  }

  // Fetch properties by category (residential, commercial, land, material, etc.)
  static Future<List<Map<String, dynamic>>> getPropertiesByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/properties/$category'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch $category properties');
    }
  }

  // Create a new residential property
  static Future<bool> createResidentialProperty(Map<String, dynamic> propertyData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/properties'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(propertyData),
    );
    return response.statusCode == 200;
  }
  // Fetch property details by ID
  static Future<Map<String, dynamic>> getPropertyDetails(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/properties/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch property details');
    }
  }
  // Update an existing property
  static Future<bool> updateProperty(int id, Map<String, dynamic> propertyData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/properties/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(propertyData),
    );
    return response.statusCode == 200;
  }
  // Delete a property
  static Future<bool> deleteProperty(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/properties/$id'));
    return response.statusCode == 200;
  }
  // Fetch all properties
  static Future<List<Map<String, dynamic>>> getAllProperties() async {
    final response = await http.get(Uri.parse('$baseUrl/properties'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch all properties');
    }
  }
  // Fetch properties by type (residential, commercial, land, etc.)
  static Future<List<Map<String, dynamic>>> getPropertiesByType(String type) async {
    final response = await http.get(Uri.parse('$baseUrl/properties/$type'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch properties of type $type');
    }
  }
  // Fetch properties by location
  static Future<List<Map<String, dynamic>>> getPropertiesByLocation(String location) async {
    final response = await http.get(Uri.parse('$baseUrl/properties/location/$location'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch properties in $location');
    }
  }
  // Fetch properties by price range
  static Future<List<Map<String, dynamic>>> getPropertiesByPriceRange(double minPrice, double maxPrice) async {
    final response = await http.get(Uri.parse('$baseUrl/properties/price-range?min=$minPrice&max=$maxPrice'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch properties in price range $minPrice - $maxPrice');
    }
  }
  // Fetch properties by size range
  static Future<List<Map<String, dynamic>>> getPropertiesBySizeRange(double minSize, double maxSize) async {
    final response = await http.get(Uri.parse('$baseUrl/properties/size-range?min=$minSize&max=$maxSize'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch properties in size range $minSize - $maxSize');
    }
  }
  // Fetch properties by amenities
  static Future<List<Map<String, dynamic>>> getPropertiesByAmenities(List<String> amenities) async {
    final response = await http.post(
      Uri.parse('$baseUrl/properties/amenities'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amenities': amenities}),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch properties with specified amenities');
    }
  }
  // Fetch properties by features
  static Future<List<Map<String, dynamic>>> getPropertiesByFeatures(List<String> features) async {
    final response = await http.post(
      Uri.parse('$baseUrl/properties/features'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'features': features}),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch properties with specified features');
    }
  }
  // Fetch properties by owner
  static Future<List<Map<String, dynamic>>> getPropertiesByOwner(int ownerId) async {
    final response = await http.get(Uri.parse('$baseUrl/properties/owner/$ownerId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch properties owned by user with ID $ownerId');
    }
  }
  // Fetch properties by status (available, sold, rented, etc.)
  static Future<List<Map<String, dynamic>>> getPropertiesByStatus(String status) async {
    final response = await http.get(Uri.parse('$baseUrl/properties/status/$status'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch properties with status $status');
    }
  }
  // Fetch properties by date added
  static Future<List<Map<String, dynamic>>> getPropertiesByDateAdded(DateTime date) async {
    final response = await http.get(Uri.parse('$baseUrl/properties/date-added/${date.toIso8601String()}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch properties added on $date');
    }
  }
  // Fetch properties by last updated date
  static Future<List<Map<String, dynamic>>> getPropertiesByLastUpdated(DateTime date) async {
    final response = await http.get(Uri.parse('$baseUrl/properties/last-updated/${date.toIso8601String()}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch properties last updated on $date');
    }
  }
  // Fetch properties by custom filters
  static Future<List<Map<String, dynamic>>> getPropertiesByFilters(Map<String, dynamic> filters) async {
    final response = await http.post(
      Uri.parse('$baseUrl/properties/filters'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(filters),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch properties with specified filters');
    }
  }
  // Fetch properties by search query
  static Future<List<Map<String, dynamic>>> searchProperties(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/properties/search?query=$query'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to search properties with query: $query');
    }
  }
}