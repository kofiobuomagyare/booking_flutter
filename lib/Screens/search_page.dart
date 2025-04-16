import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Service Provider Model
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
      imageUrl: json['profilePicture'] ?? '', // assuming it's a base64 string
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchServiceProviders(); // Fetch all initially
  }

  Future<void> fetchServiceProviders([String? category]) async {
    setState(() => _isLoading = true);
    final Uri url = category == null || category == 'All'
        ? Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/all') // adjust accordingly
        : Uri.parse('https://salty-citadel-42862-262ec2972a46.herokuapp.com/api/providers/service_type?serviceTypes=$category');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _providers = data.map((json) => ServiceProvider.fromJson(json)).toList();
        });
      } else {
        print('Failed to load providers');
      }
    } catch (e) {
      print('Error fetching providers: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showProviderDetails(ServiceProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: provider.imageUrl.startsWith('data:image')
                      ? MemoryImage(base64Decode(provider.imageUrl.split(',')[1]))
                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.name, style: Theme.of(context).textTheme.headlineSmall),
                      Text(provider.serviceType, style: Theme.of(context).textTheme.titleMedium),
                      const Text('New Provider'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About', style: Theme.of(context).textTheme.titleLarge),
                const Text('Professional with extensive experience in the field.'),
                const SizedBox(height: 16),
                Text('Services Offered', style: Theme.of(context).textTheme.titleLarge),
                const Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text('Service 1')),
                    Chip(label: Text('Service 2')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Book Now'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              onChanged: (query) {
                // Optional: filter locally by name
                setState(() {
                  _providers = _providers.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
                });
              },
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
                : ListView.builder(
                    itemCount: _providers.length,
                    itemBuilder: (context, index) {
                      final provider = _providers[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: provider.imageUrl.startsWith('data:image')
                                ? MemoryImage(base64Decode(provider.imageUrl.split(',')[1]))
                                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                          ),
                          title: Text(provider.name),
                          subtitle: Text(provider.serviceType),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('₵${provider.pricePerHour}/hr', style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                                onPressed: () => _showProviderDetails(provider),
                                child: const Text('View', style: TextStyle(fontSize: 12)),
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
