import 'package:flutter/material.dart';
import 'package:mapbox_api/components/home_bottom_panel.dart';
import 'package:mapbox_api/components/app_drawer.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MapScreen(),
    const MyReservations(),
    const FavoritesPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        onSelectTab: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
      body: Stack(
        children: [
          _pages[_selectedIndex],

          // Íconos flotantes SOLO en la vista de mapa (índice 0)
          if (_selectedIndex == 0) ...[
            Positioned(
              top: 40,
              left: 16,
              child: _FloatingHamburgerIcon(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: _FloatingSettingsIcon(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder:
                        (_) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            ListTile(
                              leading: Icon(Icons.language),
                              title: Text('Cambiar idioma'),
                            ),
                            ListTile(
                              leading: Icon(Icons.brightness_6),
                              title: Text('Cambiar tema'),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ),

            // ✅ Panel deslizable solo en vista de mapa
            const HomeBottomPanel(),
          ],
        ],
      ),
    );
  }
}

class _FloatingHamburgerIcon extends StatelessWidget {
  final VoidCallback onTap;
  const _FloatingHamburgerIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _FloatingIcon(icon: Icons.menu, onTap: onTap);
  }
}

class _FloatingSettingsIcon extends StatelessWidget {
  final VoidCallback onTap;
  const _FloatingSettingsIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _FloatingIcon(icon: Icons.settings, onTap: onTap);
  }
}

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FloatingIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
        ),
        //color floating buttons home page
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}
