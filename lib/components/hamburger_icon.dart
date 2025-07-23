import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_api/modules/auth/services/auth_page.dart';
import 'package:mapbox_api/modules/core/pages/profile_page.dart';
import 'package:mapbox_api/modules/core/pages/home_page.dart';
import 'package:mapbox_api/components/my_text.dart';

class HamburguerIcon extends StatelessWidget {
  HamburguerIcon({super.key});

  final User user = FirebaseAuth.instance.currentUser!;

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // iconos y texto en negro
        title: const MyText(
          text: 'Mapa de Parqueos',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF007BFF), // azul
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
                    child: const Icon(
                      Icons.person,
                      size: 42,
                      color: Colors.grey,
                    ),
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

            // Parte blanca con opciones
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Color(0xFF007BFF),
                      ),
                      title: const MyText(
                        text: 'Perfil',
                        color: Color(0xFF007BFF),
                        fontSize: 16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Color(0xFF007BFF),
                      ),
                      title: const MyText(
                        text: 'Cerrar sesión',
                        color: Color(0xFF007BFF),
                        fontSize: 16,
                      ),
                      onTap: () => signUserOut(context),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF007BFF),
                      ),
                      title: const MyText(
                        text: 'Sobre la app',
                        color: Color(0xFF007BFF),
                        fontSize: 16,
                      ),
                      onTap: () {}, // futuro
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Contenido principal
      body: const MapScreen(),
    );
  }
}
