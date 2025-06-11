import 'dart:convert';
import 'package:http/http.dart' as http;

class NeonApiClient {
  static const String connectionString = 
      'postgresql://mipripity_v2_owner:pw_live_square-moon-79559388@ep-square-moon-79559388.us-east-1.aws.neon.tech/mipripity_v2?sslmode=require';
  
  // Since we can't directly connect to PostgreSQL from Flutter,
  // we'll need to create a simple REST API or use a service like Supabase
  // For now, let's create methods that would work with a REST API
  
  static const String baseUrl = 'YOUR_API_ENDPOINT'; // You'll need to create this
  
  static Future<Map<String, dynamic>?> executeQuery({
    required String query,
    List<dynamic>? parameters,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/execute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'parameters': parameters ?? [],
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Database query error: $e');
      return null;
    }
  }
  
  static Future<int?> insertListing({
    required String title,
    required String description,
    required double price,
    required String location,
    required String city,
    required String state,
    required String country,
    required int categoryId,
    required int userId,
    String? mainImageUrl,
  }) async {
    const query = '''
      INSERT INTO listings (title, description, price, location, city, state, country, category_id, user_id, main_image_url, created_at, updated_at)
      VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, NOW(), NOW())
      RETURNING id
    ''';
    
    final result = await executeQuery(
      query: query,
      parameters: [title, description, price, location, city, state, country, categoryId, userId, mainImageUrl],
    );
    
    return result?['rows']?[0]?['id'];
  }
  
  static Future<bool> insertDemographicTargets({
    required int listingId,
    required List<String> countries,
    required List<String> states,
    required List<String> lgas,
    required String ageGroup,
    required String socialClass,
    required List<String> occupations,
  }) async {
    const query = '''
      INSERT INTO demographic_targets (listing_id, countries, states, lgas, age_group, social_class, occupations, created_at)
      VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, NOW())
    ''';
    
    final result = await executeQuery(
      query: query,
      parameters: [listingId, countries, states, lgas, ageGroup, socialClass, occupations],
    );
    
    return result != null;
  }
  
  static Future<bool> insertUrgencySettings({
    required int listingId,
    required String reason,
    required String deadline,
    required bool isActive,
  }) async {
    const query = '''
      INSERT INTO urgency_settings (listing_id, reason, deadline, is_active, created_at)
      VALUES (\$1, \$2, \$3, \$4, NOW())
    ''';
    
    final result = await executeQuery(
      query: query,
      parameters: [listingId, reason, deadline, isActive],
    );
    
    return result != null;
  }
  
  static Future<bool> insertPropertyFeature({
    required int listingId,
    required String featureType,
    required String featureValue,
  }) async {
    const query = '''
      INSERT INTO property_features (listing_id, feature_type, feature_value, created_at)
      VALUES (\$1, \$2, \$3, NOW())
    ''';
    
    final result = await executeQuery(
      query: query,
      parameters: [listingId, featureType, featureValue],
    );
    
    return result != null;
  }
  
  static Future<bool> insertListingImage({
    required int listingId,
    required String imageUrl,
    required bool isMain,
    required int displayOrder,
  }) async {
    const query = '''
      INSERT INTO listing_images (listing_id, image_url, is_main, display_order, created_at)
      VALUES (\$1, \$2, \$3, \$4, NOW())
    ''';
    
    final result = await executeQuery(
      query: query,
      parameters: [listingId, imageUrl, isMain, displayOrder],
    );
    
    return result != null;
  }
}
