import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'booking.dart';

class ServiceProvider {
  final String id;
  final String name;
  final String serviceType;
  final double rating;
  final int completedJobs;
  final double pricePerHour;
  final String imageUrl;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.rating,
    required this.completedJobs,
    required this.pricePerHour,
    required this.imageUrl,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['service_provider_id'].toString(),
      name: json['businessName'] ?? '',
      serviceType: json['serviceType'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      completedJobs: json['completedJobs'] ?? 0,
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
      imageUrl: json['profilePicture'] ?? '',
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All', 'Plumber', 'Electrician', 'Cleaner', 'Painter', 'Carpenter', 'Mechanic'
  ];

  List<ServiceProvider> _providers = [];
  List<ServiceProvider> _filteredProviders = [];
  bool _isLoading = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _getToken().then((_) => fetchServiceProviders());
  }

  Future<void> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _token = prefs.getString('token') ?? '';
      });

      if (_token == null || _token!.isEmpty) {
        print('Warning: Token is empty or null');
      }
    } catch (e) {
      print('Error retrieving token: $e');
    }
  }

Future<void> fetchServiceProviders([String? category]) async {
  setState(() => _isLoading = true);

  final Uri url = category == null || category == 'All'
      ? Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/all')
      : Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/service_type?serviceTypes=$category');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      
      // Fetch completed jobs count for each provider
      final providersWithJobs = await Future.wait(data.map((json) async {
        final providerId = json['service_provider_id'].toString();
        final numericId = int.tryParse(providerId.replaceAll('nsaserv', ''));
        
        if (numericId != null) {
          try {
            final completedJobsResponse = await http.get(
              Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/appointments/appointments/completed/count?providerId=$numericId')
            );
            
            if (completedJobsResponse.statusCode == 200) {
              json['completedJobs'] = jsonDecode(completedJobsResponse.body);
            } else {
              json['completedJobs'] = 0;
            }
          } catch (e) {
            json['completedJobs'] = 0;
          }
        } else {
          json['completedJobs'] = 0;
        }
        
        return ServiceProvider.fromJson(json);
      }).toList());

      setState(() {
        _providers = providersWithJobs;
        _filteredProviders = _providers;
      });
    } else {
      print('Failed to load providers: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching providers: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}
  void _navigateToBooking(String providerId) async {
    if (_token == null || _token!.isEmpty) {
      await _getToken();

      if (_token == null || _token!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required. Please log in.')),
        );
        return;
      }
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(token: _token!, providerId: providerId),
        ),
      );
    }
  }

  void _filterProviders(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProviders = _providers;
      } else {
        _filteredProviders = _providers
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()) ||
                          p.serviceType.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  // Improved image handling function
 Widget buildProviderAvatar(String imageUrl) {
  if (imageUrl.isEmpty) {
    return const CircleAvatar(
      backgroundImage: AssetImage('assets/images/default_avatar.jpg'),
      radius: 30,
    );
  }

  try {
    // Check if it's a base64 string, even with a leading slash
    final isBase64 = imageUrl.length > 100 && !imageUrl.contains('http');

    if (isBase64) {
      // Remove prefix if it exists (just in case)
      final base64Str = imageUrl.contains(',') ? imageUrl.split(',').last : imageUrl;
      return CircleAvatar(
        backgroundImage: MemoryImage(base64Decode(base64Str)),
        radius: 30,
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        radius: 30,
      );
    }
  } catch (e) {
    print('Error loading image: $e');
    return CircleAvatar(
      backgroundColor: Colors.grey.shade300,
      radius: 30,
      child: const Icon(Icons.person, size: 30, color: Colors.grey),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text('Find Services', style: TextStyle(fontWeight: FontWeight.bold)),
      
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
           
            child: Column(
              children: [
                // Search bar with rounded corners and shadow
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search for services...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: _filterProviders,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // Category filters with horizontal scrolling
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == _categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(_categories[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = _categories[index];
                        fetchServiceProviders(_selectedCategory);
                        _searchController.clear();
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: theme.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? theme.primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              },
            ),
          ),
          
          // Results count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filteredProviders.length} service providers found',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          // Provider list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProviders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No service providers found',
                              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try changing your search criteria',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        itemCount: _filteredProviders.length,
                        itemBuilder: (context, index) {
                          final provider = _filteredProviders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Provider avatar
                                  buildProviderAvatar(provider.imageUrl),
                                  const SizedBox(width: 16),
                                  
                                  // Provider info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          provider.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            provider.serviceType,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.primaryColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 16, color: Colors.amber),
                                            Text(
                                              ' ${provider.rating.toStringAsFixed(1)}',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              ' · ${provider.completedJobs} jobs completed',
                                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Price and book button
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₵${provider.pricePerHour.toStringAsFixed(2)}/hr',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () => _navigateToBooking(provider.id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: theme.primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        ),
                                        child: const Text('Book Now'),
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}