import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_api/components/my_text.dart';
import 'package:mapbox_api/modules/auth/services/auth_page.dart';
import 'package:mapbox_api/modules/core/pages/reservations_page.dart';
import 'package:mapbox_api/modules/core/pages/favorites_page.dart';
import 'package:mapbox_api/modules/core/pages/profile_page.dart';
// Si tienes más páginas, agrégalas aquí

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Drawer(
      child: Column(
        children: [
          Container(
            color: const Color(0xFF007BFF),
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            width: double.infinity,
            child: Column(
              children: [
                Container(
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
                  child: const Icon(Icons.person, size: 42, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                MyText(
                  text: user.displayName ?? 'Usuario',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                MyText(
                  text: user.email ?? '',
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.bookmark,
                      color: Color(0xFF007BFF),
                    ),
                    title: const MyText(
                      text: 'Mis reservas',
                      color: Color(0xFF007BFF),
                      fontSize: 16,
                    ),
                    onTap: () {
                      Navigator.pop(context); // Cierra el drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReservationsPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.favorite,
                      color: Color(0xFF007BFF),
                    ),
                    title: const MyText(
                      text: 'Favoritos',
                      color: Color(0xFF007BFF),
                      fontSize: 16,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FavoritesPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person, color: Color(0xFF007BFF)),
                    title: const MyText(
                      text: 'Perfil',
                      color: Color(0xFF007BFF),
                      fontSize: 16,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      color: Color(0xFF007BFF),
                    ),
                    title: const MyText(
                      text: 'Configuraciones',
                      color: Color(0xFF007BFF),
                      fontSize: 16,
                    ),
                    onTap: () {
                      // Agrega tu página de configuración si deseas
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFF007BFF)),
                    title: const MyText(
                      text: 'Cerrar sesión',
                      color: Color(0xFF007BFF),
                      fontSize: 16,
                    ),
                    onTap: () => signUserOut(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
