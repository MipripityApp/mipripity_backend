import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'map_view.dart';
import 'filter_form.dart';
import 'shared/bottom_navigation.dart';

// Mock data model for listings
class Listing {
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

  Listing({
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
}

// Mock data model for user profile
class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.firstName,
    this.lastName,
    this.avatarUrl,
  });
}

// Format price to Nigerian Naira
String formatPrice(num amount, {String symbol = '₦'}) {
  if (amount >= 1e9) {
    return '$symbol${(amount / 1e9).toStringAsFixed(1)}B';
  } else if (amount >= 1e6) {
    return '$symbol${(amount / 1e6).toStringAsFixed(1)}M';
  } else if (amount >= 1e3) {
    return '$symbol${(amount / 1e3).toStringAsFixed(1)}K';
  } else {
    return '$symbol$amount';
  }
}

// CountdownTimer Widget
class CountdownTimer extends StatefulWidget {
  final String targetDate;

  const CountdownTimer({Key? key, required this.targetDate}) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _timeRemaining;

  @override
  void initState() {
    super.initState();
    _calculateTimeRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateTimeRemaining();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateTimeRemaining() {
    final targetDateTime = DateTime.parse(widget.targetDate);
    final now = DateTime.now();
    setState(() {
      _timeRemaining = targetDateTime.difference(now);
      if (_timeRemaining.isNegative) {
        _timeRemaining = Duration.zero;
        _timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeBox(days, 'Days'),
        const SizedBox(width: 4),
        _buildTimeBox(hours, 'Hrs'),
        const SizedBox(width: 4),
        _buildTimeBox(minutes, 'Min'),
        const SizedBox(width: 4),
        _buildTimeBox(seconds, 'Sec'),
      ],
    );
  }

  Widget _buildTimeBox(int value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF39322).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF39322),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// DepositOptions Widget
class DepositOptions extends StatelessWidget {
  final double price;
  final Function(int, double) onDepositClick;

  const DepositOptions({
    Key? key,
    required this.price,
    required this.onDepositClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deposit Options',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000080),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildDepositOption(10),
                  const SizedBox(height: 4),
                  _buildDepositOption(30),
                  const SizedBox(height: 4),
                  _buildDepositOption(50),
                  const SizedBox(height: 4),
                  _buildDepositOption(70),
                  const SizedBox(height: 4),
                  _buildDepositOption(90),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                children: [
                  _buildDepositOption(20),
                  const SizedBox(height: 4),
                  _buildDepositOption(40),
                  const SizedBox(height: 4),
                  _buildDepositOption(60),
                  const SizedBox(height: 4),
                  _buildDepositOption(80),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDepositOption(int percentage) {
    final depositAmount = price * percentage / 100;
    return GestureDetector(
      onTap: () => onDepositClick(percentage, depositAmount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF39322).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF39322),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              formatPrice(depositAmount),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000080),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BidModal Widget - Updated to be a proper modal dialog
class BidModal extends StatefulWidget {
  final String listingId;
  final String listingTitle;
  final double listingPrice;

  const BidModal({
    Key? key,
    required this.listingId,
    required this.listingTitle,
    required this.listingPrice,
  }) : super(key: key);

  @override
  State<BidModal> createState() => _BidModalState();
}

class _BidModalState extends State<BidModal> {
  final TextEditingController _bidAmountController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _bidAmountController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        Navigator.of(context).pop(); // Close the modal
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bid submitted successfully!'),
            backgroundColor: Color(0xFFF39322),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Place a Bid',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000080),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 24,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Listing: ${widget.listingTitle}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Asking Price: ${formatPrice(widget.listingPrice)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF39322),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _bidAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Your Bid Amount (₦)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFF39322),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFFF39322),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Bid',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// InspectionModal Widget - Updated to be a proper modal dialog
class InspectionModal extends StatefulWidget {
  final String listingId;
  final String listingTitle;

  const InspectionModal({
    Key? key,
    required this.listingId,
    required this.listingTitle,
  }) : super(key: key);

  @override
  State<InspectionModal> createState() => _InspectionModalState();
}

class _InspectionModalState extends State<InspectionModal> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _handleSubmit() {
    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        Navigator.of(context).pop(); // Close the modal
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inspection scheduled successfully!'),
            backgroundColor: Color(0xFFF39322),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Schedule Inspection',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000080),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 24,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Listing: ${widget.listingTitle}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Preferred Date',
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFF39322),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: 'Preferred Time',
                    suffixIcon: const Icon(Icons.access_time),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFF39322),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFFF39322),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Schedule Inspection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// LayeredListingCard Widget - Updated to use modal dialogs
class LayeredListingCard extends StatefulWidget {
  final Listing listing;

  const LayeredListingCard({Key? key, required this.listing}) : super(key: key);

  @override
  State<LayeredListingCard> createState() => _LayeredListingCardState();
}

class _LayeredListingCardState extends State<LayeredListingCard> {
  Map<String, dynamic>? _listerData;

  @override
  void initState() {
    super.initState();
    _fetchListerData();
  }

  void _fetchListerData() {
    // Simulate API call
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && widget.listing.userId != null) {
        setState(() {
          _listerData = {
            'id': widget.listing.userId,
            'first_name': widget.listing.listerName.split(' ').first,
            'last_name': widget.listing.listerName.split(' ').length > 1
                ? widget.listing.listerName.split(' ').last
                : '',
            'avatar_url': widget.listing.listerDp,
          };
        });
      }
    });
  }

  void _handleCardClick() {
    // Navigate to property details with all listing data
    Navigator.pushNamed(
      context, 
      '/property-details/${widget.listing.id}',
      arguments: widget.listing,
    );

    // Increment view count in the background
    // This would typically be an API call
  }

  void _handleWhatsappClick(BuildContext context) {
    // Check if listerWhatsapp is available
    if (widget.listing.listerWhatsapp != null && widget.listing.listerWhatsapp!.isNotEmpty) {
      _launchWhatsappUrl(widget.listing.listerWhatsapp!);
    } else {
      // Show a snackbar if WhatsApp link is not available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp contact not available for this lister'),
          backgroundColor: Color(0xFF000080),
        ),
      );
    }
  }

  // Add this helper method to launch the URL
  Future<void> _launchWhatsappUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp URL: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Updated to show modal dialog instead of popup
  void _handleBidClick() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return BidModal(
          listingId: widget.listing.id,
          listingTitle: widget.listing.title,
          listingPrice: widget.listing.price,
        );
      },
    );
  }

  // Updated to show modal dialog instead of popup
  void _handleInspectClick() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return InspectionModal(
          listingId: widget.listing.id,
          listingTitle: widget.listing.title,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Removed Stack wrapper since we no longer need overlay popups
    return GestureDetector(
      onTap: _handleCardClick,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Layer I - Property Image, Title, Location
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.asset(
                    widget.listing.listingImage,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.listing.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000080),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  height: 20,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 1.0, end: 1.05),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF39322), Color(0xFF000080)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to map view with property coordinates
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapView(
                                propertyId: widget.listing.id,
                                propertyTitle: widget.listing.title,
                                propertyAddress: '${widget.listing.location}, ${widget.listing.city}, ${widget.listing.state}',
                                latitude: double.tryParse(widget.listing.latitude) ?? 0.0,
                                longitude: double.tryParse(widget.listing.longitude) ?? 0.0,
                              ),
                            ),
                          );
                        },
                        icon: ClipOval(
                          child: Image.asset(
                            'assets/icons/tour-icon.gif',
                            width: 20,
                            height: 30,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.view_in_ar,
                                size: 16,
                                color: Colors.white,
                              );
                            },
                          ),
                        ),
                        label: const Text(
                          'Take a Tour',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
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
                        Text(
                          widget.listing.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.listing.city}, ${widget.listing.state}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatPrice(widget.listing.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Divider
            const Divider(height: 1),

            // Property Features
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildPropertyFeatures(),
            ),

            // Divider
            const Divider(height: 1),

            // Layers J, K, L Container - Rearranged
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Layer L - Deposit Options (Now on top)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF39322).withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deposit Options',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000080),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 3x3 Grid for deposit options
                        Column(
                          children: [
                            // Row 1: 10%, 20%, 30%
                            Row(
                              children: [
                                Expanded(child: _buildDepositOptionButton(10)),
                                const SizedBox(width: 8),
                                Expanded(child: _buildDepositOptionButton(20)),
                                const SizedBox(width: 8),
                                Expanded(child: _buildDepositOptionButton(30)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Row 2: 40%, 50%, 60%
                            Row(
                              children: [
                                Expanded(child: _buildDepositOptionButton(40)),
                                const SizedBox(width: 8),
                                Expanded(child: _buildDepositOptionButton(50)),
                                const SizedBox(width: 8),
                                Expanded(child: _buildDepositOptionButton(60)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Row 3: 70%, 80%, 90%
                            Row(
                              children: [
                                Expanded(child: _buildDepositOptionButton(70)),
                                const SizedBox(width: 8),
                                Expanded(child: _buildDepositOptionButton(80)),
                                const SizedBox(width: 8),
                                Expanded(child: _buildDepositOptionButton(90)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Horizontal Divider
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                  
                  // Layer J and K side by side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Layer J - Lister Details with Action Icons
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFF39322).withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                _listerData != null
                                    ? '${_listerData!['first_name']} ${_listerData!['last_name']}'
                                    : widget.listing.listerName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF000080),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Row with Inspect button, DP, and Bid Now button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Inspect button on the left
                                  Column(
                                    children: [
                                      const Text(
                                        'Inspect',
                                        style: TextStyle(
                                          fontSize: 6,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF000080),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      GestureDetector(
                                        onTap: _handleInspectClick,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.2),
                                                spreadRadius: 0,
                                                blurRadius: 5,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/images/Inspect.gif',
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.search,
                                                  size: 16,
                                                  color: Colors.blue,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Space between button and DP
                                  const SizedBox(width: 2),
                                  
                                  // Lister DP in the middle
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 0,
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image: AssetImage(
                                          _listerData != null
                                              ? _listerData!['avatar_url']
                                              : widget.listing.listerDp,
                                        ),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {
                                          // Handle image loading error
                                        },
                                      ),
                                    ),
                                  ),
                                  
                                  // Space between DP and button
                                  const SizedBox(width: 2),
                                  
                                  // Bid Now button on the right
                                  Column(
                                    children: [
                                      const Text(
                                        'Bid Now',
                                        style: TextStyle(
                                          fontSize: 6,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF000080),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      GestureDetector(
                                        onTap: _handleBidClick,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.2),
                                                spreadRadius: 0,
                                                blurRadius: 5,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/images/Bid Now.gif',
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.gavel,
                                                  size: 16,
                                                  color: Colors.orange,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              // WhatsApp button directly under the DP
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => _handleWhatsappClick(context),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 0,
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/images/Whatapp.gif',
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.message,
                                              size: 16,
                                              color: Colors.green,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'WhatsApp',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF000080),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Vertical Divider - same height as containers
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 1,
                        color: Colors.grey[300],
                      ),

                      // Layer K - Urgency Bell and Countdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFF39322).withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 0,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/icons/bell.gif',
                                  width: 28,
                                  height: 28,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.notifications,
                                      size: 24,
                                      color: Color(0xFFF39322),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Closing in',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              CountdownTimer(
                                targetDate: widget.listing.urgencyPeriod,
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
            // Views Counter
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.visibility,
                    size: 12,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.listing.views} views',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyFeatures() {
    switch (widget.listing.category) {
      case 'residential':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFeatureItem(
              'Bedrooms',
              'assets/images/bed.gif',
              Icons.bed,
              widget.listing.bedrooms?.toString() ?? '0',
            ),
            _buildFeatureItem(
              'Bathrooms',
              'assets/images/bathtub.gif',
              Icons.bathtub,
              widget.listing.bathrooms?.toString() ?? '0',
            ),
            _buildFeatureItem(
              'Toilets',
              'assets/images/toilet.gif',
              Icons.wc,
              widget.listing.toilets?.toString() ?? '0',
            ),
            _buildFeatureItem(
              'Parking',
              'assets/images/parking.gif',
              Icons.local_parking,
              widget.listing.parkingSpaces?.toString() ?? '0',
            ),
          ],
        );
      case 'commercial':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFeatureItem(
              'Internet',
              'assets/images/internet.gif',
              Icons.wifi,
              widget.listing.hasInternet == true ? 'Available' : 'No Internet',
            ),
            _buildFeatureItem(
              'Power',
              'assets/images/power.gif',
              Icons.power,
              widget.listing.hasElectricity == true ? '24/7' : 'No Power',
            ),
          ],
        );
      case 'land':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFeatureItem(
              'Title',
              'assets/images/Title.gif',
              Icons.description,
              widget.listing.landTitle ?? 'N/A',
            ),
            _buildFeatureItem(
              'Land Size',
              'assets/icons/Size.gif',
              Icons.straighten,
              '${widget.listing.landSize?.toString() ?? '0'} sqm',
            ),
          ],
        );
      case 'material':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFeatureItem(
              'Quantity',
              '',
              Icons.inventory_2,
              widget.listing.quantity ?? 'N/A',
            ),
            _buildFeatureItem(
              'Condition',
              '',
              Icons.check_circle,
              widget.listing.condition ?? 'N/A',
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDepositOptionButton(int percentage) {
    final depositAmount = widget.listing.price * percentage / 100;
    return GestureDetector(
      onTap: () {
        // Handle deposit click
        debugPrint('Selected deposit: $percentage% - $depositAmount');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFF39322).withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$percentage%',
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: Color(0xFFF39322),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              formatPrice(depositAmount),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000080),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
      String label, String iconPath, IconData fallbackIcon, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: iconPath.isNotEmpty
              ? Image.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      fallbackIcon,
                      size: 16,
                      color: Colors.grey[600],
                    );
                  },
                )
              : Icon(
                  fallbackIcon,
                  size: 16,
                  color: Colors.grey[600],
                ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF000080),
          ),
        ),
      ],
    );
  }
}

// DashboardSidebar Widget
class DashboardSidebar extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;

  const DashboardSidebar({
    Key? key,
    required this.isOpen,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isOpen) return const SizedBox.shrink();

    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: onClose,
          child: Container(
            color: Colors.black.withOpacity(0.5),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Sidebar
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.7,
          child: Material(
            color: Colors.white,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Menu',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000080),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onClose,
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildMenuItemWithImage(
                      context,
                      'Inbox',
                      'assets/icons/inbox.png',
                      () {
                        Navigator.pushNamed(context, '/inbox');
                        onClose();
                      },
                    ),      
                    _buildMenuItemWithImage(
                      context,
                      'My Listings',
                      'assets/icons/my-listings.png',
                      () {
                        Navigator.pushNamed(context, '/my-listings');
                        onClose();
                      },
                    ),
                    _buildMenuItemWithImage(
                      context,
                      'Chat',
                      'assets/icons/chat.png',
                      () {
                        Navigator.pushNamed(context, '/chat');
                        onClose();
                      },
                    ),
                    _buildMenuItemWithImage(
                      context,
                      'Get Coordinate',
                      'assets/icons/get-coordinates.png',
                      () {
                        Navigator.pushNamed(context, '/get-coordinate');
                        onClose();
                      },
                    ),
                    _buildMenuItemWithImage(
                      context,
                      'Settings',
                      'assets/icons/settings.png',
                      () {
                        Navigator.pushNamed(context, '/settings');
                        onClose();
                      },
                    ),
                    const Spacer(),
                    _buildMenuItem(
                      context,
                      'Logout',
                      Icons.logout,
                      () {
                        // Handle logout
                        Navigator.pushReplacementNamed(context, '/login');
                        onClose();
                      },
                      isLogout: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : const Color(0xFF000080),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : const Color(0xFF000080),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildMenuItemWithImage(
    BuildContext context,
    String title,
    String iconAsset,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: ImageIcon(
        AssetImage(iconAsset),
        size: 24,
        color: isLogout ? Colors.red : const Color(0xFF000080),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : const Color(0xFF000080),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

// Main Dashboard Screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedCategory = '';
  final bool _showFilterBadge = false;
  List<Listing> _listings = [];
  bool _loading = true;
  String? _error;
  String _activeTab = 'home';
  bool _sidebarOpen = false;
  UserProfile? _userData;
  Map<String, dynamic> _categoryFilters = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchListings();
  }

  void _fetchUserData() {
    // Simulate API call
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _userData = UserProfile(
            id: 'mock-user-id',
            email: 'shamsudeenola6@gmail.com',
            fullName: 'Eniola Ibrahim',
            firstName: 'Eniola',
            lastName: 'Ibrahim',
            avatarUrl: 'assets/images/chatbot.png',
          );
        });
      }
    });
  }

  void _fetchListings() {
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final mockListings = [
          Listing(
            id: 'mock-1',
            title: 'Beautiful Land Property',
            description: 'A spacious land property with great views',
            price: 250000,
            location: '123 Main St',
            city: 'Lagos Island',
            latitude: '6.4365',
            longitude: '3.4849',
            state: 'Lagos',
            country: 'Nigeria',
            category: 'land',
            status: 'active',
            createdAt: DateTime.now().toIso8601String(),
            views: 42,
            listerName: 'Ken Odeh',
            listerDp: 'assets/images/Ken-Odeh.jpg',
            urgencyPeriod: DateTime.now()
                .add(const Duration(days: 7))
                .toIso8601String(),
            listingImage: 'assets/images/land1.jpeg',
            landTitle: 'Certificate of Occupancy',
            landSize: 500,
            listerEmail: 'shamsudeenola6@gmail.com',
            listerWhatsapp: 'https://wa.link/pjaava',
            condition: null,
            quantity: null,
          ),
          Listing(
            id: 'mock-2',
            title: 'Commercial Office Space',
            description: 'Prime location for your business',
            price: 500000,
            location: '456 Business Ave',
            city: 'Ikeja',
            latitude: '6.6018',
            longitude: '3.3515',
            state: 'Lagos',
            country: 'Nigeria',
            category: 'commercial',
            status: 'active',
            createdAt: DateTime.now().toIso8601String(),
            views: 28,
            listerName: 'Jane Smith',
            listerDp: 'assets/images/lister4.jpg',
            urgencyPeriod: DateTime.now()
                .add(const Duration(days: 3))
                .toIso8601String(),
            listingImage: 'assets/images/commercial1.jpg',
            hasInternet: true,
            hasElectricity: true,
            listerEmail: 'mipripity@gmail.com',
            listerWhatsapp: 'https://wa.link/nnzosp',
            condition: null,
            quantity: null,
          ),
          Listing(
            id: 'mock-3',
            title: '3 Bedroom Apartment',
            description: 'Luxury apartment with modern amenities',
            price: 350000,
            location: '789 Residential Blvd',
            city: 'Victoria Island',
            latitude: '6.4281',
            longitude: '3.4216',
            state: 'Lagos',
            country: 'Nigeria',
            category: 'residential',
            status: 'active',
            createdAt: DateTime.now().toIso8601String(),
            views: 56,
            listerName: 'Robert Johnson',
            listerDp: 'assets/images/lister2.jpg',
            urgencyPeriod: DateTime.now()
                .add(const Duration(days: 5))
                .toIso8601String(),
            listingImage: 'assets/images/residential1.jpg',
            bedrooms: 3,
            bathrooms: 2,
            toilets: 3,
            parkingSpaces: 2,
            listerEmail: 'teltasker@gmail.com',
            listerWhatsapp: 'https://wa.link/kfol9k',
            condition: null,
            quantity: null,
          ),
          Listing(
            id: 'mock-4',
            title: 'Premium Office Chair',
            description: 'Ergonomic office chair with lumbar support',
            price: 35000,
            location: '101 Furniture Mall',
            city: 'Lekki',
            latitude: '',
            longitude: '',
            state: 'Lagos',
            country: 'Nigeria',
            category: 'material',
            status: 'active',
            createdAt: DateTime.now().toIso8601String(),
            views: 18,
            listerName: 'Mary Johnson',
            listerDp: 'assets/images/lister3.jpg',
            urgencyPeriod: DateTime.now()
                .add(const Duration(days: 10))
                .toIso8601String(),
            listingImage: 'assets/images/chair1.jpg',
            condition: 'New',
            quantity: '5 Available',
            listerEmail: 'furniture@example.com',
            listerWhatsapp: 'https://wa.link/example',
          ),
        ];

        setState(() {
          _listings = mockListings
              .where((listing) {
                if (_selectedCategory.isNotEmpty && listing.category != _selectedCategory) {
                  return false;
                }
                
                // Apply category-specific filters
                final categoryFilters = _categoryFilters[_selectedCategory] ?? {};
                
                if (categoryFilters.containsKey('minPrice') && categoryFilters.containsKey('maxPrice')) {
                  final minPrice = categoryFilters['minPrice'] as double;
                  final maxPrice = categoryFilters['maxPrice'] as double;
                  final propertyPrice = listing.price; // already a double
                  if (propertyPrice < minPrice || propertyPrice > maxPrice) {
                    return false;
                  }
                }
                
                if (categoryFilters.containsKey('state') && categoryFilters['state'] != null && categoryFilters['state'].isNotEmpty) {
                  if (!listing.location.toLowerCase().contains((categoryFilters['state'] as String).toLowerCase())) {
                    return false;
                  }
                }
                
                if (categoryFilters.containsKey('status') && categoryFilters['status'] != null && categoryFilters['status'].isNotEmpty) {
                  if (listing.status != categoryFilters['status']) {
                    return false;
                  }
                }
                
                return true;
              })
              .toList();
          _loading = false;
        });
      }
    });
  }

  void _handleCategorySelect(String category) {
    setState(() {
      _selectedCategory = category;
      _loading = true;
    });

    // Refetch listings with the new category filter
    _fetchListings();
  }

  // void _handleTabChange(String tab) {
  //   setState(() {
  //     _activeTab = tab;
  //   });

  //   // Handle navigation based on tab
  //   switch (tab) {
  //     case 'home':
  //       // Reset to show all listings when returning to home tab
  //       setState(() {
  //         _selectedCategory = '';
  //         _loading = true;
  //       });
  //       _fetchListings();
  //       break;
  //     case 'invest':
  //       // Navigate to invest screen
  //       Navigator.pushNamed(context, '/invest');
  //       break;
  //     case 'add':
  //       // Navigate to add listing screen
  //       Navigator.pushNamed(context, '/add');
  //       break;
  //     case 'bid':
  //       // Navigate to bid screen
  //       Navigator.pushNamed(context, '/my-bids');
  //       break;
  //     case 'explore':
  //       // Navigate to explore screen
  //       Navigator.pushNamed(context, '/explore');
  //       break;
  //   }
  // }

  void _toggleSidebar() {
    setState(() {
      _sidebarOpen = !_sidebarOpen;
    });
  }

  void _goToNotifications() {
    // Navigate to notifications
    Navigator.pushNamed(context, '/notifications');
  }

  void _goToProfile() {
    // Navigate to profile
    Navigator.pushNamed(context, '/profile');
  }

  void _showFilterForm(String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: FilterForm(
            selectedCategory: category,
            initialFilters: _categoryFilters[category] ?? {},
            onFilterApplied: (filters) {
              setState(() {
                _categoryFilters[category] = filters;
                _loading = true;
              });
              _fetchListings();
              Navigator.pop(context);
            },
            onClose: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Fixed header
              Container(
                color: Colors.white,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Replace the broken header section (around line 1200-1250) with:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Welcome back, ${_userData?.firstName ?? 'User'}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF000080),
                              ),
                            ),
                            Row(
                              children: [
                                // Notification Icon
                                Stack(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.notifications,
                                          size: 20,
                                          color: Color(0xFF000080),
                                        ),
                                        onPressed: _goToNotifications,
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
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                // Profile Image
                                GestureDetector(
                                  onTap: _goToProfile,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFF39322),
                                        width: 2,
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage(
                                          _userData?.avatarUrl ??
                                              'assets/images/mipripity-logo.png',
                                        ),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {
                                          // Handle image loading error
                                          debugPrint('Error loading profile image: $exception');
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Category Tabs
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Residential Button
                              _buildCategoryButton(
                                'residential',
                                'Residential',
                                'assets/images/residential.png',
                                Icons.home,
                              ),

                              // Commercial Button
                              _buildCategoryButton(
                                'commercial',
                                'Commercial',
                                'assets/images/commercial.png',
                                Icons.business,
                              ),

                              // Sidebar Toggle Button
                              Column(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFF39322),
                                          Color(0xFF000080)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.menu,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      onPressed: _toggleSidebar,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Menu',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF000080),
                                    ),
                                  ),
                                ],
                              ),

                              // Land Button
                              _buildCategoryButton(
                                'land',
                                'Land',
                                'assets/images/Land.png',
                                Icons.landscape,
                              ),

                              // Material Button
                              _buildCategoryButton(
                                'material',
                                'Material',
                                'assets/images/Material.png',
                                Icons.inventory,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recommended Properties Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedCategory.isNotEmpty
                                  ? '${_selectedCategory.substring(0, 1).toUpperCase()}${_selectedCategory.substring(1)} Listings'
                                  : 'Recommended For You',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF000080),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_loading)
                              const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFF39322),
                                ),
                              )
                            else if (_error != null)
                              Center(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _loading = true;
                                          _error = null;
                                        });
                                        _fetchListings();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: const Color(0xFFF39322),
                                      ),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            else if (_listings.isEmpty)
                              Center(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.search_off,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No ${_selectedCategory.isNotEmpty ? _selectedCategory : ''} listings found',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _selectedCategory = '';
                                              _loading = true;
                                            });
                                            _fetchListings();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: const Color(0xFFF39322),
                                          ),
                                          child: const Text('Show All'),
                                        ),
                                        const SizedBox(width: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            // Navigate to add listing
                                            Navigator.pushNamed(context, '/add');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: const Color(0xFF000080),
                                          ),
                                          child: const Text('Add Listing'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            else
                              Column(
                                children: _listings
                                    .map((listing) => LayeredListingCard(
                                          listing: listing,
                                        ))
                                    .toList(),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40), // Extra space at bottom
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SharedBottomNavigation(
              activeTab: "home",
              onTabChange: (tab) {
                SharedBottomNavigation.handleNavigation(context, tab);
              },
            ),
          ),

          // Sidebar
          DashboardSidebar(
            isOpen: _sidebarOpen,
            onClose: () => setState(() => _sidebarOpen = false),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
    String category,
    String label,
    String iconPath,
    IconData fallbackIcon,
  ) {
    final isSelected = _selectedCategory == category;
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showFilterForm(category),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF39322) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 5,
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
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    fallbackIcon,
                    size: 24,
                    color: isSelected ? Colors.white : const Color(0xFF000080),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? const Color(0xFFF39322)
                : const Color(0xFF000080),
          ),
        ),
      ],
    );
  }
}
