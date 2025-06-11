import 'package:flutter/material.dart';
import 'shared/bottom_navigation.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String activeTab = 'explore';

  // Popular Lagos areas
  final List<Map<String, dynamic>> popularAreas = [
    {
      'id': '1',
      'name': 'Lekki',
      'image': 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914',
      'count': 42,
      'description': 'Upscale residential area with beaches and modern developments',
    },
    {
      'id': '2',
      'name': 'Ikeja',
      'image': 'https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6',
      'count': 28,
      'description': 'Commercial hub and capital of Lagos State',
    },
    {
      'id': '3',
      'name': 'Victoria Island',
      'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
      'count': 35,
      'description': 'Business district with luxury properties and corporate offices',
    },
    {
      'id': '4',
      'name': 'Ikoyi',
      'image': 'https://images.unsplash.com/photo-1613977257363-707ba9348227',
      'count': 31,
      'description': 'Affluent neighborhood with high-end residential properties',
    },
  ];

  // More Lagos areas
  final List<Map<String, dynamic>> moreAreas = [
    {
      'id': '5',
      'name': 'Ajah',
      'image': 'https://images.unsplash.com/photo-1613977257363-707ba9348227',
      'count': 19,
    },
    {
      'id': '6',
      'name': 'Yaba',
      'image': 'https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6',
      'count': 23,
    },
    {
      'id': '7',
      'name': 'Surulere',
      'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
      'count': 27,
    },
    {
      'id': '8',
      'name': 'Gbagada',
      'image': 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914',
      'count': 15,
    },
    {
      'id': '9',
      'name': 'Epe',
      'image': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef',
      'count': 12,
    },
    {
      'id': '10',
      'name': 'Alimosho',
      'image': 'https://images.unsplash.com/photo-1628624747186-a941c476b7ef',
      'count': 24,
    },
  ];

  // Land listings
  final List<Map<String, dynamic>> landListings = [
    {
      'id': 'l1',
      'title': 'Prime Land in Lekki Phase 1',
      'location': 'Lekki',
      'price': '₦25,000,000',
      'size': '500 sqm',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQx2LN581kRMMNSsuF3vdugokrTs1W_sn6vtg&s',
    },
    {
      'id': 'l2',
      'title': 'Commercial Plot in Ikeja',
      'location': 'Ikeja',
      'price': '₦18,500,000',
      'size': '350 sqm',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQWFmGKO8JTbeYu9fZt50EsnDvysjnF3PG9vw&s',
    },
    {
      'id': 'l3',
      'title': 'Residential Land in Ajah',
      'location': 'Ajah',
      'price': '₦15,000,000',
      'size': '450 sqm',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRcguvCDM-FOypwzH80Qevv-jzKMiF7Ma0mVw&s',
    },
  ];

  // Material listings
  final List<Map<String, dynamic>> materialListings = [
    {
      'id': 'm1',
      'title': 'Premium Cement',
      'brand': 'Dangote',
      'price': '₦4,500',
      'unit': 'per bag',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpQFTmSdzR1A8ziLD3wmIgBgyQ9idMcaHuMNtV764qL3OCD5dag13iHDYWBW7uEgn4chs&usqp=CAU',
    },
    {
      'id': 'm2',
      'title': 'Iron Rods (16mm)',
      'brand': 'Standard',
      'price': '₦7,200',
      'unit': 'per rod',
      'image': 'https://www.housingtvafrica.com/wp-content/uploads/2024/03/image-243.webp',
    },
    {
      'id': 'm3',
      'title': 'Granite Stone',
      'brand': 'Quality',
      'price': '₦45,000',
      'unit': 'per ton',
      'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Fly_Ash_Bricks.jpg/1200px-Fly_Ash_Bricks.jpg',
    },
  ];

  // Skill Workers listings
  final List<Map<String, dynamic>> skillWorkersListings = [
    {
      'id': 'sw1',
      'name': 'John Okafor',
      'profession': 'Master Plumber',
      'rating': 4.8,
      'experience': '10 years',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGb5Sy4wr_fNuw5m5UKxEOIxLsdG4yEwlwEQ&s',
    },
    {
      'id': 'sw2',
      'name': 'Amina Ibrahim',
      'profession': 'Electrician',
      'rating': 4.7,
      'experience': '8 years',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwW2BbRZXaAKPt019qQASneiNaTFLpHJ8Ebg&s',
    },
    {
      'id': 'sw3',
      'name': 'David Adeyemi',
      'profession': 'Carpenter',
      'rating': 4.9,
      'experience': '15 years',
      'image': 'https://www.liveabout.com/thmb/OBdAQfqD-FL1YzYRCIMuXqTcu8Y=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/GettyImages-508481761-5760b7105f9b58f22e360f07.jpg',
    },
  ];

  void handleLocationClick(String locationId) {
    Navigator.pushNamed(context, '/explore/$locationId');
  }

  void handlePropertyClick(String propertyId) {
    Navigator.pushNamed(context, '/property-details/$propertyId');
  }

  void handleMaterialClick(String materialId) {
    Navigator.pushNamed(context, '/material/$materialId');
  }

  void handleWorkerClick(String workerId) {
    Navigator.pushNamed(context, '/skill-workers/$workerId');
  }

  void handleNearbyClick() {
    Navigator.pushNamed(context, '/explore/nearby');
  }

  void handleTrendingClick() {
    Navigator.pushNamed(context, '/explore/trending');
  }

  void handleMapViewClick() {
    Navigator.pushNamed(context, '/map-view');
  }

  void handleViewAllLand() {
    Navigator.pushNamed(context, '/land/all');
  }

  void handleViewAllMaterials() {
    Navigator.pushNamed(context, '/material/all');
  }

  void handleViewAllSkillWorkers() {
    Navigator.pushNamed(context, '/skill-workers/all');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.white,
                expandedHeight: 150.0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with title and notification/profile
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Explore',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF000080),
                                  ),
                                ),
                                Text(
                                  'Discover properties by location',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // Notification Icon with badge
                                Stack(
                                  children: [
                                    InkWell(
                                      onTap: () => Navigator.pushNamed(context, '/notifications'),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.notifications_none,
                                          color: Color(0xFF000080),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF39322),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '3',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                // Profile Image
                                InkWell(
                                  onTap: () => Navigator.pushNamed(context, '/profile'),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      image: const DecorationImage(
                                        image: NetworkImage(
                                          'https://randomuser.me/api/portraits/men/32.jpg',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search input
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.grey[100]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.grey[400],
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search locations or properties',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF39322).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.filter_list,
                                  color: Color(0xFFF39322),
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // Quick Access Buttons
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Nearby Button
                            GestureDetector(
                              onTap: handleNearbyClick,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF39322).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.navigation_outlined,
                                        color: Color(0xFFF39322),
                                        size: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Nearby',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF000080),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Trending Button
                            GestureDetector(
                              onTap: handleTrendingClick,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF39322).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.trending_up,
                                        color: Color(0xFFF39322),
                                        size: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Trending',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF000080),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Map View Button
                            GestureDetector(
                              onTap: handleMapViewClick,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF39322).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.place_outlined,
                                        color: Color(0xFFF39322),
                                        size: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Map View',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF000080),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Popular Areas
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Popular Areas in Lagos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000080),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                            itemCount: popularAreas.length,
                            itemBuilder: (context, index) {
                              final area = popularAreas[index];
                              return GestureDetector(
                                onTap: () => handleLocationClick(area['id']),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
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
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                            ),
                                            child: Image.network(
                                              area['image'],
                                              height: 160,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [
                                                    Colors.black.withOpacity(0.7),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.place_outlined,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        area['name'],
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    '${area['count']} properties',
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.8),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          area['description'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Land Listings
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Land for Sale',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000080),
                                ),
                              ),
                              GestureDetector(
                                onTap: handleViewAllLand,
                                child: const Row(
                                  children: [
                                    Text(
                                      'View All',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFF39322),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFFF39322),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: landListings.length,
                              itemBuilder: (context, index) {
                                final land = landListings[index];
                                return GestureDetector(
                                  onTap: () => handlePropertyClick(land['id']),
                                  child: Container(
                                    width: 200,
                                    margin: EdgeInsets.only(
                                      right: index != landListings.length - 1 ? 16 : 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
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
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15),
                                              ),
                                              child: Image.network(
                                                land['image'],
                                                height: 120,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
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
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: const Text(
                                                  'Land',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
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
                                                land['title'],
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
                                                  Icon(
                                                    Icons.place_outlined,
                                                    color: Colors.grey[500],
                                                    size: 12,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    land['location'],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    land['price'],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFFF39322),
                                                    ),
                                                  ),
                                                  Text(
                                                    land['size'],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
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
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Building Materials
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Building Materials',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000080),
                                ),
                              ),
                              GestureDetector(
                                onTap: handleViewAllMaterials,
                                child: const Row(
                                  children: [
                                    Text(
                                      'View All',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFF39322),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFFF39322),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: materialListings.length,
                              itemBuilder: (context, index) {
                                final material = materialListings[index];
                                return GestureDetector(
                                  onTap: () => handleMaterialClick(material['id']),
                                  child: Container(
                                    width: 180,
                                    margin: EdgeInsets.only(
                                      right: index != materialListings.length - 1 ? 16 : 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                          ),
                                          child: Image.network(
                                            material['image'],
                                            height: 100,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                material['title'],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF000080),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                material['brand'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    material['price'],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFFF39322),
                                                    ),
                                                  ),
                                                  Text(
                                                    material['unit'],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
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
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Skilled Workers
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Skilled Workers',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000080),
                                ),
                              ),
                              GestureDetector(
                                onTap: handleViewAllSkillWorkers,
                                child: const Row(
                                  children: [
                                    Text(
                                      'View All',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFF39322),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFFF39322),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: skillWorkersListings.length,
                              itemBuilder: (context, index) {
                                final worker = skillWorkersListings[index];
                                return GestureDetector(
                                  onTap: () => handleWorkerClick(worker['id']),
                                  child: Container(
                                    width: 160,
                                    margin: EdgeInsets.only(
                                      right: index != skillWorkersListings.length - 1 ? 16 : 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 16),
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFFF39322),
                                              width: 2,
                                            ),
                                            image: DecorationImage(
                                              image: NetworkImage(worker['image']),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          worker['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF000080),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          worker['profession'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Color(0xFFF39322),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              worker['rating'].toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          worker['experience'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF000080),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'Contact',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // More Areas
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'More Areas in Lagos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF000080),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: moreAreas.length,
                            itemBuilder: (context, index) {
                              final area = moreAreas[index];
                              return GestureDetector(
                                onTap: () => handleLocationClick(area['id']),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
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
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                            ),
                                            child: Image.network(
                                              area['image'],
                                              height: 80,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [
                                                    Colors.black.withOpacity(0.7),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    area['name'],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${area['count']} properties',
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.8),
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SharedBottomNavigation(
              activeTab: "explore",
              onTabChange: (tab) {
                SharedBottomNavigation.handleNavigation(context, tab);
              },
            ),
          ),
        ],
      ),
    );
  }
}
