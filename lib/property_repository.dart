import 'database_helper.dart';
import 'dart:math';

// Unified Listing model for dashboard display
class DashboardListing {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String city;
  final String state;
  final String country;
  final String category;
  final String status;
  final String createdAt;
  final int views;
  final String listerName;
  final String listerDp;
  final String urgencyPeriod;
  final String listingImage;
  final int? bedrooms;
  final int? bathrooms;
  final int? toilets;
  final int? parkingSpaces;
  final bool? hasInternet;
  final bool? hasElectricity;
  final String? landTitle;
  final double? landSize;
  final String? quantity;
  final String? condition;
  final String? listerWhatsapp;
  final String? listerEmail;
  final String? userId;
  final String latitude;
  final String longitude;

  DashboardListing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.city,
    required this.state,
    required this.country,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.views,
    required this.listerName,
    required this.listerDp,
    required this.urgencyPeriod,
    required this.listingImage,
    required this.latitude,
    required this.longitude,
    this.bedrooms,
    this.bathrooms,
    this.toilets,
    this.parkingSpaces,
    this.hasInternet,
    this.hasElectricity,
    this.landTitle,
    this.landSize,
    this.quantity,
    this.condition,
    this.listerWhatsapp,
    this.listerEmail,
    this.userId,
  });

  // Create from a form submission
  factory DashboardListing.fromFormSubmission(Map<String, dynamic> submission, Map<String, dynamic> userData) {
    // Parse deadline for urgency period
    String urgencyPeriod = DateTime.now().add(const Duration(days: 7)).toIso8601String();
    if (submission['is_urgent'] == 1 && submission['urgencySettings'] != null) {
      final urgencyData = submission['urgencySettings'] as Map<String, dynamic>;
      if (urgencyData['deadline'] != null && urgencyData['deadline'].toString().isNotEmpty) {
        final deadlineText = urgencyData['deadline'].toString();
        if (deadlineText.contains('day')) {
          final days = int.tryParse(deadlineText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 7;
          urgencyPeriod = DateTime.now().add(Duration(days: days)).toIso8601String();
        } else if (deadlineText.contains('week')) {
          final weeks = int.tryParse(deadlineText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
          urgencyPeriod = DateTime.now().add(Duration(days: weeks * 7)).toIso8601String();
        } else if (deadlineText.contains('month')) {
          final months = int.tryParse(deadlineText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
          urgencyPeriod = DateTime.now().add(Duration(days: months * 30)).toIso8601String();
        }
      }
    }

    // Extract location components
    final locationParts = (submission['location'] as String? ?? 'Unknown').split(',');
    String city = 'Unknown';
    String state = 'Unknown';
    String country = 'Nigeria';
    
    if (locationParts.length >= 1) {
      city = locationParts[0].trim();
    }
    if (locationParts.length >= 2) {
      state = locationParts[1].trim();
    }
    if (locationParts.length >= 3) {
      country = locationParts[2].trim();
    }

    // Extract features
    final features = submission['features'] as List<Map<String, dynamic>>? ?? [];
    int? bedrooms;
    int? bathrooms;
    int? toilets;
    int? parkingSpaces;
    bool hasInternet = false;
    bool hasElectricity = false;
    String? landTitle;
    double? landSize;
    String? quantity;
    String? condition;
    
    for (final feature in features) {
      final type = feature['feature_type'] as String;
      final value = feature['feature_value'] as String;
      
      switch (type) {
        case 'bedrooms':
          bedrooms = int.tryParse(value);
          break;
        case 'bathrooms':
          bathrooms = int.tryParse(value);
          break;
        case 'toilets':
          toilets = int.tryParse(value);
          break;
        case 'parking_spaces':
          parkingSpaces = int.tryParse(value);
          break;
        case 'has_internet':
          hasInternet = value.toLowerCase() == 'true' || value == '1';
          break;
        case 'has_electricity':
          hasElectricity = value.toLowerCase() == 'true' || value == '1';
          break;
        case 'land_title':
          landTitle = value;
          break;
        case 'land_size':
          landSize = double.tryParse(value);
          break;
        case 'quantity':
          quantity = value;
          break;
        case 'condition':
          condition = value;
          break;
      }
    }

    // Extract images
    List<String> images = [];
    if (submission['images'] != null && submission['images'] is List) {
      final imageList = submission['images'] as List;
      for (final img in imageList) {
        if (img is Map<String, dynamic> && img['image_path'] != null) {
          images.add(img['image_path'] as String);
        }
      }
    }

    return DashboardListing(
      id: submission['id'].toString(),
      title: submission['title'] ?? 'Untitled Listing',
      description: submission['description'] ?? 'No description provided',
      price: (submission['price'] is String) 
          ? double.tryParse(submission['price']) ?? 0.0 
          : (submission['price'] ?? 0.0),
      location: submission['location'] ?? 'Unknown location',
      city: city,
      state: state,
      country: country,
      category: submission['type'] ?? submission['category'] ?? 'Unknown',
      status: submission['status'] ?? 'Available',
      createdAt: submission['created_at'] ?? DateTime.now().toIso8601String(),
      views: submission['views'] ?? Random().nextInt(100),
      listerName: userData['first_name'] != null && userData['last_name'] != null 
          ? "${userData['first_name']} ${userData['last_name']}"
          : (userData['fullName'] ?? 'Unknown User'),
      listerDp: userData['avatar_url'] ?? 'assets/images/chatbot.png',
      urgencyPeriod: urgencyPeriod,
      listingImage: images.isNotEmpty ? images.first : _getDefaultImageForType(submission['type']),
      latitude: submission['latitude']?.toString() ?? '0.0',
      longitude: submission['longitude']?.toString() ?? '0.0',
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      toilets: toilets,
      parkingSpaces: parkingSpaces,
      hasInternet: hasInternet,
      hasElectricity: hasElectricity,
      landTitle: landTitle,
      landSize: landSize,
      quantity: quantity,
      condition: condition,
      listerWhatsapp: submission['whatsapp_link'] ?? submission['whatsapp_number'],
      listerEmail: userData['email'],
      userId: userData['id']?.toString(),
    );
  }

  // Helper to get default image based on property type
  static String _getDefaultImageForType(String? type) {
    if (type == null) return 'assets/images/mipripity-logo.png';
    
    switch (type.toLowerCase()) {
      case 'residential':
        return 'assets/images/residential1.jpg';
      case 'commercial':
        return 'assets/images/commercial1.jpg';
      case 'land':
        return 'assets/images/land1.jpeg';
      case 'material':
        return 'assets/images/material1.jpg';
      default:
        return 'assets/images/mipripity-logo.png';
    }
  }
}

// Residential Property Model
class PropertyListing {
  final String id;
  final String title;
  final double price;
  final String location;
  final String imageUrl;
  final int? bedrooms;
  final int? bathrooms;
  final double? area;
  final String category;
  final String description;
  final List<String> features;
  final bool isFeatured;
  final String status;

  PropertyListing({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.imageUrl,
    this.bedrooms,
    this.bathrooms,
    this.area,
    required this.category,
    required this.description,
    required this.features,
    this.isFeatured = false,
    this.status = 'for_sale',
  });

  // Create from form submission
  factory PropertyListing.fromFormSubmission(Map<String, dynamic> submission) {
    // Extract features
    final featuresList = <String>[];
    final features = submission['features'] as List<Map<String, dynamic>>? ?? [];
    
    for (final feature in features) {
      final type = feature['feature_type'] as String;
      final value = feature['feature_value'] as String;
      
      // Add as feature string
      if (type == 'bedrooms' && int.tryParse(value) != null) {
        featuresList.add('${value} Bedrooms');
      } else if (type == 'bathrooms' && int.tryParse(value) != null) {
        featuresList.add('${value} Bathrooms');
      } else if (type == 'toilets' && int.tryParse(value) != null) {
        featuresList.add('${value} Toilets');
      } else if (type == 'parking_spaces' && int.tryParse(value) != null) {
        featuresList.add('${value} Parking Spaces');
      }
    }
    
    // Extract bedrooms and bathrooms
    int? bedrooms;
    int? bathrooms;
    
    for (final feature in features) {
      final type = feature['feature_type'] as String;
      final value = feature['feature_value'] as String;
      
      if (type == 'bedrooms') {
        bedrooms = int.tryParse(value);
      } else if (type == 'bathrooms') {
        bathrooms = int.tryParse(value);
      }
    }
    
    // Extract images
    List<String> images = [];
    if (submission['images'] != null && submission['images'] is List) {
      final imageList = submission['images'] as List;
      for (final img in imageList) {
        if (img is Map<String, dynamic> && img['image_path'] != null) {
          images.add(img['image_path'] as String);
        }
      }
    }
    
    return PropertyListing(
      id: submission['id'].toString(),
      title: submission['title'] ?? 'Untitled Property',
      price: submission['price'],
      location: submission['location'] ?? 'Unknown',
      imageUrl: images.isNotEmpty ? images.first : 'assets/images/residential1.jpg',
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      area: null, // Area is not collected in form
      category: 'residential',
      description: submission['description'] ?? 'No description provided',
      features: featuresList,
      status: submission['status'] ?? 'for_sale',
    );
  }

  factory PropertyListing.fromMap(Map<String, dynamic> map) {
    return PropertyListing(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      price: map['price'] is String ? double.tryParse(map['price']) ?? 0.0 : map['price'] ?? 0.0,
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? map['image_url'] ?? 'assets/images/residential1.jpg',
      bedrooms: map['bedrooms'] is String ? int.tryParse(map['bedrooms']) : map['bedrooms'],
      bathrooms: map['bathrooms'] is String ? int.tryParse(map['bathrooms']) : map['bathrooms'],
      area: map['area'] is String ? double.tryParse(map['area']) : map['area'],
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      features: map['features'] != null 
          ? (map['features'] is String ? (map['features'] as String).split(',') : 
             map['features'] is List ? (map['features'] as List).map((e) => e.toString()).toList() : [])
          : [],
      isFeatured: map['isFeatured'] == 1,
      status: map['status'] ?? 'for_sale',
    );
  }

  bool? get isFavorite => null;
}

// Commercial Property Model
class CommercialProperty {
  final String id;
  final String title;
  final double price;
  final String location;
  final String imageUrl;
  final String propertyType;
  final double area;
  final String description;
  final List<String> features;
  final bool isFeatured;
  final String status;
  final int? floors;
  final int? parkingSpaces;
  final String? yearBuilt;

  CommercialProperty({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.imageUrl,
    required this.propertyType,
    required this.area,
    required this.description,
    required this.features,
    this.isFeatured = false,
    this.status = 'for_sale',
    this.floors,
    this.parkingSpaces,
    this.yearBuilt,
  });

  factory CommercialProperty.fromMap(Map<String, dynamic> map) {
    return CommercialProperty(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      price: map['price'] ?? 0.0,
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      propertyType: map['propertyType'] ?? '',
      area: map['area'] ?? 0.0,
      description: map['description'] ?? '',
      features: map['features'] != null 
          ? (map['features'] is String ? (map['features'] as String).split(',') : [])
          : [],
      isFeatured: map['isFeatured'] == 1,
      status: map['status'] ?? 'for_sale',
      floors: map['floors'],
      parkingSpaces: map['parkingSpaces'],
      yearBuilt: map['yearBuilt'],
    );
  }
  
  // Create from form submission
  factory CommercialProperty.fromFormSubmission(Map<String, dynamic> submission) {
    // Extract images
    List<String> images = [];
    if (submission['images'] != null && submission['images'] is List) {
      final imageList = submission['images'] as List;
      for (final img in imageList) {
        if (img is Map<String, dynamic> && img['image_path'] != null) {
          images.add(img['image_path'] as String);
        }
      }
    }
    
    // Extract features
    final featuresList = <String>[];
    final features = submission['features'] as List<Map<String, dynamic>>? ?? [];
    bool hasInternet = false;
    bool hasElectricity = false;
    
    for (final feature in features) {
      final type = feature['feature_type'] as String;
      final value = feature['feature_value'] as String;
      
      if (type == 'has_internet') {
        hasInternet = value.toLowerCase() == 'true' || value == '1';
      } else if (type == 'has_electricity') {
        hasElectricity = value.toLowerCase() == 'true' || value == '1';
      }
    }
    
    if (hasInternet) featuresList.add('Internet Available');
    if (hasElectricity) featuresList.add('24/7 Electricity');
    
    return CommercialProperty(
      id: submission['id'].toString(),
      title: submission['title'] ?? 'Untitled Commercial Property',
      price: (submission['price'] is String) 
          ? double.tryParse(submission['price']) ?? 0.0 
          : (submission['price'] ?? 0.0),
      location: submission['location'] ?? 'Unknown',
      imageUrl: images.isNotEmpty ? images.first : 'assets/images/commercial1.jpg',
      propertyType: submission['category'] ?? 'Office Space',
      area: 0.0, // Area is not directly available
      description: submission['description'] ?? 'No description provided',
      features: featuresList,
      status: submission['status'] ?? 'for_sale',
    );
  }
}

// Land Property Model
class LandProperty {
  final String id;
  final String title;
  final double price;
  final String location;
  final String imageUrl;
  final String landType;
  final double area;
  final String areaUnit;
  final String description;
  final List<String> features;
  final bool isFeatured;
  final String status;
  final String? titleDocument;
  final bool? surveyed;
  final String? zoning;

  LandProperty({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.imageUrl,
    required this.landType,
    required this.area,
    required this.areaUnit,
    required this.description,
    required this.features,
    this.isFeatured = false,
    this.status = 'for_sale',
    this.titleDocument,
    this.surveyed,
    this.zoning,
  });

  factory LandProperty.fromMap(Map<String, dynamic> map) {
    return LandProperty(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      price: map['price'] ?? 0.0,
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      landType: map['landType'] ?? '',
      area: map['area'] ?? 0.0,
      areaUnit: map['areaUnit'] ?? 'sqm',
      description: map['description'] ?? '',
      features: map['features'] != null 
          ? (map['features'] is String ? (map['features'] as String).split(',') : [])
          : [],
      isFeatured: map['isFeatured'] == 1,
      status: map['status'] ?? 'for_sale',
      titleDocument: map['titleDocument'],
      surveyed: map['surveyed'] == 1,
      zoning: map['zoning'],
    );
  }
  
  // Create from form submission
  factory LandProperty.fromFormSubmission(Map<String, dynamic> submission) {
    // Extract images
    List<String> images = [];
    if (submission['images'] != null && submission['images'] is List) {
      final imageList = submission['images'] as List;
      for (final img in imageList) {
        if (img is Map<String, dynamic> && img['image_path'] != null) {
          images.add(img['image_path'] as String);
        }
      }
    }
    
    // Extract features
    String? landTitle;
    double? landSize;
    final features = submission['features'] as List<Map<String, dynamic>>? ?? [];
    
    for (final feature in features) {
      final type = feature['feature_type'] as String;
      final value = feature['feature_value'] as String;
      
      if (type == 'land_title') {
        landTitle = value;
      } else if (type == 'land_size') {
        landSize = double.tryParse(value);
      }
    }
    
    return LandProperty(
      id: submission['id'].toString(),
      title: submission['title'] ?? 'Untitled Land Property',
      price: (submission['price'] is String) 
          ? double.tryParse(submission['price']) ?? 0.0 
          : (submission['price'] ?? 0.0),
      location: submission['location'] ?? 'Unknown',
      imageUrl: images.isNotEmpty ? images.first : 'assets/images/land1.jpeg',
      landType: submission['category'] ?? 'Residential Land',
      area: landSize ?? 0.0,
      areaUnit: 'sqm',
      description: submission['description'] ?? 'No description provided',
      features: [],
      status: submission['status'] ?? 'for_sale',
      titleDocument: landTitle,
    );
  }
}

// Material Property Model
class MaterialProperty {
  final String id;
  final String title;
  final double price;
  final String location;
  final String imageUrl;
  final String materialType;
  final String? quantity;
  final String description;
  final List<String> features;
  final bool isFeatured;
  final String status;
  final String? condition;
  final String? brand;
  final String? warranty;

  MaterialProperty({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.imageUrl,
    required this.materialType,
    this.quantity,
    required this.description,
    required this.features,
    this.isFeatured = false,
    this.status = 'available',
    this.condition,
    this.brand,
    this.warranty,
  });

  factory MaterialProperty.fromMap(Map<String, dynamic> map) {
    return MaterialProperty(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      price: map['price'] ?? 0.0,
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      materialType: map['materialType'] ?? '',
      quantity: map['quantity'],
      description: map['description'] ?? '',
      features: map['features'] != null 
          ? (map['features'] is String ? (map['features'] as String).split(',') : [])
          : [],
      isFeatured: map['isFeatured'] == 1,
      status: map['status'] ?? 'available',
      condition: map['condition'],
      brand: map['brand'],
      warranty: map['warranty'],
    );
  }
  
  // Create from form submission
  factory MaterialProperty.fromFormSubmission(Map<String, dynamic> submission) {
    // Extract images
    List<String> images = [];
    if (submission['images'] != null && submission['images'] is List) {
      final imageList = submission['images'] as List;
      for (final img in imageList) {
        if (img is Map<String, dynamic> && img['image_path'] != null) {
          images.add(img['image_path'] as String);
        }
      }
    }
    
    // Extract features
    String? quantity;
    String? condition;
    final features = submission['features'] as List<Map<String, dynamic>>? ?? [];
    
    for (final feature in features) {
      final type = feature['feature_type'] as String;
      final value = feature['feature_value'] as String;
      
      if (type == 'quantity') {
        quantity = value;
      } else if (type == 'condition') {
        condition = value;
      }
    }
    
    return MaterialProperty(
      id: submission['id'].toString(),
      title: submission['title'] ?? 'Untitled Material',
      price: (submission['price'] is String) 
          ? double.tryParse(submission['price']) ?? 0.0 
          : (submission['price'] ?? 0.0),
      location: submission['location'] ?? 'Unknown',
      imageUrl: images.isNotEmpty ? images.first : 'assets/images/material1.jpg',
      materialType: submission['category'] ?? 'Other',
      quantity: quantity,
      description: submission['description'] ?? 'No description provided',
      features: [],
      status: submission['status'] ?? 'available',
      condition: condition,
    );
  }
}

class PropertyRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      // Remove any currency symbols and commas
      final cleanPrice = price.replaceAll(RegExp(r'[₦,\s]'), '');
      return double.tryParse(cleanPrice) ?? 0.0;
    }
    return 0.0;
  }

  // Get all properties for dashboard display
  Future<List<DashboardListing>> getAllProperties() async {
    try {
      final List<DashboardListing> listings = [];
    
      // Get all form submissions with details
      final submissions = await _getAllFormSubmissions();
      
      for (final submission in submissions) {
        final userId = submission['user_id']?.toString();
        Map<String, dynamic> userData = {
          'id': userId,
          'first_name': 'Anonymous',
          'last_name': 'User',
          'email': 'user@example.com',
          'avatar_url': 'assets/images/chatbot.png',
        };
        
        if (userId != null && userId != 'null') {
          try {
            final user = await _databaseHelper.getUserById(int.tryParse(userId) ?? 0);
            if (user != null) {
              userData = user;
            }
          } catch (e) {
            print('Error fetching user data for user $userId: $e');
          }
        }
        
        try {
          listings.add(DashboardListing.fromFormSubmission(submission, userData));
        } catch (e) {
          print('Error creating DashboardListing from submission: $e');
        }
      }
      
      // Also get properties from the original property tables
      await _addOriginalPropertiesToListings(listings);
      
      return listings;
    } catch (e) {
      print('Error fetching all properties: $e');
      return [];
    }
  }

  Future<void> _addOriginalPropertiesToListings(List<DashboardListing> listings) async {
    try {
      final db = await _databaseHelper.database;
      
      // Get residential properties
      final residentialProps = await db.query('residential_properties', limit: 10);
      for (final prop in residentialProps) {
        listings.add(_createDashboardListingFromProperty(prop, 'residential'));
      }
      
      // Get commercial properties
      final commercialProps = await db.query('commercial_properties', limit: 10);
      for (final prop in commercialProps) {
        listings.add(_createDashboardListingFromProperty(prop, 'commercial'));
      }
      
      // Get land properties
      final landProps = await db.query('land_properties', limit: 10);
      for (final prop in landProps) {
        listings.add(_createDashboardListingFromProperty(prop, 'land'));
      }
      
      // Get material properties
      final materialProps = await db.query('material_properties', limit: 10);
      for (final prop in materialProps) {
        listings.add(_createDashboardListingFromProperty(prop, 'material'));
      }
    } catch (e) {
      print('Error adding original properties: $e');
    }
  }

  DashboardListing _createDashboardListingFromProperty(Map<String, dynamic> property, String type) {
    final locationParts = (property['location'] as String? ?? 'Unknown').split(',');
    String city = 'Unknown';
    String state = 'Unknown';
    String country = 'Nigeria';
    
    if (locationParts.length >= 1) city = locationParts[0].trim();
    if (locationParts.length >= 2) state = locationParts[1].trim();
    if (locationParts.length >= 3) country = locationParts[2].trim();

    return DashboardListing(
      id: property['id'].toString(),
      title: property['title'] ?? 'Untitled Property',
      description: property['description'] ?? 'No description available',
      price: _parsePrice(property['price']),
      location: property['location'] ?? 'Unknown',
      city: city,
      state: state,
      country: country,
      category: type,
      status: property['status'] ?? 'Available',
      createdAt: property['created_at'] ?? DateTime.now().toIso8601String(),
      views: Random().nextInt(100),
      listerName: 'Property Owner',
      listerDp: 'assets/images/chatbot.png',
      urgencyPeriod: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      listingImage: property['imageUrl'] ?? DashboardListing._getDefaultImageForType(type),
      latitude: '0.0',
      longitude: '0.0',
      bedrooms: property['bedrooms'],
      bathrooms: property['bathrooms'],
      listerWhatsapp: 'https://wa.me/2348000000000',
      listerEmail: 'owner@example.com',
    );
  }

  // Private helper to get all form submissions with details
  Future<List<Map<String, dynamic>>> _getAllFormSubmissions() async {
    try {
      final List<Map<String, dynamic>> result = [];
      
      // Query the form_submissions table
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> submissions = await db.query('form_submissions');
      
      // Get details for each submission
      for (final submission in submissions) {
        final detailedSubmission = await _getSubmissionDetails(submission);
        if (detailedSubmission != null) {
          result.add(detailedSubmission);
        }
      }
      
      return result;
    } catch (e) {
      print('Error getting all form submissions: $e');
      return [];
    }
  }
  
  // Helper to get submission details (images, features, etc.)
  Future<Map<String, dynamic>?> _getSubmissionDetails(Map<String, dynamic> submission) async {
    try {
      final int submissionId = submission['id'];
      final db = await _databaseHelper.database;
      
      // Get images
      final List<Map<String, dynamic>> images = await db.query(
        'form_images',
        where: 'form_id = ?',
        whereArgs: [submissionId],
        orderBy: 'display_order',
      );
      
      // Get features
      final List<Map<String, dynamic>> features = await db.query(
        'form_features',
        where: 'form_id = ?',
        whereArgs: [submissionId],
      );
      
      // Get demographic targets
      final List<Map<String, dynamic>> demographics = await db.query(
        'demographic_targets',
        where: 'form_id = ?',
        whereArgs: [submissionId],
      );
      
      // Get urgency settings
      final List<Map<String, dynamic>> urgencySettings = await db.query(
        'urgency_settings',
        where: 'form_id = ?',
        whereArgs: [submissionId],
      );
      
      // Combine data
      final detailedSubmission = Map<String, dynamic>.from(submission);
      detailedSubmission['images'] = images;
      detailedSubmission['features'] = features;
      detailedSubmission['demographicTargets'] = demographics.isNotEmpty ? demographics.first : null;
      detailedSubmission['urgencySettings'] = urgencySettings.isNotEmpty ? urgencySettings.first : null;
      
      return detailedSubmission;
    } catch (e) {
      print('Error getting submission details: $e');
      return null;
    }
  }

  // Get submissions by type
  Future<List<Map<String, dynamic>>> _getFormSubmissionsByType(String type) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> submissions = await db.query(
        'form_submissions',
        where: 'type = ?',
        whereArgs: [type],
      );
      
      final List<Map<String, dynamic>> detailedSubmissions = [];
      
      for (final submission in submissions) {
        final detailedSubmission = await _getSubmissionDetails(submission);
        if (detailedSubmission != null) {
          detailedSubmissions.add(detailedSubmission);
        }
      }
      
      return detailedSubmissions;
    } catch (e) {
      print('Error getting form submissions by type: $e');
      return [];
    }
  }
  
  // Get a specific submission by ID
  Future<Map<String, dynamic>?> _getFormSubmissionById(int id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> submissions = await db.query(
        'form_submissions',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (submissions.isEmpty) return null;
      
      return await _getSubmissionDetails(submissions.first);
    } catch (e) {
      print('Error getting form submission by ID: $e');
      return null;
    }
  }

  // RESIDENTIAL PROPERTIES
  
  // Get all residential properties (from both database and form submissions)
  Future<List<PropertyListing>> getResidentialProperties() async {
    try {
      final List<PropertyListing> result = [];
      
      // Get from original database
      final properties = await _databaseHelper.getResidentialProperties();
      result.addAll(properties.map((map) => PropertyListing.fromMap(map)));
      
      // Get from form submissions
      final submissions = await _getFormSubmissionsByType('residential');
      for (final submission in submissions) {
        try {
          result.add(PropertyListing.fromFormSubmission(submission));
        } catch (e) {
          print('Error converting residential submission: $e');
        }
      }
      
      return result;
    } catch (e) {
      print('Error fetching residential properties: $e');
      return [];
    }
  }
  
  // Get filtered residential properties
  Future<List<PropertyListing>> getFilteredResidentialProperties({
    String? status,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
  }) async {
    try {
      final List<PropertyListing> result = [];
      
      // Get from original database with filter
      final properties = await _databaseHelper.getResidentialPropertiesByFilter(
        status: status,
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        searchQuery: searchQuery,
      );
      result.addAll(properties.map((map) => PropertyListing.fromMap(map)));
      
      // Get from form submissions
      final submissions = await _getFormSubmissionsByType('residential');
      
      // Apply filtering to submissions
      for (final submission in submissions) {
        bool includeProperty = true;
        
        // Apply status filter
        if (status != null && status != 'all') {
          final propertyStatus = submission['status']?.toString() ?? 'Available';
          if (propertyStatus.toLowerCase() != status.toLowerCase()) {
            includeProperty = false;
          }
        }
        
        // Apply category filter
        if (category != null && category != 'all') {
          final propertyCategory = submission['category']?.toString() ?? '';
          if (propertyCategory.toLowerCase() != category.toLowerCase()) {
            includeProperty = false;
          }
        }
        
        // Apply price filter
        final price = (submission['price'] is String)
            ? double.tryParse(submission['price']) ?? 0.0
            : (submission['price'] ?? 0.0);
            
        if (minPrice != null && price < minPrice) {
          includeProperty = false;
        }
        
        if (maxPrice != null && price > maxPrice) {
          includeProperty = false;
        }
        
        // Apply search query filter
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final title = submission['title']?.toString() ?? '';
          final location = submission['location']?.toString() ?? '';
          final description = submission['description']?.toString() ?? '';
          
          final containsQuery = 
              title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              location.toLowerCase().contains(searchQuery.toLowerCase()) ||
              description.toLowerCase().contains(searchQuery.toLowerCase());
              
          if (!containsQuery) {
            includeProperty = false;
          }
        }
        
        // Add to result if passes all filters
        if (includeProperty) {
          try {
            result.add(PropertyListing.fromFormSubmission(submission));
          } catch (e) {
            print('Error converting filtered residential submission: $e');
          }
        }
      }
      
      return result;
    } catch (e) {
      print('Error filtering residential properties: $e');
      return [];
    }
  }
  
  // Get specific residential property by ID
  Future<PropertyListing?> getResidentialPropertyById(String id) async {
    try {
      // Try to parse as integer for database lookup
      final int? intId = int.tryParse(id);
      
      if (intId != null) {
        // Try to get from form submissions first
        final submission = await _getFormSubmissionById(intId);
        if (submission != null && submission['type'] == 'residential') {
          return PropertyListing.fromFormSubmission(submission);
        }
        
        // Try to get from original database
        final db = await _databaseHelper.database;
        final List<Map<String, dynamic>> properties = await db.query(
          'residential_properties',
          where: 'id = ?',
          whereArgs: [intId],
        );
        
        if (properties.isNotEmpty) {
          return PropertyListing.fromMap(properties.first);
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching residential property by ID: $e');
      return null;
    }
  }

  // COMMERCIAL PROPERTIES
  
  // Get all commercial properties
  Future<List<CommercialProperty>> getCommercialProperties() async {
    try {
      final List<CommercialProperty> result = [];
      
      // Get from original database
      final properties = await _databaseHelper.getCommercialProperties();
      result.addAll(properties.map((map) => CommercialProperty.fromMap(map)));
      
      // Get from form submissions
      final submissions = await _getFormSubmissionsByType('commercial');
      for (final submission in submissions) {
        try {
          result.add(CommercialProperty.fromFormSubmission(submission));
        } catch (e) {
          print('Error converting commercial submission: $e');
        }
      }
      
      return result;
    } catch (e) {
      print('Error fetching commercial properties: $e');
      return [];
    }
  }
  
  // Get filtered commercial properties
  Future<List<CommercialProperty>> getFilteredCommercialProperties({
    String? status,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
  }) async {
    try {
      final List<CommercialProperty> result = [];
      
      // Get from form submissions
      final submissions = await _getFormSubmissionsByType('commercial');
      
      // Apply filtering
      for (final submission in submissions) {
        bool includeProperty = true;
        
        // Apply filters
        if (status != null && status != 'all') {
          final propertyStatus = submission['status']?.toString() ?? 'Available';
          if (propertyStatus.toLowerCase() != status.toLowerCase()) {
            includeProperty = false;
          }
        }
        
        if (propertyType != null && propertyType != 'all') {
          final type = submission['category']?.toString() ?? '';
          if (type.toLowerCase() != propertyType.toLowerCase()) {
            includeProperty = false;
          }
        }
        
        // Apply price filter
        final price = (submission['price'] is String)
            ? double.tryParse(submission['price']) ?? 0.0
            : (submission['price'] ?? 0.0);
            
        if (minPrice != null && price < minPrice) {
          includeProperty = false;
        }
        
        if (maxPrice != null && price > maxPrice) {
          includeProperty = false;
        }
        
        // Apply search query filter
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final title = submission['title']?.toString() ?? '';
          final location = submission['location']?.toString() ?? '';
          final description = submission['description']?.toString() ?? '';
          
          final containsQuery = 
              title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              location.toLowerCase().contains(searchQuery.toLowerCase()) ||
              description.toLowerCase().contains(searchQuery.toLowerCase());
              
          if (!containsQuery) {
            includeProperty = false;
          }
        }
        
        // Add to result if passes all filters
        if (includeProperty) {
          try {
            result.add(CommercialProperty.fromFormSubmission(submission));
          } catch (e) {
            print('Error converting filtered commercial submission: $e');
          }
        }
      }
      
      return result;
    } catch (e) {
      print('Error filtering commercial properties: $e');
      return [];
    }
  }
  
  // Get specific commercial property by ID
  Future<CommercialProperty?> getCommercialPropertyById(String id) async {
    try {
      // Try to parse as integer for database lookup
      final int? intId = int.tryParse(id);
      
      if (intId != null) {
        // Try to get from form submissions first
        final submission = await _getFormSubmissionById(intId);
        if (submission != null && submission['type'] == 'commercial') {
          return CommercialProperty.fromFormSubmission(submission);
        }
        
        // Try to get from original database
        final db = await _databaseHelper.database;
        final List<Map<String, dynamic>> properties = await db.query(
          'commercial_properties',
          where: 'id = ?',
          whereArgs: [intId],
        );
        
        if (properties.isNotEmpty) {
          return CommercialProperty.fromMap(properties.first);
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching commercial property by ID: $e');
      return null;
    }
  }
  
  // LAND PROPERTIES
  
  // Get all land properties
  Future<List<LandProperty>> getLandProperties() async {
    try {
      final List<LandProperty> result = [];
      
      // Get from original database
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> properties = await db.query('land_properties');
      result.addAll(properties.map((map) => LandProperty.fromMap(map)));
      
      // Get from form submissions
      final submissions = await _getFormSubmissionsByType('land');
      for (final submission in submissions) {
        try {
          result.add(LandProperty.fromFormSubmission(submission));
        } catch (e) {
          print('Error converting land submission: $e');
        }
      }
      
      return result;
    } catch (e) {
      print('Error fetching land properties: $e');
      return [];
    }
  }
  
  // Get filtered land properties
  Future<List<LandProperty>> getFilteredLandProperties({
    String? landType,
    String? areaFilter,
    String? searchQuery,
  }) async {
    try {
      final List<LandProperty> result = [];
      
      // Get from form submissions
      final submissions = await _getFormSubmissionsByType('land');
      
      // Apply filtering
      for (final submission in submissions) {
        bool includeProperty = true;
        
        // Apply filters
        if (landType != null && landType != 'all') {
          final type = submission['category']?.toString() ?? '';
          if (type.toLowerCase() != landType.toLowerCase()) {
            includeProperty = false;
          }
        }
        
        // Apply area filter (would need to extract land_size from features)
        if (areaFilter != null && areaFilter != 'all') {
          // Implementation depends on how area filters are defined
        }
        
        // Apply search query filter
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final title = submission['title']?.toString() ?? '';
          final location = submission['location']?.toString() ?? '';
          final description = submission['description']?.toString() ?? '';
          
          final containsQuery = 
              title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              location.toLowerCase().contains(searchQuery.toLowerCase()) ||
              description.toLowerCase().contains(searchQuery.toLowerCase());
              
          if (!containsQuery) {
            includeProperty = false;
          }
        }
        
        // Add to result if passes all filters
        if (includeProperty) {
          try {
            result.add(LandProperty.fromFormSubmission(submission));
          } catch (e) {
            print('Error converting filtered land submission: $e');
          }
        }
      }
      
      return result;
    } catch (e) {
      print('Error filtering land properties: $e');
      return [];
    }
  }
  
  // Get specific land property by ID
  Future<LandProperty?> getLandPropertyById(String id) async {
    try {
      // Try to parse as integer for database lookup
      final int? intId = int.tryParse(id);
      
      if (intId != null) {
        // Try to get from form submissions first
        final submission = await _getFormSubmissionById(intId);
        if (submission != null && submission['type'] == 'land') {
          return LandProperty.fromFormSubmission(submission);
        }
        
        // Try to get from original database
        final db = await _databaseHelper.database;
        final List<Map<String, dynamic>> properties = await db.query(
          'land_properties',
          where: 'id = ?',
          whereArgs: [intId],
        );
        
        if (properties.isNotEmpty) {
          return LandProperty.fromMap(properties.first);
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching land property by ID: $e');
      return null;
    }
  }
  
  // MATERIAL PROPERTIES
  
  // Get all material properties
  Future<List<MaterialProperty>> getMaterialProperties() async {
    try {
      final List<MaterialProperty> result = [];
      
      // Get from original database
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> properties = await db.query('material_properties');
      result.addAll(properties.map((map) => MaterialProperty.fromMap(map)));
      
      // Get from form submissions
      final submissions = await _getFormSubmissionsByType('material');
      for (final submission in submissions) {
        try {
          result.add(MaterialProperty.fromFormSubmission(submission));
        } catch (e) {
          print('Error converting material submission: $e');
        }
      }
      
      return result;
    } catch (e) {
      print('Error fetching material properties: $e');
      return [];
    }
  }
  
  // Get filtered material properties
  Future<List<MaterialProperty>> getFilteredMaterialProperties({
    String? materialType,
    String? condition,
    String? searchQuery,
  }) async {
    try {
      final List<MaterialProperty> result = [];
      
      // Get from form submissions
      final submissions = await _getFormSubmissionsByType('material');
      
      // Apply filtering
      for (final submission in submissions) {
        bool includeProperty = true;
        
        // Apply filters
        if (materialType != null && materialType != 'all') {
          final type = submission['category']?.toString() ?? '';
          if (type.toLowerCase() != materialType.toLowerCase()) {
            includeProperty = false;
          }
        }
        
        // Apply condition filter
        if (condition != null && condition != 'all') {
          String? propertyCondition;
          
          // Extract condition from features
          final features = submission['features'] as List<Map<String, dynamic>>? ?? [];
          for (final feature in features) {
            if (feature['feature_type'] == 'condition') {
              propertyCondition = feature['feature_value'];
              break;
            }
          }
          
          if (propertyCondition == null || 
              propertyCondition.toLowerCase() != condition.toLowerCase()) {
            includeProperty = false;
          }
        }
        
        // Apply search query filter
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final title = submission['title']?.toString() ?? '';
          final location = submission['location']?.toString() ?? '';
          final description = submission['description']?.toString() ?? '';
          
          final containsQuery = 
              title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              location.toLowerCase().contains(searchQuery.toLowerCase()) ||
              description.toLowerCase().contains(searchQuery.toLowerCase());
              
          if (!containsQuery) {
            includeProperty = false;
          }
        }
        
        // Add to result if passes all filters
        if (includeProperty) {
          try {
            result.add(MaterialProperty.fromFormSubmission(submission));
          } catch (e) {
            print('Error converting filtered material submission: $e');
          }
        }
      }
      
      return result;
    } catch (e) {
      print('Error filtering material properties: $e');
      return [];
    }
  }
  
  // Get specific material property by ID
  Future<MaterialProperty?> getMaterialPropertyById(String id) async {
    try {
      // Try to parse as integer for database lookup
      final int? intId = int.tryParse(id);
      
      if (intId != null) {
        // Try to get from form submissions first
        final submission = await _getFormSubmissionById(intId);
        if (submission != null && submission['type'] == 'material') {
          return MaterialProperty.fromFormSubmission(submission);
        }
        
        // Try to get from original database
        final db = await _databaseHelper.database;
        final List<Map<String, dynamic>> properties = await db.query(
          'material_properties',
          where: 'id = ?',
          whereArgs: [intId],
        );
        
        if (properties.isNotEmpty) {
          return MaterialProperty.fromMap(properties.first);
        }
      }
      
      return null;
    } catch (e) {
      print('Error fetching material property by ID: $e');
      return null;
    }
  }
  
  // Check if database is initialized
  Future<bool> isDatabaseReady() async {
    try {
      final db = await _databaseHelper.database;
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Reset database (for testing)
  Future<void> resetDatabase() async {
    try {
      final db = await _databaseHelper.database;
      await db.execute('DELETE FROM form_submissions');
      await db.execute('DELETE FROM form_images');
      await db.execute('DELETE FROM form_features');
      await db.execute('DELETE FROM demographic_targets');
      await db.execute('DELETE FROM urgency_settings');
    } catch (e) {
      print('Error resetting database: $e');
    }
  }
}
