import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_api/modules/core/pages/profile_page.dart';
import 'package:mapbox_api/modules/user_parking/pages/map_screen.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final User user = FirebaseAuth.instance.currentUser!;

  void signUserOut(BuildContext context) {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de Parqueos')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header con datos del usuario
            UserAccountsDrawerHeader(
              accountName: Text(user.displayName ?? 'Usuario'),
              accountEmail: Text(user.email ?? ''),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 42, color: Colors.grey),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () => signUserOut(context),
            ),
            // Aquí puedes añadir más opciones
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Sobre la app'),
              onTap: () {}, // Acción futura
            ),
          ],
        ),
      ),

      // El mapa como contenido principal
      body: const MapScreen(),
    );
  }
}
