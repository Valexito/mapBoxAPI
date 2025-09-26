// == TU ARCHIVO, SIN NAVEGAR DESDE AQUÍ ==
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/common/utils/components/ui/my_textfield.dart';
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

  Future<void> _signUpAndAskEmailVerify() async {
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

      await user.sendEmailVerification();

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return StatefulBuilder(
            builder: (ctx, _) {
              Future<void> _check() async {
                await FirebaseAuth.instance.currentUser?.reload();
                final current = FirebaseAuth.instance.currentUser;
                final ok = current?.emailVerified ?? false;
                if (!ok) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tu correo aún no está verificado. Revisa tu bandeja o spam.',
                      ),
                    ),
                  );
                  return;
                }
                if (mounted) {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(); // solo cerrar el diálogo
                }
              }

              return AlertDialog(
                title: const Text('Verifica tu correo'),
                content: const Text(
                  'Te enviamos un email de verificación. Abre el enlace y luego toca "Ya verifiqué".',
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.currentUser
                            ?.sendEmailVerification();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Correo reenviado.')),
                          );
                        }
                      } catch (_) {}
                    },
                    child: const Text('Reenviar'),
                  ),
                  ElevatedButton(
                    onPressed: _check,
                    child: const Text('Ya verifiqué'),
                  ),
                ],
              );
            },
          );
        },
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
                      text: 'REGISTRARSE',
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
                    const MyText(
                      text: 'Nombre de usuario',
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _username,
                      hintText: 'Ingresa tu nombre de usuario',
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),
                    const MyText(
                      text: 'Correo',
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _email,
                      hintText: 'Ingresa tu correo electrónico',
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),
                    const MyText(
                      text: 'Número de teléfono',
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _mobile,
                      hintText: 'Ingresa tu número de teléfono',
                      keyboardType: TextInputType.phone,
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),
                    const MyText(
                      text: 'Contraseña',
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _password,
                      hintText:
                          'La contraseña debe tener al menos 8 caracteres',
                      obscureText: true,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),
                    const MyText(
                      text: 'Confirmar contraseña',
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _confirm,
                      hintText: 'Reingresa tu contraseña',
                      obscureText: true,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 26),
                    MyButton(
                      text: _loading ? 'Creando...' : 'Registrarse',
                      onTap:
                          _loading
                              ? null
                              : () async {
                                final ok =
                                    _formKey.currentState?.validate() ?? true;
                                if (!ok) return;
                                await _signUpAndAskEmailVerify();
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
