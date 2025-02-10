import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Plumbing', 'Electrical', 'Cleaning', 'Painting', 'Carpentry'];
  
  // Sample data - replace with your actual data
  final List<ServiceProvider> _providers = [
    ServiceProvider(
      id: '1',
      name: 'John Doe',
      category: 'Plumbing',
      rating: 4.5,
      completedJobs: 150,
      hourlyRate: 50,
      imageUrl: 'assets/profile.png',
    ),
    // Add more providers
  ];

  List<ServiceProvider> _filteredProviders = [];

  @override
  void initState() {
    super.initState();
    _filteredProviders = _providers;
  }

  void _filterResults(String query) {
    setState(() {
      _filteredProviders = _providers.where((provider) {
        final nameMatch = provider.name.toLowerCase().contains(query.toLowerCase());
        final categoryMatch = _selectedCategory == 'All' || provider.category == _selectedCategory;
        return nameMatch && categoryMatch;
      }).toList();
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
                hintText: 'Search for services or providers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterResults,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Categories
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
                        _filterResults(_searchController.text);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // Results
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProviders.length,
              itemBuilder: (context, index) {
                final provider = _filteredProviders[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(provider.imageUrl),
                    ),
                    title: Text(provider.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(provider.category),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            Text(' ${provider.rating}'),
                            Text(' • ${provider.completedJobs} jobs'),
                          ],
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('\$${provider.hourlyRate}/hr'),
                        ElevatedButton(
                          onPressed: () => _showProviderDetails(provider),
                          child: const Text('View'),
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

  void _showProviderDetails(ServiceProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      backgroundImage: AssetImage(provider.imageUrl),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            provider.category,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 20, color: Colors.amber),
                              Text(' ${provider.rating}'),
                              Text(' • ${provider.completedJobs} jobs'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                  'Professional with extensive experience in the field. Available for both emergency and scheduled services.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Services Offered',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Wrap(
                  spacing: 8,
                  children: [
                    Chip(label: Text('Service 1')),
                    Chip(label: Text('Service 2')),
                    Chip(label: Text('Service 3')),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement booking logic
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking ${provider.name}')),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Book Now'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ServiceProvider {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int completedJobs;
  final double hourlyRate;
  final String imageUrl;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.completedJobs,
    required this.hourlyRate,
    required this.imageUrl,
  });
}