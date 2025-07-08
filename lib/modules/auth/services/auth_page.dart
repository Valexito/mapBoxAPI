import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_api/modules/auth/pages/complete_profile_page.dart';
import 'package:mapbox_api/modules/auth/pages/home_page.dart';
import 'package:mapbox_api/modules/auth/pages/login_page.dart';
import 'package:mapbox_api/modules/auth/pages/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/modules/auth/pages/splash_screen.dart';

// AuthPage decides whether to show Login or Home/Register based on auth state
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

        // Usuario autenticado
        if (snapshot.hasData) {
          final user = snapshot.data!;

          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
            builder: (context, docSnapshot) {
              if (docSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              if (docSnapshot.hasData && docSnapshot.data!.exists) {
                return HomePage();
              } else {
                return CompleteProfilePage(user: user);
              }
            },
          );
        }

        // Usuario no autenticado
        if (showLoginPage) {
          return LoginPage(showRegisterPage: toggleScreens);
        } else {
          return RegisterPage(showLoginPage: toggleScreens);
        }
      },
    );
  }
}
