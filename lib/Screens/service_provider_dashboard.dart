import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/service_provider_auth_provider.dart';

class ServiceProviderDashboard extends StatefulWidget {
  const ServiceProviderDashboard({super.key});

  @override
  State<ServiceProviderDashboard> createState() => _ServiceProviderDashboardState();
}

class _ServiceProviderDashboardState extends State<ServiceProviderDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Provider Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await context.read<ServiceProviderAuthProvider>().logout();
              if (mounted) {
                navigator.pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildAppointmentsTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${context.watch<ServiceProviderAuthProvider>().currentProvider?.name ?? "Provider"}',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          _buildStatCard(
            title: 'Today\'s Appointments',
            value: '0',
            icon: Icons.calendar_today,
            color: Colors.blue,
          ),
          SizedBox(height: 16.h),
          _buildStatCard(
            title: 'Total Earnings',
            value: '\$0',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
          SizedBox(height: 16.h),
          _buildStatCard(
            title: 'Rating',
            value: '0.0',
            icon: Icons.star,
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return const Center(
      child: Text('Appointments will be shown here'),
    );
  }

  Widget _buildProfileTab() {
    final provider = context.watch<ServiceProviderAuthProvider>().currentProvider;
    if (provider == null) {
      return const Center(child: Text('No provider data available'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50.w,
              backgroundImage: provider.profileImage != null
                  ? NetworkImage(provider.profileImage!)
                  : null,
              child: provider.profileImage == null
                  ? Icon(Icons.person, size: 50.w, color: Colors.grey)
                  : null,
            ),
          ),
          SizedBox(height: 24.h),
          _buildProfileField('Name', provider.name),
          _buildProfileField('Email', provider.email),
          _buildProfileField('Phone', provider.phone),
          _buildProfileField('Service Type', provider.serviceType),
          if (provider.description != null)
            _buildProfileField('Description', provider.description!),
          if (provider.pricePerHour != null)
            _buildProfileField('Price per Hour', '\$${provider.pricePerHour}'),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final nameController = TextEditingController(text: provider.name);
                final phoneController = TextEditingController(text: provider.phone);
                final descriptionController = TextEditingController(text: provider.description);
                final priceController = TextEditingController(text: provider.pricePerHour?.toString());

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Edit Profile'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            hintText: 'Enter your name',
                          ),
                          controller: nameController,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            hintText: 'Enter your phone number',
                          ),
                          controller: phoneController,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter your service description',
                          ),
                          controller: descriptionController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Price per Hour',
                            hintText: 'Enter your price per hour',
                          ),
                          controller: priceController,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final updatedProvider = provider.copyWith(
                              name: nameController.text,
                              phone: phoneController.text,
                              description: descriptionController.text,
                              pricePerHour: double.tryParse(priceController.text),
                            );
                            
                            final navigator = Navigator.of(context);
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            await context.read<ServiceProviderAuthProvider>().updateProfile(updatedProvider);
                            
                            if (mounted) {
                              navigator.pop();
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(content: Text('Profile updated successfully')),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
                              );
                            }
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(icon, size: 40.w, color: color),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 