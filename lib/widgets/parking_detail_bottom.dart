import 'package:flutter/material.dart';
import 'package:mapbox_api/pages/reserve_space_page.dart';
import '../models/parking.dart';

class ParkingDetailBottomSheet extends StatelessWidget {
  final Parking parking;

  const ParkingDetailBottomSheet({super.key, required this.parking});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parking.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Precio: Q${parking.price}'),
          Text('Espacios disponibles: ${parking.spaces}'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context); // Cierra el bottom sheet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReserveSpacePage(parkingName: parking.name),
                ),
              );
            },
            icon: const Icon(Icons.book_online),
            label: const Text('Reservar espacio'),
          ),
        ],
      ),
    );
  }
}
