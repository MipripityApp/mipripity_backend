import '../database_helper.dart';

class DatabaseService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  // Submit complete form data
  Future<bool> submitCompleteListing({
    required Map<String, dynamic> formData,
    required int userId,
  }) async {
    try {
      // Validate required fields
      if (formData['title'] == null || formData['title'].toString().trim().isEmpty) {
        print('Title is required');
        return false;
      }
      
      if (formData['description'] == null || formData['description'].toString().trim().isEmpty) {
        print('Description is required');
        return false;
      }
      
      if (formData['price'] == null || formData['price'].toString().trim().isEmpty) {
        print('Price is required');
        return false;
      }
      
      if (formData['location'] == null || formData['location'].toString().trim().isEmpty) {
        print('Location is required');
        return false;
      }
      
      // Add user ID to form data
      formData['userId'] = userId;
      
      // Submit form data to SQLite database
      final formId = await _databaseHelper.submitForm(formData);
      
      return formId > 0;
    } catch (e) {
      print('Exception submitting complete listing: $e');
      return false;
    }
  }
  
  // Get category ID by name (simplified implementation - just returns 1 for now)
  Future<int?> getCategoryIdByName(String categoryName) async {
    return 1; // Just return a default value since we're not using categories with IDs
  }
  
  // Get user's listings
  Future<List<Map<String, dynamic>>> getUserListings(int userId) async {
    return await _databaseHelper.getSubmissionsByUser(userId);
  }
  
  // Get listing details
  Future<Map<String, dynamic>?> getListingDetails(int listingId) async {
    return await _databaseHelper.getSubmissionWithDetails(listingId);
  }
  
  // Update listing status
  Future<bool> updateListingStatus(int listingId, String status) async {
    return await _databaseHelper.updateSubmissionStatus(listingId, status);
  }
  
  // Delete listing
  Future<bool> deleteListing(int listingId) async {
    return await _databaseHelper.deleteSubmission(listingId);
  }
  
  // Get residential properties for listing
  Future<List<Map<String, dynamic>>> getResidentialProperties() async {
    return await _databaseHelper.getResidentialProperties();
  }
  
  // Get commercial properties for listing
  Future<List<Map<String, dynamic>>> getCommercialProperties() async {
    return await _databaseHelper.getCommercialProperties();
  }
  
  // Helper methods to extract city and state from location
  String _extractCity(String location) {
    final parts = location.split(',');
    return parts.isNotEmpty ? parts.first.trim() : location;
  }

  String _extractState(String location) {
    final parts = location.split(',');
    return parts.length > 1 ? parts.last.trim() : '';
  }
  
  // Register a new user
  Future<Map<String, dynamic>?> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? whatsappLink,
  }) async {
    return await _databaseHelper.registerUser(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      whatsappLink: whatsappLink,
    );
  }
  
  // Login a user
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    return await _databaseHelper.loginUser(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
  }

  // Get or create default user
  Future<int> getOrCreateDefaultUser() async {
    return await _databaseHelper.getOrCreateDefaultUser();
  }

  // Add property creation methods
  Future<bool> createResidentialProperty({
    required Map<String, dynamic> propertyData,
    required int userId,
  }) async {
    try {
      propertyData['user_id'] = userId;
      final propertyId = await _databaseHelper.insertResidentialProperty(propertyData);
      return propertyId > 0;
    } catch (e) {
      print('Error creating residential property: $e');
      return false;
    }
  }

  Future<bool> createCommercialProperty({
    required Map<String, dynamic> propertyData,
    required int userId,
  }) async {
    try {
      propertyData['user_id'] = userId;
      final propertyId = await _databaseHelper.insertCommercialProperty(propertyData);
      return propertyId > 0;
    } catch (e) {
      print('Error creating commercial property: $e');
      return false;
    }
  }

  Future<bool> createLandProperty({
    required Map<String, dynamic> propertyData,
    required int userId,
  }) async {
    try {
      propertyData['user_id'] = userId;
      final propertyId = await _databaseHelper.insertLandProperty(propertyData);
      return propertyId > 0;
    } catch (e) {
      print('Error creating land property: $e');
      return false;
    }
  }

  Future<bool> createMaterialProperty({
    required Map<String, dynamic> propertyData,
    required int userId,
  }) async {
    try {
      propertyData['user_id'] = userId;
      final propertyId = await _databaseHelper.insertMaterialProperty(propertyData);
      return propertyId > 0;
    } catch (e) {
      print('Error creating material property: $e');
      return false;
    }
  }

  // Get featured properties by category
  Future<List<Map<String, dynamic>>> getFeaturedPropertiesByCategory(String category, {required int limit}) async {
    try {
      // First try to get featured properties
      List<Map<String, dynamic>> featuredProperties = await _databaseHelper.getFeaturedPropertiesByCategory(category, limit: limit);
      
      // If no featured properties, get recent properties
      if (featuredProperties.isEmpty) {
        featuredProperties = await _databaseHelper.getRecentPropertiesByCategory(category, limit: limit);
      }
      
      return featuredProperties;
    } catch (e) {
      print('Error getting featured properties for $category: $e');
      return [];
    }
  }

  // Get all featured properties
  Future<List<Map<String, dynamic>>> getAllFeaturedProperties({int limit = 20}) async {
    try {
      return await _databaseHelper.getAllFeaturedProperties(limit: limit);
    } catch (e) {
      print('Error getting all featured properties: $e');
      return [];
    }
  }
}
