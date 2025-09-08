import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/components/app_drawer.dart';
import 'package:mapbox_api/components/home_bottom_panel.dart';
import 'package:mapbox_api/features/core/widgets/map_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final DraggableScrollableController _bottomCtrl =
      DraggableScrollableController();
  final MapController _mapController = MapController();

  static const double _minSheet = 0.18; // usa el mismo valor que el panel

  void _centerMap(LatLng target) => _mapController.move(target, 16);

  void _minimizePanel() {
    _bottomCtrl.animateTo(
      _minSheet,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Mapa (nos avisa cuando el usuario toca afuera del panel)
          MapWidget(
            mapController: _mapController,
            onMapTap: _minimizePanel, // 👈 minimizar al tocar el mapa
          ),

          // Icono hamburguesa
          Positioned(
            top: 40,
            left: 16,
            child: _FloatingHamburgerIcon(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),

          // Icono settings
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

          // Panel inferior (sin overlay que bloquee la pantalla)
          HomeBottomPanel(controller: _bottomCtrl, onPlaceSelected: _centerMap),
        ],
      ),
    );
  }
}

class _FloatingHamburgerIcon extends StatelessWidget {
  final VoidCallback onTap;
  const _FloatingHamburgerIcon({required this.onTap});
  @override
  Widget build(BuildContext context) =>
      _FloatingIcon(icon: Icons.menu, onTap: onTap);
}

class _FloatingSettingsIcon extends StatelessWidget {
  final VoidCallback onTap;
  const _FloatingSettingsIcon({required this.onTap});
  @override
  Widget build(BuildContext context) =>
      _FloatingIcon(icon: Icons.settings, onTap: onTap);
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
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}
