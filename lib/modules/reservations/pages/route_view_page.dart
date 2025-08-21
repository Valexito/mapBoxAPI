import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/modules/reservations/pages/map_navigation_page.dart';
import 'package:mapbox_api/modules/reservations/services/geolocator.dart';
import 'package:mapbox_api/modules/reservations/services/location_tracker.dart';
import 'package:mapbox_api/modules/reservations/services/mapbox_directions_service.dart';
import 'package:mapbox_api/modules/reservations/widgets/route_bottom_info_card.dart';

const MAP_BOX_ACCESS_TOKEN =
    'pk.eyJ1IjoiYWxleC1hcmd1ZXRhIiwiYSI6ImNtYm9veml5MjA0dDUyd3B3YXI1ZGxqeWsifQ.4WNWf4fqoNZeL5cByoS05A';

class RouteViewPage extends StatefulWidget {
  final LatLng destination;
  final String parkingName;

  const RouteViewPage({
    super.key,
    required this.destination,
    required this.parkingName,
  });

  @override
  State<RouteViewPage> createState() => _RouteViewPageState();
}

class _RouteViewPageState extends State<RouteViewPage> {
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  final _mapController = MapController();
  StreamSubscription<Position>? _positionSubscription;

  LatLng? _currentPosition;
  List<LatLng> _routePoints = [];

  String _distance = '…';
  String _duration = '…';

  @override
  void initState() {
    super.initState();
    _prepareRoute();
  }

  Future<void> _prepareRoute() async {
    try {
      final position = await getCurrentLocation();
      final directions = MapboxDirectionsService();

      final points = await directions.getRouteCoordinates(
        origin: position,
        destination: widget.destination,
      );
      final duration = await directions.getRouteDuration(
        origin: position,
        destination: widget.destination,
      );
      final distance = await directions.getRouteDistance(
        origin: position,
        destination: widget.destination,
      );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _routePoints = points;
        _duration = duration;
        _distance = distance;
      });

      _positionSubscription = LocationTracker.getPositionStream().listen((
        pos,
      ) async {
        final updated = LatLng(pos.latitude, pos.longitude);
        if (!mounted) return;
        setState(() => _currentPosition = updated);

        // Recalcular y filtrar ruta para no dibujar puntos ya recorridos
        final newRoute = await directions.getRouteCoordinates(
          origin: updated,
          destination: widget.destination,
        );
        final filtered = _filterFutureRoutePoints(updated, newRoute);

        if (!mounted) return;
        setState(() => _routePoints = filtered);

        _mapController.move(updated, _mapController.camera.zoom);
      });
    } catch (e) {
      debugPrint('Error cargando ruta: $e');
    }
  }

  List<LatLng> _filterFutureRoutePoints(LatLng currentPos, List<LatLng> route) {
    const threshold = 10.0; // metros
    final d = Distance();
    return route.skipWhile((p) => d(currentPos, p) < threshold).toList();
    // si la ruta viniera invertida, invierte arriba
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // loader inicial
    if (_currentPosition == null || _routePoints.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F4F7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // UI consistente con la app: header navy + tarjeta info, botón recenter con gradiente.
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Stack(
        children: [
          // Mapa
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition!,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$MAP_BOX_ACCESS_TOKEN',
                userAgentPackageName: 'com.example.mapbox_api',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 6,
                    color: navyBottom,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  _pinMarker(
                    point: _currentPosition!,
                    bg: Colors.white,
                    icon: const Icon(
                      Icons.my_location,
                      color: Color(0xFF16A34A),
                      size: 22,
                    ),
                  ),
                  _pinMarker(
                    point: widget.destination,
                    bg: Colors.white,
                    icon: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Header degradado (igual lenguaje que Login/Profile)
          _TopGradientHeader(
            title: 'Ruta a',
            subtitle: widget.parkingName,
            onBack: () => Navigator.pop(context),
          ),

          // Tarjeta flotante con distancia y tiempo
          Positioned(
            top: 100,
            left: 16,
            right: 16,
            child: _RouteSummaryCard(distance: _distance, duration: _duration),
          ),

          // Botón recenter con gradiente (en vez de FAB gris)
          Positioned(
            right: 16,
            bottom: 140, // arriba del bottomSheet
            child: _RecenterButton(
              onTap: () {
                final pos = _currentPosition;
                if (pos != null) {
                  _mapController.move(pos, _mapController.camera.zoom);
                }
              },
            ),
          ),
        ],
      ),

      // Tu tarjeta inferior existente
      bottomSheet: RouteBottomInfoCard(
        parkingName: widget.parkingName,
        distance: _distance,
        duration: _duration,
        onNavigate: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MapNavigationPage()),
          );
        },
        onCancelLater: () {
          Navigator.pushReplacementNamed(context, '/homePage');
        },
      ),
    );
  }
}

/// ===== Widgets de UI (coherentes con tu diseño) =====

class _TopGradientHeader extends StatelessWidget {
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _TopGradientHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [navyTop, navyBottom],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MyText(text: 'RUTA', variant: MyTextVariant.title),
                    const SizedBox(height: 2),
                    MyText(
                      text: '$title ${subtitle}',
                      variant: MyTextVariant.normal,
                      fontSize: 13,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  final String distance;
  final String duration;

  const _RouteSummaryCard({required this.distance, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.directions_walk, color: Color(0xFF1B3A57)),
            const SizedBox(width: 10),
            Expanded(
              child: MyText(
                text: 'Distancia: $distance',
                variant: MyTextVariant.body,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.timer_outlined, color: Color(0xFF1B3A57)),
            const SizedBox(width: 8),
            MyText(
              text: duration,
              variant: MyTextVariant.bodyBold,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecenterButton extends StatelessWidget {
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  final VoidCallback onTap;
  const _RecenterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [navyTop, navyBottom],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.my_location, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

Marker _pinMarker({
  required LatLng point,
  required Color bg,
  required Widget icon,
}) {
  return Marker(
    point: point,
    width: 44,
    height: 44,
    child: Container(
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Center(child: icon),
    ),
  );
}
