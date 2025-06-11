import 'package:flutter/material.dart';
import 'shared/bottom_navigation.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State variables for toggles
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _inAppNotifications = true;
  bool _locationTracking = true;
  bool _biometricAuth = false;
  bool _twoFactorAuth = false;
  String _selectedTheme = 'System';
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'NGN (₦)';
  String _selectedDistanceUnit = 'Kilometers';
  String _selectedDateFormat = 'DD/MM/YYYY';
  String _activeTab = 'home';
  
  // Mock user data
  final Map<String, dynamic> _userData = {
    'id': 'user-123',
    'fullName': 'Eniola Ibrahim',
    'email': 'shamsudeenola6@gmail.com',
    'phone': '+234 812 345 6789',
    'avatarUrl': 'assets/images/chatbot.png',
    'joinDate': '12 Jan 2023',
    'lastLogin': '2 hours ago',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF000080),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF000080)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF000080)),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80), // Space for bottom nav
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _buildProfileSection(),
                
                const SizedBox(height: 16),
                
                // Account Settings
                _buildSettingsSection(
                  'Account Settings',
                  [
                    _buildSettingItem(
                      'Change Password',
                      Icons.lock_outline,
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                    _buildSettingItem(
                      'Update Email Address',
                      Icons.email_outlined,
                      onTap: () => _showUpdateEmailDialog(context),
                    ),
                    _buildSettingItem(
                      'Manage Linked Accounts',
                      Icons.link,
                      onTap: () {},
                    ),
                    _buildSwitchItem(
                      'Two-Factor Authentication',
                      Icons.security_outlined,
                      _twoFactorAuth,
                      (value) {
                        setState(() {
                          _twoFactorAuth = value;
                        });
                        if (value) {
                          _showSetupTwoFactorDialog(context);
                        }
                      },
                    ),
                    _buildSettingItem(
                      'Delete Account',
                      Icons.delete_outline,
                      textColor: Colors.red,
                      onTap: () => _showDeleteAccountDialog(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Notification Preferences
                _buildSettingsSection(
                  'Notification Preferences',
                  [
                    _buildSwitchItem(
                      'Push Notifications',
                      Icons.notifications_outlined,
                      _pushNotifications,
                      (value) {
                        setState(() {
                          _pushNotifications = value;
                        });
                      },
                    ),
                    _buildSwitchItem(
                      'Email Notifications',
                      Icons.email_outlined,
                      _emailNotifications,
                      (value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                      },
                    ),
                    _buildSwitchItem(
                      'SMS Notifications',
                      Icons.sms_outlined,
                      _smsNotifications,
                      (value) {
                        setState(() {
                          _smsNotifications = value;
                        });
                      },
                    ),
                    _buildSwitchItem(
                      'In-App Notifications',
                      Icons.app_registration,
                      _inAppNotifications,
                      (value) {
                        setState(() {
                          _inAppNotifications = value;
                        });
                      },
                    ),
                    _buildSettingItem(
                      'Custom Notification Settings',
                      Icons.tune,
                      onTap: () {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // App Preferences
                _buildSettingsSection(
                  'App Preferences',
                  [
                    _buildDropdownItem(
                      'Theme',
                      Icons.brightness_6_outlined,
                      _selectedTheme,
                      ['System', 'Light', 'Dark'],
                      (value) {
                        setState(() {
                          _selectedTheme = value;
                        });
                      },
                    ),
                    _buildDropdownItem(
                      'Language',
                      Icons.language,
                      _selectedLanguage,
                      ['English', 'French', 'Yoruba', 'Hausa', 'Igbo'],
                      (value) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      },
                    ),
                    _buildDropdownItem(
                      'Currency',
                      Icons.currency_exchange,
                      _selectedCurrency,
                      ['NGN (₦)', 'USD (\$)', 'EUR (€)', 'GBP (£)'],
                      (value) {
                        setState(() {
                          _selectedCurrency = value;
                        });
                      },
                    ),
                    _buildDropdownItem(
                      'Distance Unit',
                      Icons.straighten,
                      _selectedDistanceUnit,
                      ['Kilometers', 'Miles'],
                      (value) {
                        setState(() {
                          _selectedDistanceUnit = value;
                        });
                      },
                    ),
                    _buildDropdownItem(
                      'Date Format',
                      Icons.calendar_today,
                      _selectedDateFormat,
                      ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'],
                      (value) {
                        setState(() {
                          _selectedDateFormat = value;
                        });
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Privacy and Security
                _buildSettingsSection(
                  'Privacy and Security',
                  [
                    _buildSettingItem(
                      'Privacy Policy',
                      Icons.privacy_tip_outlined,
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      'Terms of Service',
                      Icons.description_outlined,
                      onTap: () {},
                    ),
                    _buildSwitchItem(
                      'Location Tracking',
                      Icons.location_on_outlined,
                      _locationTracking,
                      (value) {
                        setState(() {
                          _locationTracking = value;
                        });
                      },
                    ),
                    _buildSwitchItem(
                      'Biometric Authentication',
                      Icons.fingerprint,
                      _biometricAuth,
                      (value) {
                        setState(() {
                          _biometricAuth = value;
                        });
                        if (value) {
                          _showBiometricSetupDialog(context);
                        }
                      },
                    ),
                    _buildSettingItem(
                      'Data Sharing Preferences',
                      Icons.share_outlined,
                      onTap: () {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Help and Support
                _buildSettingsSection(
                  'Help and Support',
                  [
                    _buildSettingItem(
                      'Contact Support',
                      Icons.support_agent,
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      'FAQs',
                      Icons.question_answer_outlined,
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      'Report a Problem',
                      Icons.bug_report_outlined,
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      'Submit Feedback',
                      Icons.feedback_outlined,
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      'Rate the App',
                      Icons.star_outline,
                      onTap: () {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // App Information
                _buildSettingsSection(
                  'App Information',
                  [
                    _buildInfoItem('App Version', '1.0.3'),
                    _buildInfoItem('Build Number', '103'),
                    _buildInfoItem('Last Updated', '15 May 2023'),
                    _buildInfoItem('Developer', 'Mipripity Technologies'),
                    _buildSettingItem(
                      'License Information',
                      Icons.info_outline,
                      onTap: () {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showLogoutDialog(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40), // Extra space at bottom
              ],
            ),
          ),
          
          // Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SharedBottomNavigation(
              activeTab: "settings", // Changed from "explore" to "settings" since this is the settings screen
              onTabChange: (tab) {
                SharedBottomNavigation.handleNavigation(context, tab);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Profile Section Widget
  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
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
                        image: AssetImage(_userData['avatarUrl']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF39322),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Handle profile picture change
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData['fullName'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000080),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userData['email'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userData['phone'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Member since',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userData['joinDate'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF000080),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to edit profile
                  _showEditProfileDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFFF39322),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Edit Profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Settings Section Widget
  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000080),
              ),
            ),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }

  // Setting Item Widget
  Widget _buildSettingItem(
    String title,
    IconData icon, {
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: textColor ?? const Color(0xFF000080),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor ?? Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // Switch Item Widget
  Widget _buildSwitchItem(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: const Color(0xFF000080),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFF39322),
            activeTrackColor: const Color(0xFFF39322).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  // Dropdown Item Widget
  Widget _buildDropdownItem(
    String title,
    IconData icon,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return InkWell(
      onTap: () {
        _showDropdownDialog(context, title, value, options, onChanged);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: const Color(0xFF000080),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // Info Item Widget
  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Handle tab change
  void _handleTabChange(String tab) {
    setState(() {
      _activeTab = tab;
    });

    // Handle navigation based on tab
    switch (tab) {
      case 'home':
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 'invest':
        Navigator.pushNamed(context, '/invest');
        break;
      case 'add':
        Navigator.pushNamed(context, '/add');
        break;
      case 'bid':
        Navigator.pushNamed(context, '/my-bids');
        break;
      case 'explore':
        Navigator.pushNamed(context, '/explore');
        break;
    }
  }

  // Show Edit Profile Dialog
  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: _userData['fullName']);
    final emailController = TextEditingController(text: _userData['email']);
    final phoneController = TextEditingController(text: _userData['phone']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF000080),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Update user data
              setState(() {
                _userData['fullName'] = nameController.text;
                _userData['email'] = emailController.text;
                _userData['phone'] = phoneController.text;
              });
              Navigator.pop(context);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully'),
                  backgroundColor: Color(0xFF000080),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF39322),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show Change Password Dialog
  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Change Password',
            style: TextStyle(
              color: Color(0xFF000080),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrentPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureCurrentPassword = !obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate passwords
                if (newPasswordController.text.isEmpty ||
                    currentPasswordController.text.isEmpty ||
                    confirmPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('New passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                // Close dialog
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully'),
                    backgroundColor: Color(0xFF000080),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF39322),
              ),
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  // Show Update Email Dialog
  void _showUpdateEmailDialog(BuildContext context) {
    final emailController = TextEditingController(text: _userData['email']);
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Update Email Address',
          style: TextStyle(
            color: Color(0xFF000080),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'New Email Address',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Update email
              setState(() {
                _userData['email'] = emailController.text;
              });
              Navigator.pop(context);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email updated successfully'),
                  backgroundColor: Color(0xFF000080),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF39322),
            ),
            child: const Text('Update Email'),
          ),
        ],
      ),
    );
  }

  // Show Delete Account Dialog
  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Warning: This action cannot be undone. All your data will be permanently deleted.',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter Password to Confirm',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete account logic would go here
              Navigator.pop(context);
              
              // Navigate to login screen
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  // Show Setup Two Factor Dialog
  void _showSetupTwoFactorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Setup Two-Factor Authentication',
          style: TextStyle(
            color: Color(0xFF000080),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Two-factor authentication adds an extra layer of security to your account. We will send a verification code to your phone number when you log in.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Verification Method',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone_android),
                        const SizedBox(width: 8),
                        Text(_userData['phone']),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _twoFactorAuth = false;
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Setup 2FA logic would go here
              Navigator.pop(context);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Two-factor authentication enabled'),
                  backgroundColor: Color(0xFF000080),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF39322),
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  // Show Biometric Setup Dialog
  void _showBiometricSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Setup Biometric Authentication',
          style: TextStyle(
            color: Color(0xFF000080),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fingerprint,
                size: 64,
                color: Color(0xFFF39322),
              ),
              SizedBox(height: 16),
              Text(
                'Biometric authentication allows you to log in using your fingerprint or face recognition.',
              ),
              SizedBox(height: 16),
              Text(
                'To set up biometric authentication, you will need to verify your identity first.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _biometricAuth = false;
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Setup biometric auth logic would go here
              Navigator.pop(context);
              
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Biometric authentication enabled'),
                  backgroundColor: Color(0xFF000080),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF39322),
            ),
            child: const Text('Set Up'),
          ),
        ],
      ),
    );
  }

  // Show Dropdown Dialog
  void _showDropdownDialog(
    BuildContext context,
    String title,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select $title',
          style: const TextStyle(
            color: Color(0xFF000080),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return ListTile(
                title: Text(option),
                trailing: option == currentValue
                    ? const Icon(
                        Icons.check,
                        color: Color(0xFFF39322),
                      )
                    : null,
                onTap: () {
                  onChanged(option);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // Show Help Dialog
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Settings Help',
          style: TextStyle(
            color: Color(0xFF000080),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Section',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text('• Tap on the camera icon to change your profile picture'),
              Text('• Tap "Edit Profile" to update your personal information'),
              SizedBox(height: 16),
              Text(
                'Account Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text('• Change your password and email address'),
              Text('• Enable two-factor authentication for added security'),
              SizedBox(height: 16),
              Text(
                'Notification Preferences',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text('• Toggle different notification types on or off'),
              SizedBox(height: 16),
              Text(
                'Need more help?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text('Contact our support team at support@mipripity.com'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF39322),
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // Show Logout Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(
            color: Color(0xFF000080),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Logout logic would go here
              Navigator.pop(context);
              
              // Navigate to login screen
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// BottomNavigation Widget
class BottomNavigation extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChange;

  const BottomNavigation({
    Key? key,
    required this.activeTab,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context,
                'home',
                'assets/icons/home.png',
                'Home',
              ),
              _buildNavItem(
                context,
                'invest',
                'assets/icons/invest.png',
                'Invest',
              ),
              _buildAddButton(context),
              _buildNavItem(
                context,
                'bid',
                'assets/icons/chat.png',
                'Bid',
              ),
              _buildNavItem(
                context,
                'explore',
                'assets/icons/explore.png',
                'Explore',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String tab,
    String iconPath,
    String label,
  ) {
    final isActive = activeTab == tab;
    return GestureDetector(
      onTap: () => onTabChange(tab),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            isActive ? 'assets/icons/${tab}_active.png' : 'assets/icons/$tab.png',
            width: 24,
            height: 24,
            color: isActive ? const Color(0xFFF39322) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
              color: isActive ? const Color(0xFFF39322) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => onTabChange('add'),
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF39322), Color(0xFF000080)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
