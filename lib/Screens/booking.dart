import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingScreen extends StatefulWidget {
  final String token;

  const BookingScreen({super.key, required this.token});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<dynamic> serviceProviders = [];
  String selectedServiceProviderId = '';
  String userId = '';
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> userAppointments = [];
  // Map to store service provider details for easy lookup
  Map<String, dynamic> providerDetailsMap = {};
  
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // Initialize screen data
  Future<void> _initialize() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    
    try {
      // Get user ID from SharedPreferences
      await _getUserId();
      
      // Fetch service providers
      await fetchServiceProviders();
      
      // Fetch user appointments
      if (userId.isNotEmpty) {
        await fetchUserAppointments();
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error initializing data: $e';
      });
      debugPrint('Error in _initialize: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Get user ID from SharedPreferences
  Future<void> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');
      
      if (phoneNumber == null || phoneNumber.isEmpty) {
        setState(() {
          errorMessage = 'User phone number not found. Please log in again.';
        });
        return;
      }
      
      debugPrint('Retrieved phone number: $phoneNumber');
      
      // Get user_id by phone number
      final response = await http.get(
        Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/users/findUserIdByPhone?phoneNumber=$phoneNumber'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userId = data['user_id'];
        });
        debugPrint('Retrieved user ID: $userId');
      } else {
        setState(() {
          errorMessage = 'Failed to find user. Please check your account.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error retrieving user ID: $e';
      });
      debugPrint('Error in _getUserId: $e');
    }
  }

  // Fetch all service providers and create a lookup map
  Future<void> fetchServiceProviders() async {
    try {
      final response = await http.get(Uri.parse(
          'https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/all'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final providers = json.decode(response.body);
        
        // Create a lookup map for providers by ID
        Map<String, dynamic> providersMap = {};
        for (var provider in providers) {
          providersMap[provider['service_provider_id']] = provider;
        }
        
        setState(() {
          serviceProviders = providers;
          providerDetailsMap = providersMap;
        });
        
        debugPrint('Loaded ${serviceProviders.length} service providers');
      } else {
        throw Exception('Failed to load service providers');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading service providers: $e';
      });
      debugPrint('Error in fetchServiceProviders: $e');
    }
  }

  // Book an appointment
  Future<void> createAppointment() async {
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found. Please log in again.')));
      return;
    }
    
    if (selectedServiceProviderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a service provider')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final appointment = {
        'user_id': userId,
        'service_provider_id': selectedServiceProviderId,
        'appointmentDate': selectedDate.toIso8601String(),
        'status': 'Pending',
      };

      final response = await http.post(
        Uri.parse(
            'https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/appointments/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(appointment),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment created successfully')));
        fetchUserAppointments(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create appointment. Status: ${response.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating appointment: $e')));
      debugPrint('Error in createAppointment: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch all appointments by this user and enrich with provider details
  Future<void> fetchUserAppointments() async {
    if (userId.isEmpty) {
      setState(() {
        userAppointments = [];
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/appointments/users/$userId/appointments'),
      );

      if (response.statusCode == 200) {
        final appointments = json.decode(response.body);
        
        // Enrich appointments with provider details
        List<dynamic> enrichedAppointments = [];
        for (var appointment in appointments) {
          final String providerId = appointment['service_provider_id'];
          final dynamic providerDetails = providerDetailsMap[providerId];
          
          if (providerDetails != null) {
            // Create an enriched appointment with provider details
            Map<String, dynamic> enrichedAppointment = Map.from(appointment);
            enrichedAppointment['businessName'] = providerDetails['businessName'];
            enrichedAppointment['serviceType'] = providerDetails['serviceType'];
            
            enrichedAppointments.add(enrichedAppointment);
          } else {
            // If provider details not found, still add the appointment
            enrichedAppointments.add(appointment);
          }
        }
        
        setState(() {
          userAppointments = enrichedAppointments;
        });
        debugPrint('Fetched and enriched ${userAppointments.length} appointments');
      } else if (response.statusCode == 404) {
        // Not found is okay - just means no appointments
        setState(() {
          userAppointments = [];
        });
      } else {
        debugPrint('Error fetching appointments: ${response.statusCode}');
        setState(() {
          errorMessage = 'Error fetching your appointments';
        });
      }
    } catch (e) {
      debugPrint('Exception in fetchUserAppointments: $e');
      setState(() {
        errorMessage = 'Error fetching appointments: $e';
      });
    }
  }

  // Format date for display
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  // Helper to get color based on appointment status
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

  // Capitalize first letter of status
  String _capitalizeStatus(String status) {
    if (status.isEmpty) return '';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  // Get provider details by ID (for displaying in appointments)
  dynamic _getProviderById(String providerId) {
    return providerDetailsMap[providerId];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking'),
        actions: [
          if (!isLoading && userId.isNotEmpty)
            IconButton(
              icon: const Icon(CupertinoIcons.refresh),
              onPressed: _initialize,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : userId.isEmpty
              ? _buildErrorView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5E5CE6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.person_circle_fill,
                              color: Color(0xFF5E5CE6),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Logged in',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5E5CE6),
                                    ),
                                  ),
                                  Text(
                                    'User ID: $userId',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // New booking section
                      const Text(
                        'New Booking',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Service provider selection
                      Text(
                        'Select Service Provider:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedServiceProviderId.isNotEmpty
                                ? selectedServiceProviderId
                                : null,
                            hint: const Text("Choose a provider"),
                            onChanged: (newValue) {
                              setState(() {
                                selectedServiceProviderId = newValue!;
                              });
                            },
                            items: serviceProviders
                                .map<DropdownMenuItem<String>>((provider) {
                              return DropdownMenuItem<String>(
                                value: provider['service_provider_id'],
                                child: Text(provider['businessName']),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Date selection
                      Text(
                        'Select Appointment Date:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            // Show time picker after selecting date
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDate),
                            );
                            
                            if (pickedTime != null) {
                              setState(() {
                                selectedDate = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${selectedDate.toLocal().day}/${selectedDate.toLocal().month}/${selectedDate.toLocal().year} at ${selectedDate.toLocal().hour}:${selectedDate.toLocal().minute.toString().padLeft(2, '0')}",
                              ),
                              const Icon(CupertinoIcons.calendar, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Book button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: createAppointment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E5CE6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Book Appointment',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Previous appointments section
                      const Text(
                        'Previous Appointments',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Appointments list
                      userAppointments.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32),
                                child: Column(
                                  children: [
                                    Icon(
                                      CupertinoIcons.calendar_badge_minus,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No appointments found',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: userAppointments.length,
                              itemBuilder: (context, index) {
                                final appointment = userAppointments[index];
                                final providerId = appointment['service_provider_id'];
                                final provider = _getProviderById(providerId);
                                
                                // Get service details either from the enriched appointment or from the provider map
                                final String serviceType = appointment['serviceType'] ?? 
                                                          (provider != null ? provider['serviceType'] : 'Unknown Service');
                                final String businessName = appointment['businessName'] ?? 
                                                           (provider != null ? provider['businessName'] : 'Unknown Provider');
                                final date = appointment['appointmentDate'] ?? '';
                                final status = appointment['status'] ?? 'unknown';
                                
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                serviceType,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(status),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                _capitalizeStatus(status),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          businessName,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.calendar,
                                              size: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatDate(date),
                                              style: TextStyle(
                                                fontSize: 13,
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
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              errorMessage.isEmpty
                  ? 'Unable to retrieve your account information'
                  : errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _initialize,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E5CE6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}