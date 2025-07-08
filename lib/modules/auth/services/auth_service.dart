import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapbox_api/modules/auth/pages/complete_profile_page.dart';
import 'package:mapbox_api/modules/core/pages/home_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void showErrorDialog(BuildContext context, String message) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  //EMAIL SIGIN

  Future<void> signInUser(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");

      if (!context.mounted) return;

      showErrorDialog(context, 'Invalid credentials.');
    } catch (e) {
      print("Unexpected error: $e");

      if (!context.mounted) return;
      showErrorDialog(context, 'An unexpected error occurred.');
    }
  }

  //GOOGLE SIGN IN
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) return; // Cancelado

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User user = userCredential.user!;

      // Verificar si el usuario ya tiene datos en Firestore
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!context.mounted) return;

      if (doc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CompleteProfilePage(user: user)),
        );
      }
    } catch (e) {
      debugPrint("Google Sign-In error: $e");

      if (!context.mounted) return;

      showErrorDialog(context, "No se pudo iniciar sesión con Google.");
    }
  }
}
