import 'package:flutter/material.dart';

class ReserveSpacePage extends StatefulWidget {
  final String parkingName; // Puedes pasar el nombre o ID si lo necesitas

  const ReserveSpacePage({super.key, required this.parkingName});

  @override
  State<ReserveSpacePage> createState() => _ReserveSpacePageState();
}

class _ReserveSpacePageState extends State<ReserveSpacePage> {
  final int totalSpaces = 20;
  final List<int> occupiedSpaces = [2, 5, 6, 9]; // Mock: espacios ocupados

  int? selectedSpace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reservar espacio en ${widget.parkingName}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: totalSpaces,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (_, index) {
                  final spaceNumber = index + 1;
                  final isOccupied = occupiedSpaces.contains(spaceNumber);
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
                      child: Text(
                        'Espacio\n$spaceNumber',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed:
                  selectedSpace != null
                      ? () {
                        // Aquí iría la lógica de guardar la reserva
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Reserva confirmada'),
                                content: Text(
                                  'Reservaste el espacio $selectedSpace en ${widget.parkingName}.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                        );
                      }
                      : null,
              icon: const Icon(Icons.check),
              label: const Text('Confirmar Reserva'),
            ),
          ],
        ),
      ),
    );
  }
}
