import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng? selectedPosition;

  @override
  Widget build(BuildContext context) {
    final initialPosition = LatLng(14.8349, -91.5186); // Xela como fallback

    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona ubicación')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: initialPosition,
          initialZoom: 16,
          onTap: (_, point) => setState(() => selectedPosition = point),
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYWxleC1hcmd1ZXRhIiwiYSI6ImNtYm9veml5MjA0dDUyd3B3YXI1ZGxqeWsifQ.4WNWf4fqoNZeL5cByoS05A',
            additionalOptions: {
              'accessToken': 'MAPBOX_ACCESS_TOKEN',
              'id': 'mapbox/streets-v12',
            },
          ),
          if (selectedPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: selectedPosition!,
                  width: 50,
                  height: 50,
                  child: const Icon(
                    Icons.location_on,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton:
          selectedPosition == null
              ? null
              : FloatingActionButton.extended(
                onPressed: () => Navigator.pop(context, selectedPosition),
                label: const Text('Confirmar'),
                icon: const Icon(Icons.check),
              ),
    );
  }
}
