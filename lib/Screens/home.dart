// ignore_for_file: library_private_types_in_public_api

import 'package:app_develop/Screens/booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
      const HomeContent(),
      BookingScreen(token: widget.token),
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

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

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
                // Welcome message
                Text(
                  'Hello there!', 
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
                      'Popular Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
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
        
        // Popular services
        SliverToBoxAdapter(
          child: SizedBox(
            height: 260,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _buildPopularServiceCard(
                  context,
                  'Premium Salon',
                  'Stylish cuts & coloring',
                  'assets/images/hairshop1.jpg',
                  4.8,
                  () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const HairdressersPage())),
                ),
                _buildPopularServiceCard(
                  context,
                  'Classic Barbershop',
                  'Professional barbers',
                  'assets/images/barbshop1.jpg',
                  4.9,
                  () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const BarbersPage())),
                ),
                _buildPopularServiceCard(
                  context,
                  'Elite Hair Salon',
                  'Luxury treatments',
                  'assets/images/hairshop2.jpg',
                  4.7,
                  () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const HairdressersPage())),
                ),
              ],
            ),
          ),
        ),
        
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Recently Viewed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecentlyViewedItem(
                  context,
                  'Premium Car Repair',
                  'Mechanics',
                  CupertinoIcons.car_detailed,
                ),
                _buildRecentlyViewedItem(
                  context,
                  'Home Plumbing Services',
                  'Plumbers',
                  CupertinoIcons.drop,
                ),
                const SizedBox(height: 100), // Bottom padding to ensure content isn't hidden behind the tab bar
              ],
            ),
          ),
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

  Widget _buildPopularServiceCard(
    BuildContext context,
    String title,
    String subtitle,
    String imagePath,
    double rating,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                imagePath,
                height: 140,
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
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.star_fill,
                        color: Color(0xFFFFC107),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5E5CE6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Book',
                          style: TextStyle(
                            color: Color(0xFF5E5CE6),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
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
  }

  Widget _buildRecentlyViewedItem(
    BuildContext context,
    String title,
    String category,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF5E5CE6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF5E5CE6)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          category,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.grey),
        onTap: () {},
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return dateString;
    }
  }

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
                                  final service = appointment['serviceType'] ?? 'Unknown Service';
                                  final provider = appointment['businessName'] ?? 'Unknown Provider';
                                  final date = appointment['appointment_date'] ?? '';
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
                                                _formatDate(date),
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