import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/modules/auth/pages/complete_profile_page.dart'; // Asegúrate de importar esta

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> signUp() async {
    // Verificar que las contraseñas coincidan
    if (_passwordController.text != _confirmPasswordController.text) {
      showDialog(
        context: context,
        builder:
            (context) => const AlertDialog(
              content: Text("Las contraseñas no coinciden."),
            ),
      );
      return;
    }

    try {
      // Registrar al usuario
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // Redirigir a la vista de completar perfil
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CompleteProfilePage(user: credential.user!),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder:
            (context) =>
                AlertDialog(content: Text(e.message ?? "Error desconocido")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.app_registration, size: 100),
                const SizedBox(height: 25),
                const Text("Regístrate", style: TextStyle(fontSize: 24)),
                const SizedBox(height: 25),

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Contraseña',
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: signUp,
                  child: const Text('Registrarse'),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: widget.showLoginPage,
                  child: const Text('¿Ya tienes una cuenta? Inicia sesión.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
