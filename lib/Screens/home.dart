// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:app_develop/Screens/booking.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Added this import for date formatting

import 'profile_page.dart';
import 'screens/barbers_page.dart';
import 'screens/carpenters_page.dart';
import 'screens/electricians_page.dart';
import 'screens/hairdressers_page.dart';
import 'screens/mechanics_page.dart';
import 'screens/painters_page.dart';
import 'screens/plumbers_page.dart';
import 'screens/see_all_page.dart';
import 'search_page.dart';

// Define ServiceProviderImage class at the top level, outside of any other class
class ServiceProviderImage {
  final String id;
  final String caption;
  final String uploadDate;
  final String providerId;
  final String mimeType;

  ServiceProviderImage({
    required this.id,
    required this.caption,
    required this.uploadDate,
    required this.providerId,
    required this.mimeType,
  });
}

class NsaanoHomePage extends StatefulWidget {
  final String token;

  const NsaanoHomePage({super.key, required this.token});

  @override
  _NsaanoHomePageState createState() => _NsaanoHomePageState();
}

class _NsaanoHomePageState extends State<NsaanoHomePage> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeContent(token: widget.token),
      BookingScreen(token: widget.token, providerId: '',),
      const SearchScreen(),
      ProfilePage(token: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.calendar),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              label: 'Profile',
            ),
          ],
          selectedItemColor: const Color(0xFF5E5CE6), // iOS blue color
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final String token;

  const HomeContent({super.key, required this.token});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isAvailable = true;
  bool _isLoading = true;
  String _userName = '';
  String _formattedDate = '';
  String _formattedTime = '';
  String? _phoneNumber;
  // Store userId once fetched
  Timer? _timer;
  List<ServiceProviderImage> _serviceProviderImages = [];

  @override
  void initState() {
    super.initState();
    _initialize();
    _updateDateTime();
    _fetchServiceProviderImages();
    
    // Update time every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateDateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
      _formattedTime = DateFormat('h:mm a').format(now);
    });
  }

  // Initialize data with a consolidated approach
  Future<void> _initialize() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Get phone number from shared preferences
      final prefs = await SharedPreferences.getInstance();
      _phoneNumber = prefs.getString('phoneNumber');
      
      if (_phoneNumber == null || _phoneNumber!.isEmpty) {
        setState(() {
          _userName = 'there';
          _isAvailable = false;
          _isLoading = false;
        });
        return;
      }
      
      String baseUrl = 'https://salty-citadel-42862-262ec2972a46.herokuapp.com';
      
      // Single API call to get user info including availability and userId
      final userResponse = await http.get(
        Uri.parse('$baseUrl/api/users/profile?phoneNumber=$_phoneNumber'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('User info response: ${userResponse.statusCode} ${userResponse.body}');

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        setState(() {
          _userName = userData['first_name'] ?? 'there';
          _isAvailable = userData['available'] ?? true;
          // Store user ID for future use
          _isLoading = false;
        });
      } else if (userResponse.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile not found. Please complete registration.')),
        );
        setState(() {
          _userName = 'there';
          _isAvailable = false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _userName = 'there';
          _isAvailable = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
      setState(() {
        _userName = 'there';
        _isAvailable = false;
        _isLoading = false;
      });
    }
  }

  // More efficient update availability method
  Future<void> _updateAvailability(bool isAvailable) async {
    if (_phoneNumber == null || _phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to update availability')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      String baseUrl = 'https://salty-citadel-42862-262ec2972a46.herokuapp.com';
      
      debugPrint('Updating availability: Phone = $_phoneNumber, isAvailable = $isAvailable');
      
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/update-availability?phoneNumber=$_phoneNumber&isAvailable=$isAvailable'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      debugPrint('Update availability response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _isAvailable = isAvailable;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You are now ${isAvailable ? 'available' : 'unavailable'} for bookings'),
            backgroundColor: isAvailable ? const Color(0xFF10B981) : Colors.grey.shade700,
          ),
        );
      } else if (response.statusCode == 404) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User profile not found. Please complete registration.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update availability. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating availability: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error updating availability. Please check your connection.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fetch service provider images using the correct endpoint
  Future<void> _fetchServiceProviderImages() async {
    try {
      setState(() {
        _isLoading = true;
      });

      const baseUrl = 'https://salty-citadel-42862-262ec2972a46.herokuapp.com';
      
      // Here we're retrieving service providers first
      final providersResponse = await http.get(
        Uri.parse('$baseUrl/api/providers/all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (providersResponse.statusCode != 200) {
        debugPrint('Failed to fetch providers: ${providersResponse.statusCode}');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final providers = json.decode(providersResponse.body) as List<dynamic>;
      List<ServiceProviderImage> allImages = [];

      // For each provider, fetch their images using the endpoint from ServiceProviderImageController
      for (final provider in providers) {
        final providerId = provider['service_provider_id'];
        if (providerId == null) continue;

        final imagesResponse = await http.get(
          Uri.parse('$baseUrl/api/providers/$providerId/service-images'),
          headers: {'Content-Type': 'application/json'},
        );

        if (imagesResponse.statusCode == 200) {
          final imagesData = json.decode(imagesResponse.body) as List<dynamic>;
          
          for (final image in imagesData) {
            allImages.add(ServiceProviderImage(
              id: image['id'].toString(),
              caption: image['caption'] ?? '',
              uploadDate: image['uploadDate'] ?? '',
              providerId: providerId,
              mimeType: image['mimeType'] ?? 'image/jpeg',
            ));
          }
        }

        // Limit to prevent too many requests
        if (allImages.length >= 10) break;
      }

      setState(() {
        _serviceProviderImages = allImages;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching service provider images: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Nsaano',
            style: TextStyle(
              color: Color(0xFF5E5CE6),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.clock, color: Color(0xFF5E5CE6)),
              onPressed: () {
                _showPastBookings(context);
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Search bar
                CupertinoSearchTextField(
                  placeholder: 'Search for services...',
                  prefixInsets: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Date and time display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formattedDate,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5E5CE6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formattedTime,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    
                    // Availability toggle
                    _isLoading 
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF5E5CE6),
                          ),
                        )
                      : Row(
                          children: [
                            Text(
                              _isAvailable ? 'Available' : 'Unavailable',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _isAvailable ? const Color(0xFF10B981) : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            CupertinoSwitch(
                              value: _isAvailable,
                              activeTrackColor: const Color(0xFF10B981),
                              onChanged: (value) {
                                _updateAvailability(value);
                              },
                            ),
                          ],
                        ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Welcome message
                Text(
                  'Hello $_userName!', 
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find services you need instantly',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        
        // Categories grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildListDelegate([
              _buildCategoryIcon(
                context, 'Barbers', HugeIcons.strokeRoundedChairBarber, 
                const Color(0xFFEEF2FF), const Color(0xFF5E5CE6),
                () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const BarbersPage())),
              ),
              _buildCategoryIcon(
                context, 'Hair', HugeIcons.strokeRoundedHairDryer,
                const Color(0xFFFFF0F7), const Color(0xFFE84A7F),
                () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const HairdressersPage())),
              ),
              _buildCategoryIcon(
                context, 'Mechanics', HugeIcons.strokeRoundedRepair,
                const Color(0xFFF0F9FF), const Color(0xFF0284C7),
                () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const MechanicsPage())),
              ),
              _buildCategoryIcon(
                context, 'Carpenters', HugeIcons.strokeRoundedTable01,
                const Color(0xFFFFFBEB), const Color(0xFFD97706),
                () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const CarpentersPage())),
              ),
              _buildCategoryIcon(
                context, 'Painters', HugeIcons.strokeRoundedPaintBrush02,
                const Color(0xFFECFDF5), const Color(0xFF059669),
                () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const PaintersPage())),
              ),
              _buildCategoryIcon(
                context, 'Electricians', HugeIcons.strokeRoundedElectricPlugs,
                const Color(0xFFFFEDED), const Color(0xFFDC2626),
                () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const ElectriciansPage())),
              ),
              _buildCategoryIcon(
                context, 'Plumbers', HugeIcons.strokeRoundedWaterPump,
                const Color(0xFFEEF2FF), const Color(0xFF4F46E5),
                () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const PlumbersPage())),
              ),
              _buildCategoryIcon(
                context, 'See all', CupertinoIcons.arrow_right_circle_fill,
                const Color(0xFFF3F4F6), Colors.grey.shade700,
                () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const SeeAllPage())),
              ),
            ]),
          ),
        ),
        
        // Service Provider Images Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Service Provider Images',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context, 
                          CupertinoPageRoute(builder: (context) => const SeeAllPage())
                        );
                      },
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          color: Color(0xFF5E5CE6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // Service Provider Images Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: _isLoading
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF5E5CE6),
                    ),
                  ),
                )
              : _serviceProviderImages.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.photo,
                                color: Colors.grey.shade400,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No service provider images available',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final image = _serviceProviderImages[index];
                          return _buildProviderImageCard(
                            context,
                            image.id,
                            image.caption,
                            image.providerId,
                          );
                        },
                        childCount: _serviceProviderImages.length,
                      ),
                    ),
        ),
        
        // Add bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  void _showPastBookings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PastBookingsSheet(),
    );
  }

  Widget _buildCategoryIcon(
    BuildContext context,
    String label,
    IconData icon,
    Color backgroundColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProviderImageCard(
    BuildContext context,
    String imageId,
    String caption,
    String providerId,
  ) {
    const baseUrl = 'https://salty-citadel-42862-262ec2972a46.herokuapp.com';
    final imageUrl = '$baseUrl/api/providers/image/$imageId';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          CupertinoPageRoute(
            builder: (context) => BookingScreen(
              token: widget.token,
              providerId: providerId,
            ),
          )
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF5E5CE6),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(
                        CupertinoIcons.photo,
                        color: Colors.grey.shade400,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caption.isNotEmpty ? caption : 'Service Provider Image',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E5CE6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        color: Color(0xFF5E5CE6),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
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
}
// PastBookingsSheet with phone number authentication
class PastBookingsSheet extends StatefulWidget {
  const PastBookingsSheet({super.key});

  @override
  _PastBookingsSheetState createState() => _PastBookingsSheetState();
}

class _PastBookingsSheetState extends State<PastBookingsSheet> {
  bool _isLoading = true;
  List<dynamic> _appointments = [];
  String _errorMessage = '';
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getUserIdAndFetchAppointments();
  }

  // First get the user ID using the stored phone number, then fetch appointments
  Future<void> _getUserIdAndFetchAppointments() async {
    try {
      // Get the stored phone number from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');
      
      if (phoneNumber == null || phoneNumber.isEmpty) {
        setState(() {
          _errorMessage = 'User phone number not found. Please log in again.';
          _isLoading = false;
        });
        return;
      }
      
      debugPrint('Retrieved phone number: $phoneNumber');
      
      // Get the base URL for API calls
      String baseUrl = 'https://salty-citadel-42862-262ec2972a46.herokuapp.com';
      
      // First API call: Get user_id by phone number
      final userResponse = await http.get(
        Uri.parse('$baseUrl/api/users/findUserIdByPhone?phoneNumber=$phoneNumber'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        _userId = userData['user_id'];
        
        debugPrint('Retrieved user ID: $_userId');
        
        // Now fetch appointments with the obtained user_id
        await _fetchAppointments(baseUrl, _userId!);
      } else {
        setState(() {
          _errorMessage = 'Failed to find user. Status code: ${userResponse.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error in authentication flow: $e';
        _isLoading = false;
      });
      debugPrint('Error in getUserIdAndFetchAppointments: $e');
    }
  }

  // Fetch appointments using the user ID
  Future<void> _fetchAppointments(String baseUrl, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/appointments/users/$userId/appointments'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _appointments = data;
          _isLoading = false;
        });
        debugPrint('Fetched ${_appointments.length} appointments');
        
        // Log a sample appointment to see its structure
        if (_appointments.isNotEmpty) {
          debugPrint('Sample appointment: ${json.encode(_appointments[0])}');
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load appointments. Status code: ${response.statusCode}';
          _isLoading = false;
        });
        debugPrint('Error fetching appointments: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching appointments: $e';
        _isLoading = false;
      });
      debugPrint('Exception in _fetchAppointments: $e');
    }
  }

  // Safely parse the date string
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'No date available';
    }
    
    try {
      // The date format from the API is ISO 8601 format: "2025-05-20T08:30:00.000+00:00"
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return 'Invalid date format';
    }
  }

  // These methods are no longer needed as we're getting data directly from the nested objects

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Past Bookings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5E5CE6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF5E5CE6),
                        ),
                      )
                    : _errorMessage.isNotEmpty
                        ? Center(
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
                                    _errorMessage,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLoading = true;
                                      _errorMessage = '';
                                    });
                                    _getUserIdAndFetchAppointments();
                                  },
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
                          )
                        : _appointments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.calendar,
                                      size: 64,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No bookings found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Your past appointments will appear here',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: _appointments.length,
                                padding: const EdgeInsets.all(16),
                                itemBuilder: (context, index) {
                                  final appointment = _appointments[index];
                                  
                                  // Extract data safely with null checks
                                  final serviceProvider = appointment['serviceProvider'];
                                  final service = serviceProvider != null ? serviceProvider['serviceType'] ?? 'Unknown Service' : 'Unknown Service';
                                  final provider = serviceProvider != null ? serviceProvider['businessName'] ?? 'Unknown Provider' : 'Unknown Provider';
                                  final date = appointment['appointmentDate'] ?? appointment['appointment_date'];
                                  final status = appointment['status'] ?? 'unknown';
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  service,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(status),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  _capitalizeStatus(status),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Provider: $provider',
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                CupertinoIcons.calendar,
                                                size: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatDate(date?.toString()),
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
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
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981); // Green
      case 'confirmed':
        return const Color(0xFF5E5CE6); // Purple
      case 'cancelled':
        return const Color(0xFFEF4444); // Red
      case 'pending':
        return const Color(0xFFF59E0B); // Amber
      default:
        return Colors.grey;
    }
  }

  String _capitalizeStatus(String status) {
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}