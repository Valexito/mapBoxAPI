import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/components/ui/my_button.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/components/ui/my_textfield.dart';
import 'package:mapbox_api/modules/auth/pages/complete_profile_page.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const SignUpPage({super.key, required this.showLoginPage});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _mobile.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            content: MyText(text: msg, variant: MyTextVariant.body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _goToCompleteProfile() async {
    final email = _email.text.trim();
    final pass = _password.text.trim();
    final confirm = _confirm.text.trim();

    if (pass != confirm) {
      _showError('Las contraseñas no coinciden.');
      return;
    }

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      final user = cred.user;
      if (!mounted || user == null) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => CompleteProfilePage(
                user: user,
                isNewUser: true,
                password: pass,
              ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'No se pudo crear la cuenta.');
    } catch (e) {
      _showError('Error inesperado: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const navyDark = Color(0xFF0D1B2A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido principal
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const MyText(
                    text: 'SIGN UP',
                    variant: MyTextVariant.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const MyText(
                    text:
                        'Crea tu cuenta para continuar y acceder a todas las funciones.',
                    variant: MyTextVariant.bodyMuted,
                    textAlign: TextAlign.center,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 24),

                  // User Name
                  const MyText(
                    text: 'User Name',
                    variant: MyTextVariant.normal,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 6),
                  MyTextField(
                    controller: _username,
                    hintText: 'Enter User Name',
                    prefixIcon: Icons.person_outline,
                    obscureText: false,
                    margin: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 14),

                  // Email
                  const MyText(
                    text: 'Email',
                    variant: MyTextVariant.normal,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 6),
                  MyTextField(
                    controller: _email,
                    hintText: 'Enter Email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline,
                    obscureText: false,
                    margin: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 14),

                  // Mobile Number
                  const MyText(
                    text: 'Mobile Number',
                    variant: MyTextVariant.normal,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 6),
                  MyTextField(
                    controller: _mobile,
                    hintText: 'Enter your 10 digit mobile number',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    obscureText: false,
                    margin: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 14),

                  // Password
                  const MyText(
                    text: 'Password',
                    variant: MyTextVariant.normal,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 6),
                  MyTextField(
                    controller: _password,
                    hintText: 'Password should be in 8-15 characters',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    margin: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 14),

                  // Confirm Password
                  const MyText(
                    text: 'Confirm Password',
                    variant: MyTextVariant.normal,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 6),
                  MyTextField(
                    controller: _confirm,
                    hintText: 'Repeat the Password',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    margin: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 26),

                  MyButton(
                    text: 'Sign Up',
                    onTap: () async {
                      debugPrint('SignUp tapped'); // <-- debe verse en consola
                      final ok = _formKey.currentState?.validate() ?? true;
                      if (!ok) return;
                      await _goToCompleteProfile(); // <-- si hay error, lo verás en el catch
                    },
                  ),
                ],
              ),
            ),

            // Botón regresar esquina superior derecha
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: widget.showLoginPage,
                icon: const Icon(Icons.close, color: navyDark, size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
