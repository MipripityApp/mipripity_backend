import 'package:flutter/material.dart';
import 'add_screen.dart'; // Import for NetworkSignalDisplay
import 'property_repository.dart';
import 'database_helper.dart';

class PropertyDetails extends StatefulWidget {
  final String propertyId;

  const PropertyDetails({
    super.key,
    required this.propertyId,
  });

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
  bool isFavorite = false;
  int currentImageIndex = 0;
  final PageController _pageController = PageController();

  // Property data from SQLite database
  Map<String, dynamic>? propertyData;
  bool _isLoading = true;
  String? _error;
  
  // PropertyRepository instance
  final PropertyRepository _propertyRepository = PropertyRepository();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Sample property images
  final List<String> propertyImages = [
    'https://images.unsplash.com/photo-1580587771525-78b9dba3b914',
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
    'https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6',
    'https://images.unsplash.com/photo-1613977257363-707ba9348227',
  ];

  // Sample agent data
  final Map<String, dynamic> agentData = {
    'id': 'a1',
    'name': 'John Okafor',
    'rating': 4.8,
    'properties': 24,
    'experience': '5 years',
    'image': 'https://randomuser.me/api/portraits/men/32.jpg',
    'phone': '+234 801 234 5678',
    'email': 'john.okafor@example.com',
  };

  // Similar properties from SQLite
  List<Map<String, dynamic>> similarProperties = [];

  @override
  void initState() {
    super.initState();
    _fetchPropertyData();
    _fetchSimilarProperties();
  }
  
  // Fetch property data from SQLite database
  Future<void> _fetchPropertyData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      // Check if ID is an integer for database lookup
      final int? intId = int.tryParse(widget.propertyId);
      Map<String, dynamic>? property;
      
      if (intId != null) {
        // Try to get form submission by ID using private method approach
        // Since we can't use _getFormSubmissionById directly, we'll try to get property from each category
        
        // First try getting properties by ID from each category
        final db = await _databaseHelper.database;
        final List<Map<String, dynamic>> submissions = await db.query(
          'form_submissions',
          where: 'id = ?',
          whereArgs: [intId],
        );
        
        if (submissions.isNotEmpty) {
          // Get detailed submission with features, images, etc.
          final submission = submissions.first;
          
          // Get images
          final List<Map<String, dynamic>> images = await db.query(
            'form_images',
            where: 'form_id = ?',
            whereArgs: [intId],
          );
          
          // Get features
          final List<Map<String, dynamic>> features = await db.query(
            'form_features',
            where: 'form_id = ?',
            whereArgs: [intId],
          );
          
          // Build complete submission
          final Map<String, dynamic> formSubmission = Map<String, dynamic>.from(submission);
          formSubmission['images'] = images;
          formSubmission['features'] = features;
          
          setState(() {
            propertyData = _convertFormSubmissionToPropertyData(formSubmission);
            _isLoading = false;
          });
          return;
        }
      }
      
      // Try residential properties
      final residentialProperty = await _propertyRepository.getResidentialPropertyById(widget.propertyId);
      if (residentialProperty != null) {
        property = _convertResidentialToMap(residentialProperty);
        property['category'] = 'residential';
      }
      
      // Try commercial properties
      if (property == null) {
        final commercialProperty = await _propertyRepository.getCommercialPropertyById(widget.propertyId);
        if (commercialProperty != null) {
          property = _convertCommercialToMap(commercialProperty);
          property['category'] = 'commercial';
        }
      }
      
      // Try land properties
      if (property == null) {
        final landProperty = await _propertyRepository.getLandPropertyById(widget.propertyId);
        if (landProperty != null) {
          property = _convertLandToMap(landProperty);
          property['category'] = 'land';
        }
      }
      
      // Try material properties
      if (property == null) {
        final materialProperty = await _propertyRepository.getMaterialPropertyById(widget.propertyId);
        if (materialProperty != null) {
          property = _convertMaterialToMap(materialProperty);
          property['category'] = 'material';
        }
      }
      
      if (property != null) {
        setState(() {
          propertyData = property;
          _isLoading = false;
        });
      } else {
        // If still not found, use fallback mock data based on ID pattern
        _useFallbackData();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        // Use fallback data in case of error
        _useFallbackData();
      });
    }
  }
  
  // Fallback to mock data if property is not found in the database
  void _useFallbackData() {
    if (widget.propertyId.startsWith('p')) {
      // Regular property fallback
      propertyData = {
        'id': widget.propertyId,
        'title': '3 Bedroom Apartment',
        'type': 'Apartment',
        'price': '₦45,000,000',
        'location': 'Lekki Phase 1',
        'address': '123 Ocean View Road, Lekki Phase 1, Lagos',
        'bedrooms': 3,
        'bathrooms': 2,
        'area': '120 sqm',
        'description': 'This beautiful 3-bedroom apartment offers stunning ocean views and modern amenities. Located in the heart of Lekki Phase 1, it features a spacious living area, modern kitchen, and balcony overlooking the Atlantic Ocean. The property includes 24/7 security, backup power, and water supply.',
        'features': [
          'Swimming Pool',
          'Gym',
          'Security',
          '24/7 Electricity',
          'Parking Space',
          'Air Conditioning',
        ],
        'isVerified': true,
        'yearBuilt': '2020',
        'propertyID': 'LK-${widget.propertyId}',
        'category': 'residential',
        'latitude': '6.4281',
        'longitude': '3.4216',
      };
    } else if (widget.propertyId.startsWith('l')) {
      // Land property fallback
      propertyData = {
        'id': widget.propertyId,
        'title': 'Prime Land in Lekki Phase 1',
        'type': 'Land',
        'price': '₦25,000,000',
        'location': 'Lekki Phase 1',
        'address': 'Plot 45, Ocean View Estate, Lekki Phase 1, Lagos',
        'area': '500 sqm',
        'description': 'Prime land for sale in the prestigious Lekki Phase 1 area. This plot is located in a secure estate with excellent infrastructure including paved roads, drainage systems, and street lighting. The land has a C of O title document and is ready for immediate development.',
        'features': [
          'C of O Document',
          'Dry Land',
          'Gated Estate',
          'Good Road Network',
          'Electricity',
        ],
        'isVerified': true,
        'propertyID': 'LL-${widget.propertyId}',
        'category': 'land',
        'latitude': '6.4365',
        'longitude': '3.4849',
      };
    } else if (widget.propertyId.startsWith('c')) {
      // Commercial property fallback
      propertyData = {
        'id': widget.propertyId,
        'title': 'Office Space in Victoria Island',
        'type': 'Commercial',
        'price': '₦75,000,000',
        'location': 'Victoria Island',
        'address': '45 Adeola Odeku Street, Victoria Island, Lagos',
        'area': '250 sqm',
        'description': 'Prime office space in the heart of Victoria Island business district. This modern office features open floor plans, meeting rooms, and reception area. The building has 24/7 security, backup power, central air conditioning, and ample parking space.',
        'features': [
          'Reception Area',
          'Meeting Rooms',
          'High-speed Internet',
          '24/7 Security',
          'Backup Power',
          'Parking Space',
        ],
        'isVerified': true,
        'yearBuilt': '2018',
        'propertyID': 'VC-${widget.propertyId}',
        'category': 'commercial',
        'latitude': '6.4281',
        'longitude': '3.4216',
      };
    } else if (widget.propertyId.startsWith('m')) {
      // Material property fallback
      propertyData = {
        'id': widget.propertyId,
        'title': 'Premium Building Materials',
        'type': 'Material',
        'price': '₦2,500,000',
        'location': 'Ikeja',
        'address': '78 Construction Avenue, Ikeja, Lagos',
        'area': 'N/A',
        'description': 'High-quality building materials including cement, tiles, and roofing materials. All materials are brand new and from top manufacturers. Bulk purchase discounts available.',
        'features': [
          'Brand New',
          'Top Quality',
          'Bulk Discounts',
          'Delivery Available',
          'Warranty Included',
        ],
        'isVerified': true,
        'propertyID': 'MT-${widget.propertyId}',
        'category': 'material',
        'quantity': '500 units',
        'condition': 'New',
      };
    } else {
      // Default property data fallback
      propertyData = {
        'id': widget.propertyId,
        'title': 'Property in Lagos',
        'type': 'Property',
        'price': '₦30,000,000',
        'location': 'Lagos',
        'address': 'Lagos, Nigeria',
        'area': '200 sqm',
        'description': 'A beautiful property in Lagos with modern amenities.',
        'features': [
          'Security',
          '24/7 Electricity',
          'Parking Space',
        ],
        'isVerified': false,
        'propertyID': 'PR-${widget.propertyId}',
        'category': 'residential',
        'latitude': '',
        'longitude': '',
      };
    }
  }
  
  // Convert form submission to property data format
  Map<String, dynamic> _convertFormSubmissionToPropertyData(Map<String, dynamic> submission) {
    final category = submission['category'] as String? ?? 'unknown';
    final List<String> features = [];
    
    // Extract features based on category
    if (category == 'residential') {
      if (submission['bedrooms'] != null) features.add('${submission['bedrooms']} Bedrooms');
      if (submission['bathrooms'] != null) features.add('${submission['bathrooms']} Bathrooms');
      if (submission['toilets'] != null) features.add('${submission['toilets']} Toilets');
      if (submission['parkingSpaces'] != null) features.add('${submission['parkingSpaces']} Parking Spaces');
    } else if (category == 'commercial') {
      if (submission['hasInternet'] == 1) features.add('Internet Available');
      if (submission['hasElectricity'] == 1) features.add('24/7 Electricity');
    } else if (category == 'land') {
      if (submission['landTitle'] != null) features.add('${submission['landTitle']}');
      if (submission['landSize'] != null) features.add('${submission['landSize']} sqm');
    } else if (category == 'material') {
      if (submission['quantity'] != null) features.add('Quantity: ${submission['quantity']}');
      if (submission['condition'] != null) features.add('Condition: ${submission['condition']}');
    }
    
    // Add any additional features from the JSON
    if (submission['features'] != null) {
      try {
        final List<dynamic> additionalFeatures = submission['features'] is String 
            ? (submission['features'] as String).split(',') 
            : (submission['features'] as List<dynamic>);
        
        for (final feature in additionalFeatures) {
          if (feature is String && feature.isNotEmpty) {
            features.add(feature);
          }
        }
      } catch (e) {
        print('Error parsing features: $e');
      }
    }
    
    // Format price string
    final price = submission['price'] != null 
        ? '₦${double.parse(submission['price'].toString()).toStringAsFixed(2)}'
        : '₦0.00';
    
    return {
      'id': submission['id'].toString(),
      'title': submission['title'] ?? 'Untitled Property',
      'type': _getCategoryType(category),
      'price': price,
      'location': submission['location'] ?? 'Unknown Location',
      'address': submission['address'] ?? submission['location'] ?? 'Unknown Address',
      'description': submission['description'] ?? 'No description available.',
      'features': features,
      'isVerified': submission['isVerified'] == 1,
      'propertyID': 'FS-${submission['id']}',
      'category': category,
      'latitude': submission['latitude']?.toString() ?? '',
      'longitude': submission['longitude']?.toString() ?? '',
      // Add category-specific fields
      'bedrooms': submission['bedrooms'],
      'bathrooms': submission['bathrooms'],
      'area': submission['area'] ?? submission['landSize']?.toString(),
      'toilets': submission['toilets'],
      'parkingSpaces': submission['parkingSpaces'],
      'hasInternet': submission['hasInternet'] == 1,
      'hasElectricity': submission['hasElectricity'] == 1,
      'landTitle': submission['landTitle'],
      'landSize': submission['landSize'],
      'quantity': submission['quantity'],
      'condition': submission['condition'],
      // User details
      'userId': submission['userId'],
      'listerName': submission['listerName'] ?? 'Unknown',
      'listerContact': submission['listerContact'],
      'listerEmail': submission['listerEmail'],
      'listerWhatsapp': submission['listerWhatsapp'],
    };
  }
  
  // Get display type based on category
  String _getCategoryType(String category) {
    switch (category) {
      case 'residential':
        return 'Residential';
      case 'commercial':
        return 'Commercial';
      case 'land':
        return 'Land';
      case 'material':
        return 'Material';
      default:
        return 'Property';
    }
  }
  
  // Helper methods to convert property objects to maps
  Map<String, dynamic> _convertResidentialToMap(PropertyListing property) {
    return {
      'id': property.id,
      'title': property.title,
      'price': property.price.toString(),
      'location': property.location,
      'imageUrl': property.imageUrl,
      'bedrooms': property.bedrooms,
      'bathrooms': property.bathrooms,
      'area': property.area?.toString(),
      'description': property.description,
      'features': property.features,
      'isFeatured': property.isFeatured,
      'status': property.status,
      'type': 'Residential',
    };
  }
  
  Map<String, dynamic> _convertCommercialToMap(CommercialProperty property) {
    return {
      'id': property.id,
      'title': property.title,
      'price': property.price.toString(),
      'location': property.location,
      'imageUrl': property.imageUrl,
      'propertyType': property.propertyType,
      'area': property.area.toString(),
      'description': property.description,
      'features': property.features,
      'isFeatured': property.isFeatured,
      'status': property.status,
      'floors': property.floors,
      'parkingSpaces': property.parkingSpaces,
      'yearBuilt': property.yearBuilt,
      'type': 'Commercial',
    };
  }
  
  Map<String, dynamic> _convertLandToMap(LandProperty property) {
    return {
      'id': property.id,
      'title': property.title,
      'price': property.price.toString(),
      'location': property.location,
      'imageUrl': property.imageUrl,
      'landType': property.landType,
      'area': property.area.toString(),
      'areaUnit': property.areaUnit,
      'description': property.description,
      'features': property.features,
      'isFeatured': property.isFeatured,
      'status': property.status,
      'titleDocument': property.titleDocument,
      'surveyed': property.surveyed,
      'zoning': property.zoning,
      'type': 'Land',
    };
  }
  
  Map<String, dynamic> _convertMaterialToMap(MaterialProperty property) {
    return {
      'id': property.id,
      'title': property.title,
      'price': property.price.toString(),
      'location': property.location,
      'imageUrl': property.imageUrl,
      'materialType': property.materialType,
      'quantity': property.quantity,
      'description': property.description,
      'features': property.features,
      'isFeatured': property.isFeatured,
      'status': property.status,
      'condition': property.condition,
      'brand': property.brand,
      'warranty': property.warranty,
      'type': 'Material',
    };
  }

  // Fetch similar properties from SQLite database
  Future<void> _fetchSimilarProperties() async {
    try {
      // Get current property category from property data
      final category = propertyData?['category'] ?? '';
      
      if (category.isEmpty) return;
      
      // Get similar properties based on category
      List<Map<String, dynamic>> properties = [];
      
      switch (category) {
        case 'residential':
          final residentialProps = await _propertyRepository.getResidentialProperties();
          properties = residentialProps.map((p) => _convertResidentialToMap(p)).toList();
          break;
        case 'commercial':
          final commercialProps = await _propertyRepository.getCommercialProperties();
          properties = commercialProps.map((p) => _convertCommercialToMap(p)).toList();
          break;
        case 'land':
          final landProps = await _propertyRepository.getLandProperties();
          properties = landProps.map((p) => _convertLandToMap(p)).toList();
          break;
        case 'material':
          final materialProps = await _propertyRepository.getMaterialProperties();
          properties = materialProps.map((p) => _convertMaterialToMap(p)).toList();
          break;
        default:
          // Get all properties and filter by category
          final allProps = await _propertyRepository.getAllProperties();
          properties = allProps
            .where((prop) => prop.category.toLowerCase() == category.toLowerCase())
            .map((prop) => {
              'id': prop.id,
              'title': prop.title,
              'price': prop.price.toString(),
              'location': prop.location,
              'type': prop.category,
              'description': prop.description,
              'imageUrl': prop.listingImage,
              'bedrooms': prop.bedrooms,
              'bathrooms': prop.bathrooms,
            })
            .toList();
          break;
      }
      
      // Convert to similar properties format and exclude current property
      final currentId = widget.propertyId;
      similarProperties = properties
          .where((p) => p['id'].toString() != currentId)
          .map((p) => {
            'id': p['id'].toString(),
            'title': p['title'] ?? 'Untitled Property',
            'type': p['type'] ?? _getCategoryType(category),
            'price': p['price'] is String ? p['price'] : '₦${p['price']}',
            'location': p['location'] ?? 'Unknown Location',
            'bedrooms': p['bedrooms'],
            'bathrooms': p['bathrooms'],
            'area': p['area'] ?? p['landSize']?.toString() ?? 'N/A',
            'image': p['main_image_url'] ?? p['image_url'] ?? 'assets/images/${category}1.jpg',
          })
          .take(2) // Limit to 2 similar properties
          .toList();
      
      // If no properties found or only current property, use fallback
      if (similarProperties.isEmpty) {
        similarProperties = [
          {
            'id': 'p2',
            'title': 'Luxury Villa with Pool',
            'type': 'Villa',
            'price': '₦120,000,000',
            'location': 'Lekki Phase 1',
            'bedrooms': 5,
            'bathrooms': 6,
            'area': '350 sqm',
            'image': 'assets/images/residential2.jpg',
          },
          {
            'id': 'p3',
            'title': 'Commercial Space',
            'type': 'Commercial',
            'price': '₦80,000,000',
            'location': 'Lekki Phase 1',
            'area': '200 sqm',
            'image': 'assets/images/commercial1.jpg',
          },
        ];
      }
      
      setState(() {});
    } catch (e) {
      print('Error fetching similar properties: $e');
      // Use fallback similar properties
      similarProperties = [
        {
          'id': 'p2',
          'title': 'Luxury Villa with Pool',
          'type': 'Villa',
          'price': '₦120,000,000',
          'location': 'Lekki Phase 1',
          'bedrooms': 5,
          'bathrooms': 6,
          'area': '350 sqm',
          'image': 'assets/images/residential2.jpg',
        },
        {
          'id': 'p3',
          'title': 'Commercial Space',
          'type': 'Commercial',
          'price': '₦80,000,000',
          'location': 'Lekki Phase 1',
          'area': '200 sqm',
          'image': 'assets/images/commercial1.jpg',
        },
      ];
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    
    if (isFavorite) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${propertyData?['title']} added to favorites'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void handleSimilarPropertyClick(String propertyId) {
    Navigator.pushReplacementNamed(context, '/property-details/$propertyId');
  }

  void handleAgentClick(String agentId) {
    Navigator.pushNamed(context, '/agent-profile/$agentId');
  }

  void handleScheduleVisit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildScheduleVisitSheet(),
    );
  }

  void handleContactAgent() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildContactAgentSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Property Details'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF000080),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFF39322),
          ),
        ),
      );
    }
    
    if (propertyData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Property Details'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF000080),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Property not found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'The property you are looking for does not exist or has been removed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF000080),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image Slider
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image Slider
                  PageView.builder(
                    controller: _pageController,
                    itemCount: propertyImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        propertyImages[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  // Image Indicator
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        propertyImages.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentImageIndex == index
                                ? const Color(0xFFF39322)
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Image Counter
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${currentImageIndex + 1}/${propertyImages.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF000080)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : const Color(0xFF000080),
                  ),
                  onPressed: toggleFavorite,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Color(0xFF000080)),
                  onPressed: () {
                    // Share functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sharing this property...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Title and Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              propertyData?['title'] ?? 'Untitled Property',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF000080),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.place,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    propertyData?['address'] ?? propertyData?['location'] ?? 'Unknown Location',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            propertyData?['price'] ?? '₦0.00',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF39322),
                            ),
                          ),
                          if (propertyData?['type'] != 'Land')
                            Text(
                              'Negotiable',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Property Features
                  if (propertyData?['type'] != 'Land')
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeatureItem(
                            Icons.king_bed_outlined,
                            '${propertyData?['bedrooms'] ?? 0} Beds',
                          ),
                          _buildFeatureItem(
                            Icons.bathtub_outlined,
                            '${propertyData?['bathrooms'] ?? 0} Baths',
                          ),
                          _buildFeatureItem(
                            Icons.square_foot,
                            propertyData?['area'] ?? 'N/A',
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeatureItem(
                            Icons.square_foot,
                            propertyData?['area'] ?? propertyData?['landSize']?.toString() ?? 'N/A',
                          ),
                          _buildFeatureItem(
                            Icons.description_outlined,
                            propertyData?['landTitle'] ?? 'C of O',
                          ),
                          _buildFeatureItem(
                            Icons.location_city,
                            'Residential',
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Network Signal Display for property listings
                  if (_shouldShowNetworkSignal())
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Network Coverage',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000080),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: NetworkSignalDisplay(
                            latitude: double.tryParse(propertyData?['latitude'] ?? '') ?? 0,
                            longitude: double.tryParse(propertyData?['longitude'] ?? '') ?? 0,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000080),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    propertyData?['description'] ?? 'No description available.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Features
                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000080),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      (propertyData?['features'] as List<dynamic>?)?.length ?? 0,
                      (index) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          (propertyData?['features'] as List<dynamic>)[index].toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Property Details
                  const Text(
                    'Property Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000080),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildPropertyDetailRow('Property ID', propertyData?['propertyID'] ?? 'N/A'),
                        const Divider(height: 24),
                        _buildPropertyDetailRow('Property Type', propertyData?['type'] ?? 'N/A'),
                        const Divider(height: 24),
                        _buildPropertyDetailRow('Location', propertyData?['location'] ?? 'N/A'),
                        if (propertyData?.containsKey('yearBuilt') ?? false) ...[
                          const Divider(height: 24),
                          _buildPropertyDetailRow('Year Built', propertyData?['yearBuilt'] ?? 'N/A'),
                        ],
                        if (propertyData?.containsKey('quantity') ?? false) ...[
                          const Divider(height: 24),
                          _buildPropertyDetailRow('Quantity', propertyData?['quantity']?.toString() ?? 'N/A'),
                        ],
                        if (propertyData?.containsKey('condition') ?? false) ...[
                          const Divider(height: 24),
                          _buildPropertyDetailRow('Condition', propertyData?['condition'] ?? 'N/A'),
                        ],
                        const Divider(height: 24),
                        _buildPropertyDetailRow('Status', (propertyData?['isVerified'] == true) ? 'Verified' : 'Unverified'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Agent Information
                  const Text(
                    'Listed By',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000080),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => handleAgentClick(agentData['id']),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFF39322),
                                width: 2,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(agentData['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                propertyData?['listerName'] ?? agentData['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000080),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xFFF39322),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    agentData['rating'].toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '${agentData['experience']} exp.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => handleAgentClick(agentData['id']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000080),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'View Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Similar Properties
                  const Text(
                    'Similar Properties',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000080),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: similarProperties.length,
                      itemBuilder: (context, index) {
                        final property = similarProperties[index];
                        return GestureDetector(
                          onTap: () => handleSimilarPropertyClick(property['id']),
                          child: Container(
                            width: 200,
                            margin: EdgeInsets.only(
                              right: index != similarProperties.length - 1 ? 16 : 0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                      child: Image.asset(
                                        property['image'],
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 120,
                                            width: double.infinity,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF000080),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          property['type'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        property['title'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF000080),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.place,
                                            size: 12,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            property['location'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            property['price'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFF39322),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              if (property.containsKey('bedrooms'))
                                                _buildSmallFeatureChip(
                                                  Icons.bed,
                                                  '${property['bedrooms']}',
                                                ),
                                              if (property.containsKey('bathrooms'))
                                                _buildSmallFeatureChip(
                                                  Icons.bathtub,
                                                  '${property['bathrooms']}',
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: handleScheduleVisit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF000080),
                  side: const BorderSide(color: Color(0xFF000080)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Schedule Visit'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: handleContactAgent,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF000080),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Contact Agent'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to determine if we should show network signal
  bool _shouldShowNetworkSignal() {
    // Only show for residential, commercial, and land categories
    final category = propertyData?['category'] as String?;
    if (category == null) return false;
    
    final hasCoordinates = 
        propertyData?.containsKey('latitude') == true && 
        propertyData?.containsKey('longitude') == true &&
        propertyData?['latitude'] != null && 
        (propertyData?['latitude'] as String?)?.isNotEmpty == true &&
        propertyData?['longitude'] != null && 
        (propertyData?['longitude'] as String?)?.isNotEmpty == true;
    
    return (category == 'residential' || 
            category == 'commercial' ||
            category == 'land') && 
           hasCoordinates;
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF39322).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFFF39322),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallFeatureChip(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 10,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleVisitSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Schedule a Visit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000080),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Select Date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index + 1));
                final isSelected = index == 0;
                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF000080) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF000080) : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1],
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1],
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              itemBuilder: (context, index) {
                final hour = 9 + index;
                final isSelected = index == 1;
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF000080) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF000080) : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    '$hour:00',
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Visit scheduled successfully!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000080),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirm Visit'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContactAgentSheet() {
    final String agentName = propertyData?['listerName'] ?? agentData['name'];
    final String agentPhone = propertyData?['listerContact'] ?? agentData['phone'];
    final String agentEmail = propertyData?['listerEmail'] ?? agentData['email'];
    final String agentWhatsapp = propertyData?['listerWhatsapp'] ?? agentData['phone'];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Contact Agent',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000080),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(agentData['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agentName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xFFF39322),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${agentData['rating']} • ${agentData['experience']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            'Contact Options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 15),
          _buildContactOption(
            Icons.phone,
            'Call',
            agentPhone,
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling $agentName...'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          _buildContactOption(
            Icons.message,
            'Message',
            'Send a direct message',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening chat with $agentName...'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          _buildContactOption(
            Icons.email,
            'Email',
            agentEmail,
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Composing email to $agentName...'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          _buildContactOption(
            Icons.chat,
            'WhatsApp',
            'Chat on WhatsApp',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening WhatsApp chat with $agentName...'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF000080).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF000080),
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}