import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/modules/reservations/services/geolocator.dart';

const _MAPBOX_TOKEN =
    'pk.eyJ1IjoiYWxleC1hcmd1ZXRhIiwiYSI6ImNtYm9veml5MjA0dDUyd3B3YXI1ZGxqeWsifQ.4WNWf4fqoNZeL5cByoS05A';

class MapPickPage extends StatefulWidget {
  const MapPickPage({super.key});
  @override
  State<MapPickPage> createState() => _MapPickPageState();
}

class _MapPickPageState extends State<MapPickPage> {
  final _map = MapController();
  LatLng? _center;
  LatLng? _picked;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final here = await getCurrentLocation();
      setState(() => _center = here);
    } catch (_) {
      setState(() => _center = LatLng(14.834999, -91.518669));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_center == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elige la ubicación'),
        actions: [
          TextButton(
            onPressed:
                _picked == null ? null : () => Navigator.pop(context, _picked),
            child: const Text('Usar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _center!,
              initialZoom: 16,
              onTap: (tapPos, latlng) => setState(() => _picked = latlng),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$_MAPBOX_TOKEN',
                additionalOptions: {
                  'accessToken': _MAPBOX_TOKEN,
                  'id': 'mapbox/streets-v12',
                },
                userAgentPackageName: 'com.example.mapbox_api',
              ),
              if (_picked != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _picked!,
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
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              onPressed: () => _map.move(_center!, 16),
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
