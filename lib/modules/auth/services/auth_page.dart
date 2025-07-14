import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/modules/auth/pages/login_page.dart';
import 'package:mapbox_api/modules/auth/pages/sign_up.dart';
import 'package:mapbox_api/modules/auth/pages/splash_screen.dart';
import 'package:mapbox_api/modules/core/pages/home_page.dart';

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

        // Si el usuario ya está autenticado, mostrar Home
        if (snapshot.hasData) {
          return HomePage();
        }

        // Si no está autenticado, mostrar login o register
        if (showLoginPage) {
          return LoginPage(showRegisterPage: toggleScreens);
        } else {
          return SignUpPage(showLoginPage: toggleScreens);
        }
      },
    );
  }
}
