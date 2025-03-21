import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider_provider.dart';
import '../models/service_provider.dart';
import '../widgets/service_provider_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load service providers when the screen initializes
    Future.microtask(() =>
        Provider.of<ServiceProviderProvider>(context, listen: false)
            .loadServiceProviders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nsaano'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search screen
            },
          ),
        ],
      ),
      body: Consumer<ServiceProviderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadServiceProviders(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.providers.isEmpty) {
            return const Center(
              child: Text('No service providers available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.providers.length,
            itemBuilder: (context, index) {
              final serviceProvider = provider.providers[index];
              return ServiceProviderCard(provider: serviceProvider);
            },
          );
        },
      ),
    );
  }
} 