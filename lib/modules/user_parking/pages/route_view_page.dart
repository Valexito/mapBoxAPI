import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/modules/user_parking/services/geolocator.dart';
import 'package:mapbox_api/modules/user_parking/services/mapbox_directions_service.dart';
import 'package:mapbox_api/modules/user_parking/services/location_tracker.dart';
import 'package:geolocator/geolocator.dart';

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
  LatLng? _currentPosition;
  List<LatLng> _routePoints = [];
  final _mapController = MapController();
  StreamSubscription<Position>? _positionSubscription;

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

      setState(() {
        _currentPosition = position;
        _routePoints = points;
      });

      // Escuchar ubicación en tiempo real
      _positionSubscription = LocationTracker.getPositionStream().listen((
        pos,
      ) async {
        final updatedPos = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _currentPosition = updatedPos;
        });

        final newRoute = await directions.getRouteCoordinates(
          origin: updatedPos,
          destination: widget.destination,
        );

        // Eliminar parte ya recorrida
        final filteredRoute = _filterFutureRoutePoints(updatedPos, newRoute);

        setState(() {
          _routePoints = filteredRoute;
        });

        _mapController.move(updatedPos, _mapController.camera.zoom);
      });
    } catch (e) {
      debugPrint('Error cargando ruta: $e');
    }
  }

  List<LatLng> _filterFutureRoutePoints(LatLng currentPos, List<LatLng> route) {
    const threshold = 10.0; // en metros
    final distance = Distance();
    return route.skipWhile((point) {
      final d = distance(currentPos, point);
      return d < threshold;
    }).toList();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null || _routePoints.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentPosition != null) {
            _mapController.move(_currentPosition!, _mapController.camera.zoom);
          }
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.my_location),
      ),

      appBar: AppBar(title: Text('Ruta hacia ${widget.parkingName}')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: _currentPosition!, initialZoom: 15),
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
                strokeWidth: 5,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentPosition!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              Marker(
                point: widget.destination,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
