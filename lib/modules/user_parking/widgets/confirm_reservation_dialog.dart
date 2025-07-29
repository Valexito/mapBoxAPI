import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/components/my_text.dart';

class ConfirmReservationDialog extends StatelessWidget {
  final LatLng destination;
  final String parkingName;

  const ConfirmReservationDialog({
    super.key,
    required this.destination,
    required this.parkingName,
  });

  static Future<void> show(
    BuildContext context, {
    required LatLng destination,
    required String parkingName,
  }) async {
    await showDialog(
      context: context,
      builder:
          (_) => ConfirmReservationDialog(
            destination: destination,
            parkingName: parkingName,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MyText(
              text: '¿Reservar el espacio No. 2?',
              fontSize: 20,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const MyText(
                    text: 'Cancelar',
                    color: Color.fromARGB(255, 64, 63, 63),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cierra el diálogo

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/routeView',
                      ModalRoute.withName(
                        '/homeNav',
                      ), // 👈 cambia si tu home tiene otro nombre
                      arguments: {
                        'destination': destination,
                        'parkingName': parkingName,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const MyText(
                    text: 'Confirmar',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
