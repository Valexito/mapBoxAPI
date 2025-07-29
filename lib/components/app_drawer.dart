import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_api/components/my_text.dart';
import 'package:mapbox_api/modules/auth/services/auth_page.dart';

class AppDrawer extends StatelessWidget {
  final Function(int index) onSelectTab;

  const AppDrawer({super.key, required this.onSelectTab});

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
                      onSelectTab(1); // Index de MyReservations
                      Navigator.pop(context);
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
                      onSelectTab(2); // Index de FavoritesPage
                      Navigator.pop(context);
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
                      onSelectTab(3); // Index de ProfilePage
                      Navigator.pop(context);
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
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
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
