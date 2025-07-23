import 'package:flutter/material.dart';
import 'package:mapbox_api/components/bottom_nav_bar.dart';
import 'package:mapbox_api/modules/core/pages/favorites_page.dart';
import 'package:mapbox_api/modules/core/pages/profile_page.dart';
import 'package:mapbox_api/modules/core/pages/home_page.dart';
import 'package:mapbox_api/modules/core/pages/reservations.dart';

class HomeNavigationPage extends StatefulWidget {
  const HomeNavigationPage({super.key});

  @override
  State<HomeNavigationPage> createState() => _HomeNavigationPageState();
}

class _HomeNavigationPageState extends State<HomeNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MapScreen(),
    const MyReservations(),
    const FavoritesPage(), // Aquí podrías poner FavoritesPage()
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
