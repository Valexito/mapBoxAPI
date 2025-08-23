// lib/modules/core/widgets/map_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/modules/core/services/favorite_service.dart';
import 'package:mapbox_api/modules/core/widgets/home_bottom_parking_details.dart';
import 'package:mapbox_api/modules/reservations/services/geolocator.dart';
import 'package:mapbox_api/modules/reservations/services/parking_service.dart';
import 'package:mapbox_api/modules/reservations/models/parking.dart';

const MAP_BOX_ACCESS_TOKEN =
    'pk.eyJ1IjoiYWxleC1hcmd1ZXRhIiwiYSI6ImNtYm9veml5MjA0dDUyd3B3YXI1ZGxqeWsifQ.4WNWf4fqoNZeL5cByoS05A';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  LatLng? currentPosition;
  List<Marker> _parkingMarkers = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
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
    final parkingService = ParkingService();
    final parkings = await parkingService.getAllParkings();

    final markers =
        parkings.map((parking) {
          return Marker(
            point: LatLng(parking.lat, parking.lng),
            width: 100,
            height: 80,
            child: GestureDetector(
              onTap: () => _showParkingDetails(parking),
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
                      parking.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 9, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList();

    setState(() => _parkingMarkers = markers);
  }

  void _showParkingDetails(Parking parking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        bool? localFav; // null hasta que el stream responda

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return StreamBuilder<bool>(
              stream: FavoriteService.instance.isFavoriteStream(parking.id),
              builder: (context, snap) {
                if (localFav == null) {
                  localFav = snap.data ?? false;
                }
                final uiFav = localFav!;

                return HomeParkingDetailBottomSheet(
                  parking: parking,
                  isFavorite: uiFav,
                  onToggleFavorite: () async {
                    final next = !uiFav;
                    setSheetState(() => localFav = next); // flip inmediato
                    try {
                      if (next) {
                        await FavoriteService.instance.add(parking);
                      } else {
                        await FavoriteService.instance.removeByParkingId(
                          parking.id,
                        );
                      }
                    } catch (e) {
                      setSheetState(() => localFav = !next); // revertir
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
  void _zoomBy(double delta) {
    final cam = _mapController.camera; // center & zoom actuales (flutter_map 6)
    final newZoom = (cam.zoom + delta).clamp(2.0, 20.0);
    _mapController.move(cam.center, newZoom.toDouble());
  }

  void _centerOnUser() {
    if (currentPosition != null) {
      _mapController.move(currentPosition!, 16.0);
    }
  }

  Widget _roundCtrl(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.add, color: Colors.black), // placeholder
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentPosition == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPosition!,
              initialZoom: 16,
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

          // ===== Controles flotantes: +  -  centrar =====
          // Colocados por encima de la search bar (ajusta "bottom" si tu barra es más alta)
          Positioned(
            right: 16,
            bottom: 200, // ≈ encima del bottom search bar
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zoom +
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 3,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _zoomBy(1),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.add, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Zoom -
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 3,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _zoomBy(-1),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.remove, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Centrar cámara en usuario
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 3,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _centerOnUser,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.my_location, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
