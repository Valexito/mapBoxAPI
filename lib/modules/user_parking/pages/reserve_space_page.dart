import 'package:flutter/material.dart';
import 'package:mapbox_api/components/my_button.dart';
import 'package:mapbox_api/components/my_text.dart';
import 'package:mapbox_api/modules/user_parking/models/parking.dart';
import '../widgets/confirm_reservation_dialog.dart';

class ReserveSpacePage extends StatefulWidget {
  final Parking parking;

  const ReserveSpacePage({super.key, required this.parking});

  @override
  State<ReserveSpacePage> createState() => _ReserveSpacePageState();
}

class _ReserveSpacePageState extends State<ReserveSpacePage> {
  final int totalSpaces = 20;
  final List<int> occupiedSpaces = [2, 5, 6, 9];
  int? selectedSpace;

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
                      fontWeight: FontWeight.bold,
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
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
                      onTap:
                          selectedSpace != null
                              ? () async {
                                await ConfirmReservationDialog.show(
                                  context,
                                  onConfirm: () {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Reserva confirmada en espacio $selectedSpace',
                                        ),
                                      ),
                                    );
                                    // Aquí puedes insertar lógica real, como guardar en Firestore o navegar.
                                  },
                                );
                              }
                              : null,
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
