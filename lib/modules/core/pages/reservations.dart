import 'package:flutter/material.dart';

class MyReservations extends StatelessWidget {
  const MyReservations({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F5F5), // color claro de fondo
      body: Center(
        child: Text(
          'Mis Reservas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
