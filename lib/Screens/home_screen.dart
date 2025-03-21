import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ServiceProviderProvider>().loadServiceProviders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nsaano'),
      ),
      body: Consumer<ServiceProviderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                provider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: provider.providers.length,
            itemBuilder: (context, index) {
              final serviceProvider = provider.providers[index];
              return ServiceProviderCard(
                provider: serviceProvider,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/provider-details',
                    arguments: serviceProvider.id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
} 