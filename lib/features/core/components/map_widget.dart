import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/features/core/services/favorite_service.dart';
import 'package:mapbox_api/features/core/components/home_bottom_parking_details.dart';
import 'package:mapbox_api/features/reservations/services/geolocator.dart';
import 'package:mapbox_api/features/reservations/services/parking_service.dart';
import 'package:mapbox_api/features/reservations/models/parking.dart';

const MAP_BOX_ACCESS_TOKEN =
    'pk.eyJ1IjoiYWxleC1hcmd1ZXRhIiwiYSI6ImNtYm9veml5MjA0dDUyd3B3YXI1ZGxqeWsifQ.4WNWf4fqoNZeL5cByoS05A';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key, this.mapController, this.onMapTap});

  final MapController? mapController;
  final VoidCallback? onMapTap;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng? currentPosition;
  List<Marker> _parkingMarkers = [];
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController ?? MapController();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final location = await getCurrentLocation();
      setState(() => currentPosition = location);
      _loadParkingMarkers();
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');
      setState(() => currentPosition = LatLng(14.834999, -91.518669));
      _loadParkingMarkers();
    }
  }

  Future<void> _loadParkingMarkers() async {
    final parkings = await ParkingService().getAllParkings();
    setState(() {
      _parkingMarkers =
          parkings.map((p) {
            return Marker(
              point: LatLng(p.lat, p.lng),
              width: 100,
              height: 80,
              child: GestureDetector(
                onTap: () => _showParkingDetails(p),
                child: Column(
                  children: [
                    const Icon(
                      Icons.directions_car_filled,
                      color: Colors.blue,
                      size: 30,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(221, 255, 255, 255),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        p.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList();
    });
  }

  void _showParkingDetails(Parking parking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        bool? localFav;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return StreamBuilder<bool>(
              stream: FavoriteService.instance.isFavoriteStream(parking.id),
              builder: (context, snap) {
                if (localFav == null) localFav = snap.data ?? false;
                final uiFav = localFav!;
                return HomeParkingDetailBottomSheet(
                  parking: parking,
                  isFavorite: uiFav,
                  onToggleFavorite: () async {
                    final next = !uiFav;
                    setSheetState(() => localFav = next);
                    try {
                      if (next) {
                        await FavoriteService.instance.add(parking);
                      } else {
                        await FavoriteService.instance.removeByParkingId(
                          parking.id,
                        );
                      }
                    } catch (_) {
                      setSheetState(() => localFav = !next);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No se pudo actualizar favoritos'),
                          ),
                        );
                      }
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // ===== Controles de cámara / zoom =====
  void zoomBy(double delta) {
    final cam = _mapController.camera;
    final newZoom = (cam.zoom + delta).clamp(2.0, 20.0);
    _mapController.move(cam.center, newZoom.toDouble());
  }

  void centerOn(LatLng target, {double zoom = 16}) =>
      _mapController.move(target, zoom);

  void centerOnUser() {
    if (currentPosition != null) _mapController.move(currentPosition!, 16.0);
  }

  @override
  Widget build(BuildContext context) {
    // ⛔ Nada de Scaffold aquí: HomePage ya tiene el suyo
    if (currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: currentPosition!,
            initialZoom: 16,
            onTap:
                (_, __) =>
                    widget.onMapTap?.call(), // minimiza panel en HomePage
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$MAP_BOX_ACCESS_TOKEN',
              additionalOptions: {
                'accessToken': MAP_BOX_ACCESS_TOKEN,
                'id': 'mapbox/streets-v12',
              },
              userAgentPackageName: 'com.example.mapbox_api',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: currentPosition!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.green,
                    size: 40,
                  ),
                ),
                ..._parkingMarkers,
              ],
            ),
          ],
        ),

        // Controles flotantes
        Positioned(
          right: 16,
          bottom: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _roundBtn(icon: Icons.add, onTap: () => zoomBy(1)),
              const SizedBox(height: 10),
              _roundBtn(icon: Icons.remove, onTap: () => zoomBy(-1)),
              const SizedBox(height: 10),
              _roundBtn(icon: Icons.my_location, onTap: centerOnUser),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roundBtn({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.black),
        ),
      ),
    );
  }
}
