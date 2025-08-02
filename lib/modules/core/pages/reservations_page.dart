import 'package:cloud_firestore/cloud_firestore.dart';
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
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('reservations')
                .orderBy('reservedAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No tienes reservas aún.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final reservations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final data = reservations[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(
                    Icons.local_parking,
                    color: Color(0xFF1976D2),
                  ),
                  title: Text(data['parkingName'] ?? 'Parqueo'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Espacio: ${data['spaceNumber']}'),
                      Text(
                        'Reservado: ${data['reservedAt']?.toString().substring(0, 16)}',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
