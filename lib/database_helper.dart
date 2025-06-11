import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'property_listings.db');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createAuthTables(db);
      await _createFormSubmissionTables(db);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create property listing tables
    await db.execute('''
      CREATE TABLE residential_properties (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        location TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        category TEXT NOT NULL,
        bedrooms INTEGER,
        bathrooms INTEGER,
        area REAL,
        description TEXT,
        features TEXT,
        isFeatured INTEGER DEFAULT 0,
        status TEXT DEFAULT 'for_sale',
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE commercial_properties (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        location TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        propertyType TEXT NOT NULL,
        area REAL,
        description TEXT,
        features TEXT,
        isFeatured INTEGER DEFAULT 0,
        status TEXT DEFAULT 'for_sale',
        floors INTEGER,
        parkingSpaces INTEGER,
        yearBuilt TEXT,
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE land_properties (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        location TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        landType TEXT NOT NULL,
        area REAL,
        areaUnit TEXT,
        description TEXT,
        features TEXT,
        isFeatured INTEGER DEFAULT 0,
        status TEXT DEFAULT 'for_sale',
        titleDocument TEXT,
        surveyed INTEGER,
        zoning TEXT,
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE material_properties (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        location TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        materialType TEXT NOT NULL,
        quantity TEXT,
        description TEXT,
        features TEXT,
        isFeatured INTEGER DEFAULT 0,
        status TEXT DEFAULT 'available',
        condition TEXT,
        brand TEXT,
        warranty TEXT,
        user_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    // Create authentication and form submission tables
    await _createAuthTables(db);
    await _createFormSubmissionTables(db);
    
    // Insert initial sample data
    await _insertInitialData(db);
  }

  Future<void> _createAuthTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        phone_number TEXT,
        whatsapp_link TEXT,
        avatar_url TEXT,
        user_type TEXT DEFAULT 'regular',
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        session_token TEXT NOT NULL,
        expires_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createFormSubmissionTables(Database db) async {
    await db.execute('''
      CREATE TABLE form_submissions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        price TEXT NOT NULL,
        market_value TEXT,
        location TEXT NOT NULL,
        latitude TEXT,
        longitude TEXT,
        whatsapp_number TEXT,
        whatsapp_link TEXT,
        status TEXT DEFAULT 'Available',
        terms_and_conditions TEXT,
        is_urgent INTEGER DEFAULT 0,
        target_demography INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE form_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        form_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        is_main INTEGER DEFAULT 0,
        display_order INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (form_id) REFERENCES form_submissions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE form_features (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        form_id INTEGER NOT NULL,
        feature_type TEXT NOT NULL,
        feature_value TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (form_id) REFERENCES form_submissions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE demographic_targets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        form_id INTEGER NOT NULL,
        countries TEXT,
        states TEXT,
        lgas TEXT,
        age_group TEXT DEFAULT 'All',
        social_class TEXT DEFAULT 'All',
        occupations TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (form_id) REFERENCES form_submissions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE urgency_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        form_id INTEGER NOT NULL,
        reason TEXT,
        deadline TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (form_id) REFERENCES form_submissions (id) ON DELETE CASCADE
      )
    ''');
  }

  // Password hashing
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Authentication Methods
  Future<Map<String, dynamic>?> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? whatsappLink,
  }) async {
    try {
      final db = await database;
      
      // Check if email already exists
      final existingUser = await getUserByEmail(email);
      if (existingUser != null) {
        return {'error': 'Email already registered'};
      }
      
      final now = DateTime.now().toIso8601String();
      final passwordHash = _hashPassword(password);
      
      final userId = await db.insert('users', {
        'email': email,
        'password_hash': passwordHash,
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'whatsapp_link': whatsappLink ?? 'https://wa.me/${phoneNumber.replaceAll(RegExp(r'[^0-9]'), '')}',
        'user_type': 'regular',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
      });
      
      if (userId > 0) {
        return await getUserById(userId);
      } else {
        return {'error': 'Failed to create user'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final db = await database;
      final passwordHash = _hashPassword(password);
      
      final List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'email = ? AND password_hash = ? AND is_active = 1',
        whereArgs: [email, passwordHash],
      );
      
      if (users.isNotEmpty) {
        final user = users.first;
        
        if (rememberMe) {
          final now = DateTime.now();
          final expiresAt = now.add(const Duration(days: 30)).toIso8601String();
          
          await db.insert('user_sessions', {
            'user_id': user['id'],
            'session_token': _generateSessionToken(),
            'expires_at': expiresAt,
            'created_at': now.toIso8601String(),
          });
        }
        
        return user;
      } else {
        return {'error': 'Invalid email or password'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'id = ? AND is_active = 1',
      whereArgs: [userId],
    );
    
    return users.isNotEmpty ? users.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ? AND is_active = 1',
      whereArgs: [email],
    );
    
    return users.isNotEmpty ? users.first : null;
  }

  String _generateSessionToken() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(random);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Property CRUD Operations

  // Residential Properties
  Future<int> insertResidentialProperty(Map<String, dynamic> property) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    property['created_at'] = now;
    property['updated_at'] = now;
    
    return await db.insert('residential_properties', property);
  }

  Future<List<Map<String, dynamic>>> getResidentialProperties({
    int? limit,
    bool? featuredOnly,
    int? userId,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (featuredOnly == true) {
      whereClause = 'isFeatured = 1';
      whereArgs.add(1);
    }

    if (userId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'user_id = ?';
      whereArgs.add(userId);
    }

    return await db.query(
      'residential_properties',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // Commercial Properties
  Future<int> insertCommercialProperty(Map<String, dynamic> property) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    property['created_at'] = now;
    property['updated_at'] = now;
    
    return await db.insert('commercial_properties', property);
  }

  Future<List<Map<String, dynamic>>> getCommercialProperties({
    int? limit,
    bool? featuredOnly,
    int? userId,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (featuredOnly == true) {
      whereClause = 'isFeatured = 1';
      whereArgs.add(1);
    }

    if (userId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'user_id = ?';
      whereArgs.add(userId);
    }

    return await db.query(
      'commercial_properties',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // Land Properties
  Future<int> insertLandProperty(Map<String, dynamic> property) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    property['created_at'] = now;
    property['updated_at'] = now;
    
    return await db.insert('land_properties', property);
  }

  Future<List<Map<String, dynamic>>> getLandProperties({
    int? limit,
    bool? featuredOnly,
    int? userId,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (featuredOnly == true) {
      whereClause = 'isFeatured = 1';
      whereArgs.add(1);
    }

    if (userId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'user_id = ?';
      whereArgs.add(userId);
    }

    return await db.query(
      'land_properties',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // Material Properties
  Future<int> insertMaterialProperty(Map<String, dynamic> property) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    property['created_at'] = now;
    property['updated_at'] = now;
    
    return await db.insert('material_properties', property);
  }

  Future<List<Map<String, dynamic>>> getMaterialProperties({
    int? limit,
    bool? featuredOnly,
    int? userId,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (featuredOnly == true) {
      whereClause = 'isFeatured = 1';
      whereArgs.add(1);
    }

    if (userId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'user_id = ?';
      whereArgs.add(userId);
    }

    return await db.query(
      'material_properties',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // NEW METHODS FOR FEATURED PROPERTIES

  // Get featured properties by category
  Future<List<Map<String, dynamic>>> getFeaturedPropertiesByCategory(String category, {required int limit}) async {
    final db = await database;
    
    String tableName;
    switch (category.toLowerCase()) {
      case 'residential':
        tableName = 'residential_properties';
        break;
      case 'commercial':
        tableName = 'commercial_properties';
        break;
      case 'land':
        tableName = 'land_properties';
        break;
      case 'material':
        tableName = 'material_properties';
        break;
      default:
        return [];
    }

    try {
      return await db.query(
        tableName,
        where: 'isFeatured = 1',
        orderBy: 'created_at DESC',
        limit: limit,
      );
    } catch (e) {
      print('Error getting featured properties for $category: $e');
      return [];
    }
  }

  // Get recent properties by category (fallback when no featured properties)
  Future<List<Map<String, dynamic>>> getRecentPropertiesByCategory(String category, {required int limit}) async {
    final db = await database;
    
    String tableName;
    switch (category.toLowerCase()) {
      case 'residential':
        tableName = 'residential_properties';
        break;
      case 'commercial':
        tableName = 'commercial_properties';
        break;
      case 'land':
        tableName = 'land_properties';
        break;
      case 'material':
        tableName = 'material_properties';
        break;
      default:
        return [];
    }

    try {
      return await db.query(
        tableName,
        orderBy: 'created_at DESC',
        limit: limit,
      );
    } catch (e) {
      print('Error getting recent properties for $category: $e');
      return [];
    }
  }

  // Get all featured properties across all categories
  Future<List<Map<String, dynamic>>> getAllFeaturedProperties({int limit = 20}) async {
    final db = await database;
    
    try {
      List<Map<String, dynamic>> allFeatured = [];
      
      // Get featured from each category
      final residential = await db.query(
        'residential_properties',
        where: 'isFeatured = 1',
        orderBy: 'created_at DESC',
        limit: limit ~/ 4,
      );
      
      final commercial = await db.query(
        'commercial_properties',
        where: 'isFeatured = 1',
        orderBy: 'created_at DESC',
        limit: limit ~/ 4,
      );
      
      final land = await db.query(
        'land_properties',
        where: 'isFeatured = 1',
        orderBy: 'created_at DESC',
        limit: limit ~/ 4,
      );
      
      final material = await db.query(
        'material_properties',
        where: 'isFeatured = 1',
        orderBy: 'created_at DESC',
        limit: limit ~/ 4,
      );
      
      // Add category field to each property
      for (var prop in residential) {
        prop['category'] = 'residential';
        allFeatured.add(prop);
      }
      
      for (var prop in commercial) {
        prop['category'] = 'commercial';
        allFeatured.add(prop);
      }
      
      for (var prop in land) {
        prop['category'] = 'land';
        allFeatured.add(prop);
      }
      
      for (var prop in material) {
        prop['category'] = 'material';
        allFeatured.add(prop);
      }
      
      // Sort by created_at and limit
      allFeatured.sort((a, b) => b['created_at'].compareTo(a['created_at']));
      
      return allFeatured.take(limit).toList();
    } catch (e) {
      print('Error getting all featured properties: $e');
      return [];
    }
  }

  // Form Submission Methods
  Future<int> submitForm(Map<String, dynamic> formData) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    final Map<String, dynamic> dbFormData = {
      'user_id': formData['userId'],
      'category': formData['category'],
      'type': formData['type'],
      'title': formData['title'],
      'description': formData['description'],
      'price': formData['price'],
      'market_value': formData['marketValue'],
      'location': formData['location'],
      'latitude': formData['latitude'],
      'longitude': formData['longitude'],
      'whatsapp_number': formData['whatsappNumber'],
      'whatsapp_link': formData['whatsappLink'],
      'status': formData['status'] ?? 'Available',
      'terms_and_conditions': formData['termsAndConditions'],
      'is_urgent': formData['isUrgent'] == true ? 1 : 0,
      'target_demography': formData['targetDemography'] == true ? 1 : 0,
      'created_at': now,
      'updated_at': now,
    };
    
    final formId = await db.insert('form_submissions', dbFormData);
    
    // Insert form images
    final List<String> images = List<String>.from(formData['images'] ?? []);
    for (int i = 0; i < images.length; i++) {
      await db.insert('form_images', {
        'form_id': formId,
        'image_path': images[i],
        'is_main': i == 0 ? 1 : 0,
        'display_order': i + 1,
        'created_at': now,
      });
    }
    
    // Insert form features based on type
    final Map<String, String> features = {};
    
    if (formData['type'] == 'residential') {
      features['bedrooms'] = formData['bedrooms']?.toString() ?? '0';
      features['bathrooms'] = formData['bathrooms']?.toString() ?? '0';
      features['toilets'] = formData['toilets']?.toString() ?? '0';
      features['parking_spaces'] = formData['parkingSpaces']?.toString() ?? '0';
    } else if (formData['type'] == 'commercial') {
      features['has_internet'] = formData['hasInternet']?.toString() ?? 'false';
      features['has_electricity'] = formData['hasElectricity']?.toString() ?? 'false';
    } else if (formData['type'] == 'land') {
      features['land_title'] = formData['landTitle']?.toString() ?? '';
      features['land_size'] = formData['landSize']?.toString() ?? '0';
    } else if (formData['type'] == 'material') {
      features['quantity'] = formData['quantity']?.toString() ?? '0';
      features['condition'] = formData['condition']?.toString() ?? 'New';
    }
    
    for (final entry in features.entries) {
      await db.insert('form_features', {
        'form_id': formId,
        'feature_type': entry.key,
        'feature_value': entry.value,
        'created_at': now,
      });
    }
    
    return formId;
  }

  Future<List<Map<String, dynamic>>> getSubmissionsByUser(int userId) async {
    final db = await database;
    return await db.query(
      'form_submissions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  Future<Map<String, dynamic>?> getSubmissionWithDetails(int formId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> submissions = await db.query(
      'form_submissions',
      where: 'id = ?',
      whereArgs: [formId],
    );
    
    if (submissions.isEmpty) {
      return null;
    }
    
    final submission = submissions.first;
    
    final List<Map<String, dynamic>> images = await db.query(
      'form_images',
      where: 'form_id = ?',
      whereArgs: [formId],
      orderBy: 'display_order',
    );
    
    final List<Map<String, dynamic>> features = await db.query(
      'form_features',
      where: 'form_id = ?',
      whereArgs: [formId],
    );
    
    submission['images'] = images;
    submission['features'] = features;
    
    return submission;
  }

  Future<bool> updateSubmissionStatus(int formId, String status) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    final count = await db.update(
      'form_submissions',
      {
        'status': status,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [formId],
    );
    
    return count > 0;
  }

  Future<bool> deleteSubmission(int formId) async {
    final db = await database;
    
    final count = await db.delete(
      'form_submissions',
      where: 'id = ?',
      whereArgs: [formId],
    );
    
    return count > 0;
  }

  // Utility methods
  String _listToJson(dynamic list) {
    if (list == null) return '[]';
    if (list is List) {
      return jsonEncode(list);
    }
    return '[]';
  }

  // Insert sample data with some featured properties
  Future<void> _insertInitialData(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    // Insert residential properties with some featured
    final residentialData = [
      {
        'title': 'Modern 3 Bedroom Apartment',
        'price': 25000000.0,
        'location': 'Lekki, Lagos',
        'imageUrl': 'assets/images/residential1.jpg',
        'category': 'apartment',
        'bedrooms': 3,
        'bathrooms': 2,
        'area': 120.5,
        'description': 'A beautifully designed modern apartment with contemporary finishes and stunning city views.',
        'features': 'Swimming Pool,Gym,24/7 Security,Parking Space,Generator',
        'isFeatured': 1, // Featured
        'status': 'for_sale',
        'user_id': null,
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Luxury Villa with Pool',
        'price': 75000000.0,
        'location': 'Ikoyi, Lagos',
        'imageUrl': 'assets/images/residential2.jpg',
        'category': 'villa',
        'bedrooms': 5,
        'bathrooms': 4,
        'area': 350.0,
        'description': 'Luxurious villa featuring private pool, garden, and high-end finishes throughout.',
        'features': 'Private Pool,Garden,Maid\'s Quarters,Garage,Security System',
        'isFeatured': 1, // Featured
        'status': 'for_sale',
        'user_id': null,
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Cozy 2 Bedroom Flat',
        'price': 15000000.0,
        'location': 'Yaba, Lagos',
        'imageUrl': 'assets/images/residential3.jpg',
        'category': 'flat',
        'bedrooms': 2,
        'bathrooms': 1,
        'area': 85.0,
        'description': 'Perfect starter home in a vibrant neighborhood with easy access to amenities.',
        'features': 'Fitted Kitchen,Wardrobe,Tile Flooring,Water Supply',
        'isFeatured': 1, // Featured
        'status': 'for_sale',
        'user_id': null,
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Executive 4 Bedroom Duplex',
        'price': 45000000.0,
        'location': 'Ajah, Lagos',
        'imageUrl': 'assets/images/residential4.jpg',
        'category': 'duplex',
        'bedrooms': 4,
        'bathrooms': 3,
        'area': 200.0,
        'description': 'Spacious duplex with modern amenities in a gated community.',
        'features': 'Gated Community,Parking,Generator,Water Treatment,CCTV',
        'isFeatured': 0, // Not featured
        'status': 'for_sale',
        'user_id': null,
        'created_at': now,
        'updated_at': now,
      },
    ];

    // Insert commercial properties with some featured
    final commercialData = [
      {
        'title': 'Premium Office Space',
        'price': 45000000.0,
        'location': 'Victoria Island, Lagos',
        'imageUrl': 'assets/images/commercial1.jpg',
        'propertyType': 'office',
        'area': 250.0,
        'description': 'Modern office space with stunning views and premium finishes in the heart of Victoria Island.',
        'features': '24/7 Security,Elevator,Air Conditioning,Generator,Reception Area',
        'isFeatured': 1, // Featured
        'status': 'for_sale',
        'floors': 3,
        'parkingSpaces': 20,
        'yearBuilt': '2020',
        'user_id': null,
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Retail Shop in Mall',
        'price': 35000000.0,
        'location': 'Ikeja, Lagos',
        'imageUrl': 'assets/images/commercial2.jpg',
        'propertyType': 'retail',
        'area': 150.0,
        'description': 'Prime retail space in busy shopping mall with high foot traffic.',
        'features': 'High Foot Traffic,Mall Security,Parking Available,Storage Space',
        'isFeatured': 1, // Featured
        'status': 'for_sale',
        'floors': 1,
        'parkingSpaces': 50,
        'yearBuilt': '2018',
        'user_id': null,
        'created_at': now,
        'updated_at': now,
      },
    ];

    // Insert land properties with some featured
    final landData = [
      {
        'title': 'Prime Residential Plot',
        'price': 18000000.0,
        'location': 'Ajah, Lagos',
        'imageUrl': 'assets/images/land1.png',
        'landType': 'residential',
        'area': 500.0,
        'areaUnit': 'sqm',
        'description': 'Well-located residential plot in a developing area with good access roads and infrastructure.',
        'features': 'Good Access Road,Electricity Available,Water Source,Survey Plan',
        'isFeatured': 1, // Featured
        'status': 'for_sale',
        'titleDocument': 'Certificate of Occupancy',
        'surveyed': 1,
        'zoning': 'Residential',
        'user_id': null,
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Commercial Land',
        'price': 65000000.0,
        'location': 'Ikeja, Lagos',
        'imageUrl': 'assets/images/land2.jpg',
        'landType': 'commercial',
        'area': 1200.0,
        'areaUnit': 'sqm',
        'description': 'Strategic commercial land perfect for shopping centers, offices, or mixed-use development.',
        'features': 'Corner Piece,High Traffic Area,Approved Building Plan,Utilities Available',
        'isFeatured': 1, // Featured
        'status': 'for_sale',
        'titleDocument': 'Deed of Assignment',
        'surveyed': 1,
        'zoning': 'Commercial',
        'user_id': null,
        'created_at': now,
        'updated_at': now,
      },
    ];

    // Insert material properties with some featured
    final materialData = [
      {
        'title': 'Premium Cement',
        'price': 150000.0,
        'location': 'Nationwide Delivery',
        'imageUrl': 'assets/images/material1.jpg',
        'materialType': 'building',
        'quantity': '100 bags',
        'description': 'High-quality cement suitable for all construction needs with fast setting time.',
        'features': 'Fast Setting,Weather Resistant,High Strength,Bulk Discount Available',
        'isFeatured': 1, // Featured
        'status': 'available',
        'condition': 'new',
        'brand': 'Dangote',
        'warranty': '30 days',
        'user_id': null,
        'created_at': now,
        'updated_at': now,
      },
      {
        'title': 'Sand (30 tons)',
        'price': 85000.0,
        'location': 'Lagos Mainland',
        'imageUrl': 'assets/images/material2.jpg',
        'materialType': 'building',
        'quantity': '30 tons',
        'description': 'Clean, washed sand suitable for construction and landscaping projects.',
        'features': 'Washed,Screened,Free Delivery,Quality Tested',
        'isFeatured': 1, // Featured
        'status': 'available',
        'condition': 'new',
        'brand': null,
        'warranty': null,
        'user_id': null,
        'created_at': now,
        'updated_at': now,
      },
    ];

    // Insert data into tables
    for (final property in residentialData) {
      await db.insert('residential_properties', property);
    }

    for (final property in commercialData) {
      await db.insert('commercial_properties', property);
    }

    for (final property in landData) {
      await db.insert('land_properties', property);
    }

    for (final property in materialData) {
      await db.insert('material_properties', property);
    }
    
    print('Sample data with featured properties inserted successfully');
  }

  // Filter methods for properties
  Future<List<Map<String, dynamic>>> getResidentialPropertiesByFilter({
    String? status,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (status != null && status != 'all') {
      whereClause += 'status = ?';
      whereArgs.add(status);
    }

    if (category != null && category != 'all') {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'category = ?';
      whereArgs.add(category);
    }

    if (minPrice != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'price >= ?';
      whereArgs.add(minPrice);
    }

    if (maxPrice != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'price <= ?';
      whereArgs.add(maxPrice);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += '(title LIKE ? OR location LIKE ?)';
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
    }

    return await db.query(
      'residential_properties',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getCommercialPropertiesByFilter({
    String? status,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (status != null && status != 'all') {
      whereClause += 'status = ?';
      whereArgs.add(status);
    }

    if (propertyType != null && propertyType != 'all') {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'propertyType = ?';
      whereArgs.add(propertyType);
    }

    if (minPrice != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'price >= ?';
      whereArgs.add(minPrice);
    }

    if (maxPrice != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'price <= ?';
      whereArgs.add(maxPrice);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += '(title LIKE ? OR location LIKE ?)';
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
    }

    return await db.query(
      'commercial_properties',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getLandPropertiesByFilter({
    String? landType,
    String? areaFilter,
    String? searchQuery,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (landType != null && landType != 'all') {
      whereClause += 'landType = ?';
      whereArgs.add(landType);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += '(title LIKE ? OR location LIKE ?)';
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
    }

    return await db.query(
      'land_properties',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getMaterialPropertiesByFilter({
    String? materialType,
    String? condition,
    String? searchQuery,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (materialType != null && materialType != 'all') {
      whereClause += 'materialType = ?';
      whereArgs.add(materialType);
    }

    if (condition != null && condition != 'all') {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'condition = ?';
      whereArgs.add(condition);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += '(title LIKE ? OR location LIKE ?)';
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
    }

    return await db.query(
      'material_properties',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'created_at DESC',
    );
  }

  // Database management
  Future<void> resetDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
    
    String path = join(await getDatabasesPath(), 'property_listings.db');
    await deleteDatabase(path);
  }

  bool isDatabaseInitialized() {
    return _database != null;
  }

  // Get or create default user (for demo purposes - you can remove this if not needed)
  Future<int> getOrCreateDefaultUser() async {
    final db = await database;
    
    // Try to get existing user
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['demo@mipripity.com'],
    );
    
    if (users.isNotEmpty) {
      return users.first['id'] as int;
    }
    
    // Create default user if not found
    final now = DateTime.now().toIso8601String();
    final passwordHash = _hashPassword('password123');
    
    return await db.insert('users', {
      'email': 'demo@mipripity.com',
      'password_hash': passwordHash,
      'first_name': 'Demo',
      'last_name': 'User',
      'phone_number': '+2348000000000',
      'whatsapp_link': 'https://wa.me/2348000000000',
      'user_type': 'regular',
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });
  }
}
