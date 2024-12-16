import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'explore_page.dart'; // Import other screens
import 'search_page.dart';
import 'profile_page.dart';

class NsaanoHomePage extends StatefulWidget {
  const NsaanoHomePage({super.key});

  @override
  _NsaanoHomePageState createState() => _NsaanoHomePageState();
}

class _NsaanoHomePageState extends State<NsaanoHomePage> {
  int _currentIndex = 0; // Track the current selected tab

  // List of screens for navigation
  final List<Widget> _screens = [
    const HomeContent(), // The content of your home screen
    const ExploreScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nsaano',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff6161b8),
      ),
      body: _screens[_currentIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Change the current tab
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: const Color(0xFFFFC107),
        unselectedItemColor: Colors.white,
        backgroundColor: const Color(0xff6161b8),
      ),
    );
  }
}

// Extract the home content to keep the file organized
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search here...',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Here, you meet all your needs',
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            children: [
              _buildCategoryIcon('Barbers', HugeIcons.strokeRoundedChairBarber, const Color(0xff6161b8)),
              _buildCategoryIcon('Hairdressers', HugeIcons.strokeRoundedHairDryer, const Color(0xff6161b8)),
              _buildCategoryIcon('Mechanics', HugeIcons.strokeRoundedRepair, const Color(0xff6161b8)),
              _buildCategoryIcon('Carpenters', HugeIcons.strokeRoundedTable01, const Color(0xff6161b8)),
              _buildCategoryIcon('Painters', HugeIcons.strokeRoundedPaintBrush02, const Color(0xff6161b8)),
              _buildCategoryIcon('Electricians', HugeIcons.strokeRoundedElectricPlugs, const Color(0xff6161b8)),
              _buildCategoryIcon('Plumbers', HugeIcons.strokeRoundedGasPipe, const Color(0xff6161b8)),
              _buildCategoryIcon('Tailors', HugeIcons.strokeRoundedHanger, const Color(0xff6161b8)),
              _buildCategoryIcon('Event planners', HugeIcons.strokeRoundedCalendar03, const Color(0xff6161b8)),
              _buildCategoryIcon('Nail Technicians', HugeIcons.strokeRoundedAiBeautify, const Color(0xff6161b8)),
              _buildCategoryIcon('Apartment', HugeIcons.strokeRoundedBuilding05, const Color(0xff6161b8)),
              _buildCategoryIcon('See all', HugeIcons.strokeRoundedMore03, const Color(0xff6161b8)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Popular Services',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildPopularServiceItem('Salon', 'assets/images/hairshop1.jpg'),
              _buildPopularServiceItem('Barbershop', 'assets/images/barbshop1.jpg'),
              _buildPopularServiceItem('Salon', 'assets/images/hairshop2.jpg'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(String label, IconData icon, Color iconColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40.0, color: iconColor),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
          ),
        ),
      ],
    );
  }

  Widget _buildPopularServiceItem(String label, String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            width: 200,
            height: 120,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
