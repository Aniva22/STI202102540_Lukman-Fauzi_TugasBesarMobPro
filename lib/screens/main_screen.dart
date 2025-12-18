import 'package:flutter/material.dart';
import '../models/user.dart'; // Keep for compatibility if needed, though unused
import 'tabs/dashboard_page.dart';
import 'tabs/explorer_page.dart';
import 'tabs/favorites_page.dart';
import 'map_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  final User? user;
  const MainScreen({super.key, this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardPage(
        onSeeAllTap: () {
          setState(() {
            _currentIndex = 1; // Switch to Explorer
          });
        },
      ),
      const ExplorerPage(),
      const MapPage(),
      const FavoritesPage(),
      const ProfilePage(),
    ];
  }

  // Colors for each tab's active state
  final List<Color> _activeColors = [
    Colors.purple, // Dashboard
    const Color(0xFF10B981), // Explorer (Emerald)
    Colors.blue, // Map
    Colors.pink, // Favorites (Pink/Red)
    const Color(0xFF10B981), // Profile (Emerald)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: _activeColors[_currentIndex],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Important for >3 items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explorer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Peta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
