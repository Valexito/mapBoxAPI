import 'package:flutter/material.dart';
import 'package:mapbox_api/components/ui/my_text.dart';

class RouteBottomInfoCard extends StatelessWidget {
  final String parkingName;
  final String distance;
  final String duration;
  final VoidCallback onNavigate;
  final VoidCallback onCancelLater;

  const RouteBottomInfoCard({
    super.key,
    required this.parkingName,
    required this.distance,
    required this.duration,
    required this.onNavigate,
    required this.onCancelLater,
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
          MyText(text: parkingName, fontSize: 18, variant: MyTextVariant.title),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.directions_walk,
                size: 20,
                color: Colors.black54,
              ),
              const SizedBox(width: 6),
              MyText(
                text: 'Distancia: $distance',
                variant: MyTextVariant.normal,
              ),
              const SizedBox(width: 16),
              const Icon(Icons.timer, size: 20, color: Colors.black54),
              const SizedBox(width: 6),
              MyText(
                text: 'Tiempo estimado: $duration',
                variant: MyTextVariant.normal,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Botón azul: Navegar
              Expanded(
                child: GestureDetector(
                  onTap: onNavigate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: MyText(
                        text: "Navegar",
                        variant: MyTextVariant.body,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botón blanco con borde azul: Más tarde
              Expanded(
                child: GestureDetector(
                  onTap: onCancelLater,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1976D2),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: MyText(
                        text: "Más tarde",
                        variant: MyTextVariant.body,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
