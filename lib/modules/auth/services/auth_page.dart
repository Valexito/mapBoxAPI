import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/modules/core/pages/home_page.dart';
import 'package:mapbox_api/modules/auth/pages/complete_profile_page.dart';
import 'package:mapbox_api/modules/auth/pages/login_page.dart';
import 'package:mapbox_api/modules/auth/pages/sign_up.dart';
import 'package:mapbox_api/modules/auth/pages/splash_screen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final user = snapshot.data;

        if (user != null) {
          // Verifica si tiene perfil en Firestore
          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SplashScreen();
              }

              final doc = snapshot.data!;
              final exists = doc.exists;

              if (exists) {
                return const HomePage(); // 👈 Nuevo destino
              } else {
                return CompleteProfilePage(user: user, isNewUser: true);
              }
            },
          );
        }

        // No autenticado
        return showLoginPage
            ? LoginPage(showRegisterPage: toggleScreens)
            : SignUpPage(showLoginPage: toggleScreens);
      },
    );
  }
}
