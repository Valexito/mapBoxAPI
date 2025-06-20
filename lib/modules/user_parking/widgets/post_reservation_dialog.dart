import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../pages/route_view_page.dart'; // ← futura página para mostrar ruta

class PostReservationDialog {
  static Future<void> show(
    BuildContext context, {
    required LatLng destination,
    required String parkingName,
  }) async {
    return showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Reserva exitosa'),
            content: const Text('¿Deseas iniciar la ruta al parqueo ahora?'),
            actions: [
              TextButton(
                child: const Text('Más tarde'),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el dialog
                  Navigator.of(context).pop(); // Vuelve al mapa
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.directions),
                label: const Text('Ir ahora'),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el dialog
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => RouteViewPage(
                            destination: destination,
                            parkingName: parkingName,
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
    );
  }
}
