import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/modules/user_parking/services/geolocator.dart';
import 'package:mapbox_api/modules/user_parking/services/parking_service.dart';
import 'package:mapbox_api/modules/user_parking/models/parking.dart';
import 'package:mapbox_api/modules/core/widgets/home_bottom_parking_details.dart';

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
      setState(() {
        currentPosition = location;
      });
      _loadParkingMarkers();
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');
      setState(() {
        currentPosition = LatLng(14.834999, -91.518669); // fallback en Xela
      });
      _loadParkingMarkers();
    }
  }

  Future<void> _loadParkingMarkers() async {
    final parkingService = ParkingService();
    final parkings = await parkingService.getAllParkings();
    print('Parqueos obtenidos: ${parkings.length}');
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
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      parking.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 9, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList();

    setState(() {
      _parkingMarkers = markers;
    });
  }

  void _showParkingDetails(Parking parking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => HomeParkingDetailBottomSheet(parking: parking),
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

          // 🔄 Botón para reposicionar la cámara
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              onPressed: () {
                if (currentPosition != null) {
                  _mapController.move(currentPosition!, 16);
                }
              },
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
