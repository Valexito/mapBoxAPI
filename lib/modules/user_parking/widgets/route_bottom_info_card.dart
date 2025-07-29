import 'package:flutter/material.dart';

class RouteBottomInfoCard extends StatelessWidget {
  final String parkingName;
  final String distance;
  final String duration;
  final VoidCallback onNavigate;
  final VoidCallback onCancel;

  const RouteBottomInfoCard({
    super.key,
    required this.parkingName,
    required this.distance,
    required this.duration,
    required this.onNavigate,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parkingName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.directions_walk, size: 20),
              const SizedBox(width: 6),
              Text('Distancia: $distance'),
              const SizedBox(width: 16),
              const Icon(Icons.timer, size: 20),
              const SizedBox(width: 6),
              Text('Tiempo estimado: $duration'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/mapNavigation');
                  },
                  icon: const Icon(Icons.navigation),
                  label: const Text('Iniciar navegación'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/homeNav',
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text('Más tarde'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
