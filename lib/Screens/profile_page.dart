import 'dart:convert';
import 'package:app_develop/Screens/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:app_develop/services/auth_service.dart';
import 'package:app_develop/Screens/login.dart';

class ProfilePage extends StatefulWidget {
  final String token;

  const ProfilePage({super.key, required this.token});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? profileData;
  
  @override
  void initState() {
    super.initState();
    // Load user profile when widget initializes
    Future.microtask(() => _loadUserProfile());
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Get the AuthService instance
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Check if there's a saved phone number
      final phoneNumber = authService.phoneNumber;
      if (phoneNumber == null) {
        // Redirect to login if no phone number is saved
        _redirectToLogin();
        return;
      }

      // Use the AuthService.fetchUserProfile() method instead of custom implementation
      final result = await authService.fetchUserProfile();
      
      if (result['success']) {
        // Update the state with the profile data if widget is still mounted
        if (mounted) {
          setState(() {
            profileData = result['data'];
            isLoading = false;
          });
        }
      } else {
        // Handle error from AuthService
        if (mounted) {
          setState(() {
            errorMessage = result['message'];
            isLoading = false;
          });
          _showError(result['message']);
          
          // If authentication expired, redirect to login
          if (result['message'] == 'Authentication expired') {
            _redirectToLogin();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load profile: $e';
          isLoading = false;
        });
        _showError('Error loading profile. Please try again.');
      }
    }
  }

  void _redirectToLogin() {
    // Only navigate if the widget is still mounted
    if (mounted) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    }
  }

  Future<void> _navigateToEditProfile() async {
    if (profileData == null) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    if (token == null) {
      _redirectToLogin();
      return;
    }
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          profileData: profileData!,
          token: token,
        ),
      ),
    );
    
    // If profile was updated, reload the profile data
    if (result == true) {
      _loadUserProfile();
    }
  }

  Future<void> _logout() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.logout();
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      _showError('Logout failed: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF5E5CE6),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF5E5CE6)),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5E5CE6)))
          : errorMessage != null
              ? _buildErrorView()
              : profileData == null
                  ? const Center(child: Text('No profile data found'))
                  : _buildProfileContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              errorMessage ?? 'An error occurred',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadUserProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E5CE6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    final data = profileData!;
    final String firstName = data['first_name'] ?? 'N/A';
    final String lastName = data['last_name'] ?? 'N/A';
    final String email = data['email'] ?? 'N/A';
    final String phone = data['phone_number'] ?? 'N/A';
    final String gender = data['gender'] ?? 'N/A';
    final String age = data['age']?.toString() ?? 'N/A';
    final String address = data['address'] ?? 'N/A';
    final String picture = data['profile_picture'] ?? '';

    return RefreshIndicator(
      onRefresh: () async {
        await _loadUserProfile();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              
              // Profile Picture with Edit Button Overlay
              Stack(
                children: [
                  // Profile Picture
                  _buildProfilePicture(picture),
                  
                  // Edit Button
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _navigateToEditProfile,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF5E5CE6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Full Name
              Text(
                "$firstName $lastName",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 36),
              
              // Profile Details Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5E5CE6),
                            ),
                          ),
                          // Edit Button
                          TextButton.icon(
                            onPressed: _navigateToEditProfile,
                            icon: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Color(0xFF5E5CE6),
                            ),
                            label: const Text(
                              "Edit",
                              style: TextStyle(
                                color: Color(0xFF5E5CE6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      _buildInfoRow(CupertinoIcons.mail, "Email", email),
                      const Divider(height: 24),
                      _buildInfoRow(CupertinoIcons.phone, "Phone", phone),
                      const Divider(height: 24),
                      _buildInfoRow(CupertinoIcons.person, "Gender", gender),
                      const Divider(height: 24),
                      _buildInfoRow(CupertinoIcons.calendar, "Age", age),
                      const Divider(height: 24),
                      _buildInfoRow(CupertinoIcons.location, "Address", address),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 36),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5E5CE6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Method to safely handle profile picture display
  Widget _buildProfilePicture(String pictureData) {
    // If no picture data, display default icon
    if (pictureData.isEmpty) {
      return _buildDefaultProfileIcon();
    }

    // Try to decode the base64 string, display default if it fails
    try {
      // Clean the base64 string before decoding
      String cleanedBase64 = _cleanBase64String(pictureData);
      return CircleAvatar(
        radius: 60,
        backgroundImage: MemoryImage(base64Decode(cleanedBase64)),
      );
    } catch (e) {
      // If decoding fails, display default icon and log error
      debugPrint('Error decoding profile picture: $e');
      return _buildDefaultProfileIcon();
    }
  }

  // Helper method to build default profile icon
  Widget _buildDefaultProfileIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF5E5CE6).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        CupertinoIcons.person_fill,
        size: 60,
        color: Color(0xFF5E5CE6),
      ),
    );
  }

  // Clean base64 string to ensure it's valid
  String _cleanBase64String(String input) {
    // Remove any whitespace, newlines, or other non-base64 characters
    String cleaned = input.trim()
      .replaceAll('\n', '')
      .replaceAll('\r', '')
      .replaceAll(' ', '');
    
    // Ensure padding is correct (must be multiple of 4)
    while (cleaned.length % 4 != 0) {
      cleaned += '=';
    }
    
    return cleaned;
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF5E5CE6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF5E5CE6),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}