import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/components/my_text.dart';
import 'package:mapbox_api/modules/user_parking/pages/route_view_page.dart';

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
              text: '✅ ¡Reserva confirmada!',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
              color: Colors.green,
            ),
            const SizedBox(height: 10),
            const MyText(
              text: '¿Deseas ir al parqueo ahora?',
              fontSize: 14,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const MyText(text: 'Cancelar', color: Colors.grey),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => RouteViewPage(
                              destination: destination,
                              parkingName: parkingName,
                            ),
                      ),
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
                    text: 'Ir ahora',
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
