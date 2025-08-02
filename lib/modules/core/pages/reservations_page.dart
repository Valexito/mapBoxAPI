import 'package:flutter/material.dart';

class ReservationsPage extends StatelessWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context); // ← Vuelve a HomePage
          },
        ),
        title: const Text('Mis Reservas'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: const Center(
        child: Text(
          'Aquí se mostrarán tus reservas',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
