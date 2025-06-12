/// Configuration class for API endpoints
class ApiConfig {
  /// Base URL for the API
  /// In development, this can point to a local server (e.g. http://localhost:8080)
  /// In production, this can point to the deployed server (e.g. https://mipripity-api-1.onrender.com)
  static const String baseUrl = 'http://localhost:8080';
  
  /// Alternative production URL (can be used by changing the active URL in ApiConfig)
  static const String productionUrl = 'https://mipripity-api-1.onrender.com';

  /// Returns the active API base URL
  static String getBaseUrl() {
    // For development/testing purposes, uncomment the line below to use the local server
    return baseUrl;
    
    // For production, uncomment the line below to use the deployed server
    // return productionUrl;
  }
}