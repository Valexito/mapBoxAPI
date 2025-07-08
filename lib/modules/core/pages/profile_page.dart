import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser!.uid)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('No se encontró información del usuario.'),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final isProvider = userData['role'] == 'provider';

          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                const Text(
                  'Información del Usuario',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text('Nombre: ${userData['name'] ?? ''}'),
                Text('Email: ${userData['email'] ?? ''}'),
                Text('Teléfono: ${userData['phone'] ?? ''}'),
                Text('Rol: ${userData['role'] ?? ''}'),
                const SizedBox(height: 20),

                if (!isProvider)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.local_parking),
                    label: const Text('Quiero ser proveedor de parqueos'),
                    onPressed: () {
                      // Navegar a formulario para convertirse en proveedor
                      Navigator.pushNamed(context, '/becomeProvider');
                    },
                  ),

                if (isProvider) ...[
                  const Divider(height: 40),
                  const Text(
                    'Información del Parqueo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (userData['providerProfile'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nombre parqueo: ${userData['providerProfile']['parkingName'] ?? ''}',
                        ),
                        Text(
                          'Dirección: ${userData['providerProfile']['address'] ?? ''}',
                        ),
                        Text(
                          'Espacios: ${userData['providerProfile']['slots'] ?? ''}',
                        ),
                        Text(
                          'Horario: ${userData['providerProfile']['schedule'] ?? ''}',
                        ),
                      ],
                    )
                  else
                    const Text(
                      'Este proveedor aún no ha registrado su parqueo.',
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
