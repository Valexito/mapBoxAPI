import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/components/ui/my_button.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/modules/user_parking/models/parking.dart';
import 'package:mapbox_api/modules/user_parking/models/reservation.dart';

class ReserveSpacePage extends StatefulWidget {
  final Parking parking;

  const ReserveSpacePage({super.key, required this.parking});

  @override
  State<ReserveSpacePage> createState() => _ReserveSpacePageState();
}

class _ReserveSpacePageState extends State<ReserveSpacePage> {
  final int totalSpaces = 20;
  final List<int> occupiedSpaces = [2, 5, 6, 9]; // Simulación
  int? selectedSpace;

  Future<void> _confirmReservation() async {
    final confirm = await ConfirmReservationDialog.show(
      context,
      destination: LatLng(widget.parking.lat, widget.parking.lng),
      parkingName: widget.parking.name,
    );

    if (confirm == true && selectedSpace != null) {
      final reservation = Reservation(
        userId: FirebaseAuth.instance.currentUser!.uid,
        parkingId: widget.parking.id,
        parkingName: widget.parking.name,
        spaceNumber: selectedSpace!,
        reservedAt: DateTime.now(),
        lat: widget.parking.lat,
        lng: widget.parking.lng,
      );

      await FirebaseFirestore.instance
          .collection('reservations')
          .add(reservation.toMap());

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/routeView',
        ModalRoute.withName('/homeNav'),
        arguments: {
          'destination': LatLng(widget.parking.lat, widget.parking.lng),
          'parkingName': widget.parking.name,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF007BFF),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MyText(
                      text: 'Selecciona tu espacio',
                      fontSize: 20,
                      variant: MyTextVariant.title,
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.builder(
                        itemCount: totalSpaces,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                        itemBuilder: (_, index) {
                          final spaceNumber = index + 1;
                          final isOccupied = occupiedSpaces.contains(
                            spaceNumber,
                          );
                          final isSelected = selectedSpace == spaceNumber;

                          Color color;
                          if (isOccupied) {
                            color = Colors.red;
                          } else if (isSelected) {
                            color = Colors.blueAccent;
                          } else {
                            color = Colors.green;
                          }

                          return GestureDetector(
                            onTap:
                                isOccupied
                                    ? null
                                    : () {
                                      setState(() {
                                        selectedSpace = spaceNumber;
                                      });
                                    },
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: MyText(
                                text: 'Espacio\n$spaceNumber',
                                fontSize: 13,
                                variant: MyTextVariant.body,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    MyButton(
                      text: 'Confirmar Reserva',
                      color: const Color(0xFF007BFF),
                      onTap: selectedSpace != null ? _confirmReservation : null,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_parking,
                    size: 40,
                    color: Color(0xFF007BFF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmReservationDialog {
  static Future<bool?> show(
    BuildContext context, {
    required LatLng destination,
    required String parkingName,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Confirmar reserva?'),
            content: Text('Estás reservando en: $parkingName'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
  }
}
