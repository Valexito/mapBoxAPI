import 'package:flutter/material.dart';
import 'package:mapbox_api/components/home_bottom_panel.dart';
import 'package:mapbox_api/components/app_drawer.dart';
import 'package:mapbox_api/modules/core/pages/favorites_page.dart';
import 'package:mapbox_api/modules/core/pages/profile_page.dart';
import 'package:mapbox_api/modules/core/pages/reservations_page.dart';
import 'package:mapbox_api/modules/core/widgets/map_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(), // Drawer ya maneja navegación con push
      body: Stack(
        children: [
          const MapWidget(), // solo el mapa como contenido principal
          // Ícono hamburguesa
          Positioned(
            top: 40,
            left: 16,
            child: _FloatingHamburgerIcon(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),

          // Ícono de configuración
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

          // Panel deslizable inferior
          const HomeBottomPanel(),
        ],
      ),
    );
  }
}

// Botón hamburguesa
class _FloatingHamburgerIcon extends StatelessWidget {
  final VoidCallback onTap;
  const _FloatingHamburgerIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _FloatingIcon(icon: Icons.menu, onTap: onTap);
  }
}

// Botón de configuración
class _FloatingSettingsIcon extends StatelessWidget {
  final VoidCallback onTap;
  const _FloatingSettingsIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _FloatingIcon(icon: Icons.settings, onTap: onTap);
  }
}

// Widget reutilizable para íconos flotantes
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
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}
