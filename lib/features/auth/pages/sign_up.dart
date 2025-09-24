import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/common/utils/components/ui/my_textfield.dart';
import 'package:mapbox_api/features/users/pages/complete_profile_page.dart';

import '../providers/auth_providers.dart';

class SignUpPage extends ConsumerStatefulWidget {
  final VoidCallback onBackToLogin;
  const SignUpPage({super.key, required this.onBackToLogin});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

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

    final auth = ref.read(authActionsProvider);
    setState(() => _loading = true);
    try {
      final cred = await auth.signUpWithEmailPassword(
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
    } finally {
      if (mounted) setState(() => _loading = false);
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
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Form(
                key: _formKey,
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

                    // === User Name ===
                    const MyText(
                      text: 'User Name',
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _username,
                      hintText: 'Enter User Name',
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),

                    // === Email ===
                    const MyText(
                      text: 'Email',
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _email,
                      hintText: 'Enter Email',
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),

                    // === Mobile ===
                    const MyText(
                      text: 'Mobile Number',
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _mobile,
                      hintText: 'Enter your 10 digit mobile number',
                      keyboardType: TextInputType.phone,
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),

                    // === Password ===
                    const MyText(
                      text: 'Password',
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _password,
                      hintText: 'Password should be in 8-15 characters',
                      obscureText: true, // sin icono de ojo
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),

                    // === Confirm Password ===
                    const MyText(
                      text: 'Confirm Password',
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _confirm,
                      hintText: 'Repeat the Password',
                      obscureText: true, // sin icono de ojo
                      margin: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 26),

                    MyButton(
                      text: _loading ? 'Creando...' : 'Sign Up',
                      onTap:
                          _loading
                              ? null
                              : () async {
                                final ok =
                                    _formKey.currentState?.validate() ?? true;
                                if (!ok) return;
                                await _goToCompleteProfile();
                              },
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: _loading ? null : widget.onBackToLogin,
                icon: const Icon(Icons.close, color: navyDark, size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
