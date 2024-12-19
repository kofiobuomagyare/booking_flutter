import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Handle back navigation
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/profile.jpg', // Replace with actual image path
                  fit: BoxFit.cover,
                  width: 100, // Double the radius
                  height: 100, // Double the radius
                ),
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              'KPORTIMAH GIDEON',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'kportimahgideon72@gmail.com',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            ProfileOption(
              icon: Icons.lock,
              label: 'Privacy',
              onTap: () {
                // Handle Privacy action
              },
            ),
            ProfileOption(
              icon: Icons.history,
              label: 'Booking History',
              onTap: () {
                // Handle Booking History action
              },
            ),
            ProfileOption(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () {
                // Handle Help & Support action
              },
            ),
            ProfileOption(
              icon: Icons.person_add,
              label: 'Invite a Friend',
              onTap: () {
                // Handle Invite a Friend action
              },
            ),
            ProfileOption(
              icon: Icons.settings,
              label: 'Settings',
              onTap: () {
                // Handle Settings action
              },
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  // Handle Logout action
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
                height: 20), // Adds space for better scrolling experience
          ],
        ),
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileOption({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xff6161b8), width: 2),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xff6161b8), size: 24),
              const SizedBox(width: 15),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
