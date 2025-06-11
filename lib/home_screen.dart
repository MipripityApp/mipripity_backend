import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'filter_form.dart';

// First, add imports for all the property screens at the top of the file
import 'residential_properties_screen.dart';
import 'commercial_properties_screen.dart';
import 'land_properties_screen.dart';
import 'material_properties_screen.dart';

// Import property repository for SQLite database access
import 'services/database_service.dart';
import 'database_helper.dart';

// Define our property model (keep for backward compatibility)
class PropertyListing {
  final String id;
  final String title;
  final double price;
  final String location;
  final String imageUrl;
  final int? bedrooms;
  final int? bathrooms;
  final double? area;
  final String? category;

  PropertyListing({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.imageUrl,
    this.bedrooms,
    this.bathrooms,
    this.area,
    this.category,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool locationEnabled = false;
  String selectedCategory = 'residential';
  String budget = '';
  bool isFilterVisible = false;
  Map<String, dynamic> activeFilters = {};
  
  // Property listings states
  List<PropertyListing> residentialProperties = [];
  List<PropertyListing> commercialProperties = [];
  List<PropertyListing> landProperties = [];
  List<PropertyListing> materialProperties = [];
  bool isLoading = true;
  String? error;
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Fetch properties
    fetchProperties();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Property repository instance
  final DatabaseService _databaseService = DatabaseService();

  // Fetch properties from the database
  Future<void> fetchProperties() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Check if database is ready
      final dbHelper = DatabaseHelper();
      await dbHelper.database; // This will initialize the database if needed
      
      // Fetch properties from database by category
      final residentialData = await _fetchCategoryProperties('residential');
      final commercialData = await _fetchCategoryProperties('commercial');
      final landData = await _fetchCategoryProperties('land');
      final materialData = await _fetchCategoryProperties('material');

      setState(() {
        residentialProperties = residentialData;
        commercialProperties = commercialData;
        landProperties = landData;
        materialProperties = materialData;
        isLoading = false;
      });
      
      // Start animation after data is loaded
      _animationController.forward();
    } catch (e) {
      print('Error in fetchProperties: $e');
      setState(() {
        error = 'Failed to load properties. Please check your database connection.';
        isLoading = false;
      });
    }
  }

  // Helper method to fetch properties by category
  Future<List<PropertyListing>> _fetchCategoryProperties(String category) async {
    try {
      // Get featured properties from database service
      final properties = await _databaseService.getFeaturedPropertiesByCategory(category, limit: 6);
      
      List<PropertyListing> propertyList = [];
      
      for (final property in properties) {
        try {
          propertyList.add(PropertyListing(
            id: property['id'].toString(),
            title: property['title'] ?? 'Untitled Property',
            price: _parsePrice(property['price']),
            location: property['location'] ?? 'Unknown',
            imageUrl: property['imageUrl'] ?? property['image_url'] ?? _getDefaultImageForCategory(category),
            bedrooms: property['bedrooms'],
            bathrooms: property['bathrooms'],
            area: property['area'] is String ? double.tryParse(property['area']) : property['area'],
            category: category,
          ));
        } catch (e) {
          print('Error creating PropertyListing from property: $e');
        }
      }
      
      return propertyList;
    } catch (e) {
      print('Error fetching $category properties: $e');
      return [];
    }
  }

  // Get default image based on property category
  String _getDefaultImageForCategory(String category) {
    switch (category) {
      case 'residential':
        return 'assets/images/residential1.jpg';
      case 'commercial':
        return 'assets/images/commercial1.jpg';
      case 'land':
        return 'assets/images/land1.png';
      case 'material':
        return 'assets/images/material1.jpg';
      default:
        return 'assets/images/residential1.jpg';
    }
  }

  // Helper method to parse price from various formats
  double _parsePrice(dynamic price) {
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

  // Method to handle category selection
  void handleCategorySelect(String category) {
    // Add haptic feedback
    HapticFeedback.selectionClick();
    
    setState(() {
      selectedCategory = category;
      isFilterVisible = true; // Show filter form when category is selected
    });
  }

  // Method to handle filter application
  void handleFilterApplied(Map<String, dynamic> filters) {
    setState(() {
      activeFilters = filters;
      isFilterVisible = false; // Hide filter form after applying filters
    });
    
    // In a real app, you would filter your properties list here
    print('Filters applied for $selectedCategory: $filters');
    // Example:
    // setState(() {
    //   filteredProperties = applyFilters(properties, filters);
    // });
  }

  // Method to close filter form
  void closeFilterForm() {
    setState(() {
      isFilterVisible = false;
    });
  }

  // Format price to local currency
  String formatPrice(double price) {
    return '₦${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  // Build property cards
  Widget buildPropertyCards(List<PropertyListing> properties, String category) {
    if (isLoading) {
      return Row(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              width: 240,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFFF39322).withOpacity(0.5),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          color: Colors.grey[200],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 100,
                          color: Colors.grey[200],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading properties. Please try again.',
              style: TextStyle(color: Colors.red[500]),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: fetchProperties,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000080),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (properties.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.search_off, color: Colors.grey[400], size: 48),
            const SizedBox(height: 16),
            const Text(
              'No featured properties available.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Row(
      children: properties.asMap().entries.map((entry) {
        final int idx = entry.key;
        final property = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              // Staggered animation for cards
              final delay = idx * 0.2;
              final startValue = delay;
              final endValue = delay + 0.8;
              
              final animationProgress = (_animationController.value - startValue) / (endValue - startValue);
              final calculatedValue = animationProgress.clamp(0.0, 1.0);
              
              return Transform.translate(
                offset: Offset(0, 20 * (1 - calculatedValue)),
                child: Opacity(
                  opacity: calculatedValue,
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onTap: () {
                // Navigate to property details based on category
                switch (category) {
                  case 'residential':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ResidentialPropertiesScreen()),
                    );
                    break;
                  case 'commercial':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CommercialPropertiesScreen()),
                    );
                    break;
                  case 'land':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LandPropertiesScreen()),
                    );
                    break;
                  case 'material':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MaterialPropertiesScreen()),
                    );
                    break;
                }
                
                // Add haptic feedback for better engagement
                HapticFeedback.lightImpact();
              },
              child: Container(
                width: 240,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Hero(
                          tag: 'property-${property.id}',
                          child: Container(
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              image: DecorationImage(
                                image: AssetImage(property.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF000080).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              formatPrice(property.price),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        // Add a favorite button
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.favorite_border,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF000080),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  property.location,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Property details (bedrooms, bathrooms, area)
                          if (property.bedrooms != null || property.bathrooms != null || property.area != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (property.bedrooms != null)
                                  _buildPropertyFeature(
                                    Icons.bed_outlined,
                                    '${property.bedrooms}',
                                  ),
                                if (property.bathrooms != null)
                                  _buildPropertyFeature(
                                    Icons.bathtub_outlined,
                                    '${property.bathrooms}',
                                  ),
                                if (property.area != null)
                                  _buildPropertyFeature(
                                    Icons.square_foot_outlined,
                                    '${property.area}m²',
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPropertyFeature(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFFF39322),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF000080),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Main Content Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with animated gradient
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF000080), Color(0xFF0000B3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Find Your Dream Property',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Discover the perfect place to call home',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.notifications_none,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Search Box with Location Toggle
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 0,
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.search,
                                        color: Color(0xFFF39322),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          decoration: const InputDecoration(
                                            hintText: 'What is your Budget?',
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              budget = value;
                                            });
                                          },
                                        ),
                                      ),
                                      Container(
                                        height: 24,
                                        width: 1,
                                        color: Colors.grey[300],
                                        margin: const EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'Location',
                                            style: TextStyle(
                                              color: Color(0xFF000080),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Switch(
                                            value: locationEnabled,
                                            onChanged: (value) {
                                              setState(() {
                                                locationEnabled = value;
                                                // Add haptic feedback
                                                HapticFeedback.selectionClick();
                                              });
                                            },
                                            activeColor: const Color(0xFFF39322),
                                            activeTrackColor: const Color(0xFFF39322).withOpacity(0.3),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Category Tabs with improved UI
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Residential Button
                                buildCategoryButton(
                                  'residential',
                                  'Residential',
                                  'assets/icons/residential.png',
                                ),
                                
                                // Commercial Button
                                buildCategoryButton(
                                  'commercial',
                                  'Commercial',
                                  'assets/icons/commercial.png',
                                ),
                                
                                // Land Button
                                buildCategoryButton(
                                  'land',
                                  'Land',
                                  'assets/icons/land.png',
                                ),
                                
                                // Material Button
                                buildCategoryButton(
                                  'material',
                                  'Material',
                                  'assets/icons/material.png',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Active filters indicator (if any)
                          if (activeFilters.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF39322).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFF39322).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.filter_list,
                                    size: 18,
                                    color: Color(0xFFF39322),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Filters applied: ${activeFilters.length} filters',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFFF39322),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        activeFilters = {};
                                      });
                                    },
                                    child: const Text(
                                      'Clear',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF000080),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          // Featured Residential Properties
                          buildPropertySection(
                            'Featured Residential Properties',
                            residentialProperties,
                            'residential',
                          ),
                          
                          // Featured Commercial Properties
                          buildPropertySection(
                            'Featured Commercial Properties',
                            commercialProperties,
                            'commercial',
                          ),
                          
                          // Featured Land Properties
                          buildPropertySection(
                            'Featured Landed Properties',
                            landProperties,
                            'land',
                          ),
                          
                          // Featured Material Properties
                          buildPropertySection(
                            'Featured Materials',
                            materialProperties,
                            'material',
                          ),
                          
                          // Action Buttons with improved styling
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Navigate to login
                                    Navigator.of(context).pushNamed('/login');
                                    // Add haptic feedback
                                    HapticFeedback.mediumImpact();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: const Color(0xFF000080),
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(color: Color(0xFF000080)),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/register');
                                    HapticFeedback.mediumImpact();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                    backgroundColor: const Color(0xFFF39322),
                                  ),
                                  child: const Text(
                                    'Create Account',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          // Add a footer
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey[200]!),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildSocialButton(Icons.facebook, Colors.blue),
                                    _buildSocialButton(Icons.camera_alt, Colors.pink),
                                    _buildSocialButton(Icons.telegram, Colors.blue[400]!),
                                    _buildSocialButton(Icons.chat_bubble, Colors.green),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  '© 2023 Property Finder. All rights reserved.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Filter form overlay
            if (isFilterVisible)
              Positioned.fill(
                child: GestureDetector(
                  onTap: closeFilterForm, // Close when tapping outside
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {}, // Prevent closing when tapping on the form
                        child: FilterForm(
                          selectedCategory: selectedCategory,
                          onFilterApplied: handleFilterApplied,
                          onClose: closeFilterForm,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  // Helper method to build category buttons with improved UI
  Widget buildCategoryButton(String category, String label, String iconPath) {
    final isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () => handleCategorySelect(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF39322)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFFF39322).withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFF39322)
                      : Colors.grey[100]!,
                ),
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: 36,
                  height: 36,
                  color: isSelected ? Colors.white : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFF39322)
                    : const Color(0xFF000080),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build property sections with improved UI
  Widget buildPropertySection(
    String title,
    List<PropertyListing> properties,
    String category,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF000080),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to category page based on category
                switch (category) {
                  case 'residential':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ResidentialPropertiesScreen()),
                    );
                    break;
                  case 'commercial':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CommercialPropertiesScreen()),
                    );
                    break;
                  case 'land':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LandPropertiesScreen()),
                    );
                    break;
                  case 'material':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MaterialPropertiesScreen()),
                    );
                    break;
                }
                
                // Add haptic feedback
                HapticFeedback.selectionClick();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF39322),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: buildPropertyCards(properties, category),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
