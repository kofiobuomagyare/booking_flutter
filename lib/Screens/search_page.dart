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
      id: json['id'].toString(),
      name: json['name'] ?? '',
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
  final List<String> _categories = ['All', 'Plumber', 'Electrician', 'Cleaner', 'Painter', 'Carpenter', 'Mechanic'];

  List<ServiceProvider> _providers = [];
  List<ServiceProvider> _filteredProviders = [];
  bool _isLoading = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _getToken().then((_) => fetchServiceProviders()); // Fetch token first, then providers
  }

  // Get token from SharedPreferences
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
        setState(() {
          _providers = data.map((json) => ServiceProvider.fromJson(json)).toList();
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

  void _navigateToBooking() async {
    if (_token == null || _token!.isEmpty) {
      // Try to get token again if it's missing
      await _getToken();
      
      if (_token == null || _token!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required. Please log in.')),
        );
        return;
      }
    }
    
    // Navigate to booking screen with token
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingScreen(token: _token!),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterProviders,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(_categories[index]),
                    selected: _selectedCategory == _categories[index],
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = _categories[index];
                        fetchServiceProviders(_selectedCategory);
                        _searchController.clear(); // Clear search when changing category
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProviders.isEmpty
                    ? const Center(child: Text('No service providers found'))
                    : ListView.builder(
                        itemCount: _filteredProviders.length,
                        itemBuilder: (context, index) {
                          final provider = _filteredProviders[index];
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: provider.imageUrl.isNotEmpty && provider.imageUrl.startsWith('data:image')
                                    ? MemoryImage(base64Decode(provider.imageUrl.split(',')[1]))
                                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                              ),
                              title: Text(provider.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(provider.serviceType),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 16, color: Colors.amber),
                                      Text(' ${provider.rating.toStringAsFixed(1)} · ${provider.completedJobs} jobs'),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: SizedBox(
                                width: 100,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('₵${provider.pricePerHour}/hr', style: const TextStyle(fontSize: 12)),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: 30,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          textStyle: const TextStyle(fontSize: 12),
                                        ),
                                        onPressed: _navigateToBooking,
                                        child: const Text('Book'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              isThreeLine: true,
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