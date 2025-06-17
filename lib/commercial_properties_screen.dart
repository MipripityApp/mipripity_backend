import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CommercialProperty {
  final String id;
  final String title;
  final double price;
  final String location;
  final String imageUrl;
  final String propertyType; // office, retail, warehouse, industrial
  final double area; // in square meters
  final String description;
  final List<String> features;
  final bool isFeatured;
  final String status; // 'for_sale', 'for_rent', 'sold'
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

  factory CommercialProperty.fromJson(Map<String, dynamic> json) {
    // Map backend type to UI type
    String backendType = (json['type'] ?? '').toString().toLowerCase();
    String mappedType;
    switch (backendType) {
      case 'office':
      case 'retail':
      case 'warehouse':
      case 'industrial':
        mappedType = backendType;
        break;
      case 'commercial':
        // Default to 'office' or 'commercial' for now
        mappedType = 'office';
        break;
      default:
        mappedType = 'office';
    }

    return CommercialProperty(
      id: json['property_id'] ?? json['id'].toString(),
      title: json['title'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      location: json['location'] ?? '',
      imageUrl: (json['images'] != null && (json['images'] as List).isNotEmpty)
          ? json['images'][0]
          : 'https://via.placeholder.com/400x200.png?text=No+Image',
      propertyType: mappedType,
      area: double.tryParse(json['area']?.toString() ?? '') ?? 0,
      description: json['description'] ?? '',
      features: (json['features'] != null)
          ? List<String>.from(json['features'])
          : [],
      isFeatured: json['category'] == 'premium' || json['is_featured'] == true,
      status: json['status']?.toString() ?? 'for_sale',
      floors: json['floors'] is int
          ? json['floors']
          : int.tryParse(json['floors']?.toString() ?? ''),
      parkingSpaces: json['parkingSpaces'] is int
          ? json['parkingSpaces']
          : int.tryParse(json['parkingSpaces']?.toString() ?? ''),
      yearBuilt: json['year_built']?.toString(),
    );
  }
}

class CommercialPropertiesScreen extends StatefulWidget {
  const CommercialPropertiesScreen({super.key});

  @override
  State<CommercialPropertiesScreen> createState() => _CommercialPropertiesScreenState();
}

class _CommercialPropertiesScreenState extends State<CommercialPropertiesScreen> {
  List<CommercialProperty> properties = [];
  List<CommercialProperty> filteredProperties = [];
  bool isLoading = true;
  String? error;
  String selectedFilter = 'all'; // all, for_sale, for_rent
  String selectedTypeFilter = 'all'; // all, office, retail, warehouse, industrial
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchCommercialProperties();
  }

  Future<void> fetchCommercialProperties() async {
  setState(() {
    isLoading = true;
    error = null;
  });

  try {
    final response = await http.get(
      Uri.parse('https://mipripity-api-1.onrender.com/properties/commercial'),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> data;
      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map) {
        data = [decoded];
      } else {
        data = [];
      }
      final List<CommercialProperty> loadedProperties =
          data.map((json) => CommercialProperty.fromJson(json)).toList();

      setState(() {
        properties = loadedProperties;
        filteredProperties = loadedProperties;
        isLoading = false;
      });
    } else {
      setState(() {
        error = 'Failed to load properties. Status code: ${response.statusCode}';
        isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      error = 'Error loading properties: $e';
      isLoading = false;
    });
  }
}

  void filterProperties() {
    List<CommercialProperty> filtered = properties;

    // Filter by status
    if (selectedFilter != 'all') {
      filtered = filtered.where((property) => property.status == selectedFilter).toList();
    }

    // Filter by property type
    if (selectedTypeFilter != 'all') {
      filtered = filtered.where((property) => property.propertyType == selectedTypeFilter).toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((property) =>
        property.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
        property.location.toLowerCase().contains(searchQuery.toLowerCase()) ||
        property.propertyType.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    setState(() {
      filteredProperties = filtered;
      isLoading = false;
    });
  }

  String formatPrice(double price) {
    return '₦${price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  String getPropertyTypeIcon(String type) {
    switch (type) {
      case 'office':
        return '🏢';
      case 'retail':
        return '🏪';
      case 'warehouse':
        return '🏭';
      case 'industrial':
        return '🏗️';
      default:
        return '🏢';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Commercial Properties',
          style: TextStyle(
            color: Color(0xFF000080),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF000080)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search commercial properties...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF000080)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF000080)),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                searchQuery = value;
                filterProperties();
              },
            ),
          ),
          
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all', selectedFilter),
                        const SizedBox(width: 8),
                        _buildFilterChip('For Sale', 'for_sale', selectedFilter),
                        const SizedBox(width: 8),
                        _buildFilterChip('For Rent', 'for_rent', selectedFilter),
                        const SizedBox(width: 16),
                        _buildTypeFilterChip('All Types', 'all', selectedTypeFilter),
                        const SizedBox(width: 8),
                        _buildTypeFilterChip('Office', 'office', selectedTypeFilter),
                        const SizedBox(width: 8),
                        _buildTypeFilterChip('Retail', 'retail', selectedTypeFilter),
                        const SizedBox(width: 8),
                        _buildTypeFilterChip('Warehouse', 'warehouse', selectedTypeFilter),
                        const SizedBox(width: 8),
                        _buildTypeFilterChip('Industrial', 'industrial', selectedTypeFilter),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Properties List
          Expanded(
            child: _buildPropertiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String selectedValue) {
    final isSelected = selectedValue == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
        filterProperties();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF000080) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilterChip(String label, String value, String selectedValue) {
    final isSelected = selectedValue == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTypeFilter = value;
        });
        filterProperties();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF39322) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPropertiesList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading properties',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: fetchCommercialProperties,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredProperties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No commercial properties found',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredProperties.length,
      itemBuilder: (context, index) {
        final property = filteredProperties[index];
        return _buildPropertyCard(property);
      },
    );
  }

  Widget _buildPropertyCard(CommercialProperty property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/property-details/${property.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Image.network(
                      property.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (property.isFeatured)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF39322),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: property.status == 'for_rent' 
                        ? Colors.green 
                        : const Color(0xFF000080),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      property.status == 'for_rent' ? 'FOR RENT' : 'FOR SALE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getPropertyTypeIcon(property.propertyType),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          property.propertyType.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Property Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000080),
                          ),
                        ),
                      ),
                      Text(
                        formatPrice(property.price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF39322),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Property Features
                  Row(
                    children: [
                      _buildFeatureItem(Icons.square_foot, '${property.area.toInt()} m²'),
                      if (property.floors != null) ...[
                        const SizedBox(width: 16),
                        _buildFeatureItem(Icons.layers, '${property.floors} Floors'),
                      ],
                      if (property.parkingSpaces != null) ...[
                        const SizedBox(width: 16),
                        _buildFeatureItem(Icons.local_parking, '${property.parkingSpaces} Parking'),
                      ],
                    ],
                  ),
                  if (property.yearBuilt != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildFeatureItem(Icons.calendar_today, 'Built ${property.yearBuilt}'),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    property.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  
                  // Key Features
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: property.features.take(3).map((feature) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF000080),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF000080)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF000080),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Commercial Properties',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000080),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Property Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  'office',
                  'retail',
                  'warehouse',
                  'industrial',
                ].map((type) {
                  return FilterChip(
                    label: Text(type.toUpperCase()),
                    selected: selectedTypeFilter == type,
                    onSelected: (selected) {
                      setState(() {
                        selectedTypeFilter = selected ? type : 'all';
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  filterProperties();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000080),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        );
      },
    );
  }
}