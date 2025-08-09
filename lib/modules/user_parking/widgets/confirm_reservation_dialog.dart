import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/modules/user_parking/models/reservation.dart';

class ReservationsPage extends StatelessWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mis Reservas'),
          backgroundColor: const Color(0xFF1976D2),
        ),
        body: const Center(
          child: MyText(
            text: 'Debes iniciar sesión para ver tus reservas.',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final String userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Mis Reservas'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('reservations')
                .where('userId', isEqualTo: userId)
                .orderBy('reservedAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar reservas.'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: MyText(
                text: 'No tienes reservas aún.',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            );
          }

          final reservations =
              docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Reservation.fromMap(data);
              }).toList();

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (_, index) {
              final r = reservations[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.local_parking, color: Colors.blue),
                  title: Text(r.parkingName),
                  subtitle: Text('Espacio: ${r.spaceNumber}'),
                  trailing: Text(
                    _formatDate(r.reservedAt),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
