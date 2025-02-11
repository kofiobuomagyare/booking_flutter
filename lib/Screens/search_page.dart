import 'package:flutter/material.dart';

// Service Provider Model
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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Plumbing', 'Electrical', 'Cleaning', 'Painting', 'Carpentry'];

  // Sample data with more providers for demonstration
  final List<ServiceProvider> _providers = [
    ServiceProvider(
      id: '1',
      name: 'Aaron Smith',
      category: 'Plumbing',
      rating: 0,
      completedJobs: 0,
      hourlyRate: 45,
      imageUrl: 'assets/images/profile.jpg',
    ),
    ServiceProvider(
      id: '2',
      name: 'Brian Johnson',
      category: 'Electrical',
      rating: 0,
      completedJobs: 0,
      hourlyRate: 55,
      imageUrl: 'assets/images/profile1.jpg',
    ),
    ServiceProvider(
      id: '3',
      name: 'Charlie Wilson',
      category: 'Cleaning',
      rating: 0,
      completedJobs: 0,
      hourlyRate: 35,
      imageUrl: 'assets/images/profile2.jpg',
    ),
  ];

  List<ServiceProvider> _filteredProviders = [];

  @override
  void initState() {
    super.initState();
    // Sort providers alphabetically by name initially
    _filteredProviders = List.from(_providers)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  void _filterResults(String query) {
    setState(() {
      _filteredProviders = _providers.where((provider) {
        final nameMatch = provider.name.toLowerCase().contains(query.toLowerCase());
        final categoryMatch = _selectedCategory == 'All' || provider.category == _selectedCategory;
        return nameMatch && categoryMatch;
      }).toList();
      
      // Sort filtered results alphabetically
      _filteredProviders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
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
                  onPressed: () {
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
                        const Text('New Provider'),
                      ],
                    ),
                    trailing: SizedBox(  // Wrap in SizedBox with fixed width
                      width: 80,         // Adjust width as needed
                      child: Column(
                        mainAxisSize: MainAxisSize.min,  // Use minimum space needed
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '\$${provider.hourlyRate}/hr',
                            style: const TextStyle(fontSize: 12),  // Reduce font size if needed
                          ),
                          const SizedBox(height: 4),  // Add small spacing
                          SizedBox(  // Constrain button size
                            height: 30,  // Adjust height as needed
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),  // Reduce padding
                              ),
                              onPressed: () => _showProviderDetails(provider),
                              child: const Text(
                                'View',
                                style: TextStyle(fontSize: 12),  // Reduce font size
                              ),
                            ),
                          ),
                        ],
                      ),
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