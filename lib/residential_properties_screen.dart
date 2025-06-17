import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PropertyListing {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final String location;
  final int? bedrooms;
  final int? bathrooms;
  final double? area;
  final String description;
  final List<dynamic> features;
  final String status;
  final bool isFeatured;

  PropertyListing({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.location,
    this.bedrooms,
    this.bathrooms,
    this.area,
    required this.description,
    required this.features,
    required this.status,
    required this.isFeatured,
  });

  factory PropertyListing.fromJson(Map<String, dynamic> json) {
    return PropertyListing(
      id: json['property_id'] ?? json['id'].toString(),
      title: json['title'] ?? '',
      imageUrl: (json['images'] != null && (json['images'] as List).isNotEmpty)
          ? json['images'][0]
          : 'https://via.placeholder.com/400x200.png?text=No+Image',
      price: double.tryParse(json['price'].toString()) ?? 0,
      location: json['location'] ?? '',
      bedrooms: json['bedrooms'] is int ? json['bedrooms'] : int.tryParse(json['bedrooms']?.toString() ?? ''),
      bathrooms: json['bathrooms'] is int ? json['bathrooms'] : int.tryParse(json['bathrooms']?.toString() ?? ''),
      area: json['area'] is double ? json['area'] : double.tryParse(json['area']?.toString() ?? ''),
      description: json['description'] ?? '',
      features: json['features'] ?? [],
      status: json['category'] ?? 'for_sale',
      isFeatured: json['category'] == 'premium' || json['is_featured'] == true,
    );
  }
}

class ResidentialPropertiesScreen extends StatefulWidget {
  const ResidentialPropertiesScreen({super.key});

  @override
  State<ResidentialPropertiesScreen> createState() => _ResidentialPropertiesScreenState();
}

class _ResidentialPropertiesScreenState extends State<ResidentialPropertiesScreen> {
  List<PropertyListing> properties = [];
  List<PropertyListing> filteredProperties = [];
  bool isLoading = true;
  String? error;
  String selectedFilter = 'all'; // all, for_sale, for_rent
  String selectedPriceRange = 'all'; // all, 0-20m, 20-50m, 50m+
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchResidentialProperties();
  }

  Future<void> fetchResidentialProperties() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://mipripity-api-1.onrender.com/properties/residential'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<PropertyListing> loadedProperties =
            data.map((json) => PropertyListing.fromJson(json)).toList();

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
    setState(() {
      isLoading = true;
    });

    double? minPrice;
    double? maxPrice;

    // Parse price range
    if (selectedPriceRange != 'all') {
      switch (selectedPriceRange) {
        case '0-20m':
          maxPrice = 20000000;
          break;
        case '20-50m':
          minPrice = 20000000;
          maxPrice = 50000000;
          break;
        case '50m+':
          minPrice = 50000000;
          break;
      }
    }

    List<PropertyListing> filtered = properties.where((property) {
      bool matchesStatus = selectedFilter == 'all' ||
          (selectedFilter == 'for_sale' && property.status == 'for_sale') ||
          (selectedFilter == 'for_rent' && property.status == 'for_rent');
      bool matchesPrice = true;
      if (minPrice != null && property.price < minPrice) matchesPrice = false;
      if (maxPrice != null && property.price > maxPrice) matchesPrice = false;
      bool matchesSearch = searchQuery.isEmpty ||
          property.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          property.location.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesStatus && matchesPrice && matchesSearch;
    }).toList();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Residential Properties',
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
                hintText: 'Search properties...',
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
                        _buildPriceFilterChip('All Prices', 'all', selectedPriceRange),
                        const SizedBox(width: 8),
                        _buildPriceFilterChip('₦0-20M', '0-20m', selectedPriceRange),
                        const SizedBox(width: 8),
                        _buildPriceFilterChip('₦20-50M', '20-50m', selectedPriceRange),
                        const SizedBox(width: 8),
                        _buildPriceFilterChip('₦50M+', '50m+', selectedPriceRange),
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

  Widget _buildPriceFilterChip(String label, String value, String selectedValue) {
    final isSelected = selectedValue == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPriceRange = value;
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
            Text(
              error!,
              style: TextStyle(color: Colors.red[400], fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchResidentialProperties,
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
            Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No properties found',
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

  Widget _buildPropertyCard(PropertyListing property) {
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
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(property.imageUrl),
                        fit: BoxFit.cover,
                      ),
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
                      if (property.bedrooms != null)
                        _buildPropertyFeature(
                          Icons.bed_outlined,
                          '${property.bedrooms}',
                        ),
                      if (property.bathrooms != null) ...[
                        const SizedBox(width: 16),
                        _buildPropertyFeature(
                          Icons.bathtub_outlined,
                          '${property.bathrooms}',
                        ),
                      ],
                      if (property.area != null) ...[
                        const SizedBox(width: 16),
                        _buildPropertyFeature(
                          Icons.square_foot_outlined,
                          '${property.area}m²',
                        ),
                      ],
                    ],
                  ),
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
                          feature.toString(),
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

  Widget _buildPropertyFeature(IconData icon, String text) {
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
                'Filter Properties',
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
              // Add more filter options here
              ElevatedButton(
                onPressed: () {
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