import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_password_field.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/common/utils/components/ui/my_textfield.dart';
import 'package:mapbox_api/features/auth/components/verify_email_page.dart';
import '../providers/auth_providers.dart';

class SignUpPage extends ConsumerStatefulWidget {
  final VoidCallback onBackToLogin;
  const SignUpPage({super.key, required this.onBackToLogin});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDims.radiusLg),
            ),
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

  Future<void> _signUpAndGoToVerifyPage() async {
    final email = _email.text.trim();
    final pass = _password.text.trim();
    final confirm = _confirm.text.trim();

    if (pass != confirm) {
      _showError('Las contraseñas no coinciden.');
      return;
    }

    if (pass.length < 8) {
      _showError('La contraseña debe tener al menos 8 caracteres.');
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VerifyEmailPage(user: user)),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'No se pudo crear la cuenta.');
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Ingresa tu correo.';
    final ok = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$').hasMatch(email);
    if (!ok) return 'Correo inválido.';
    return null;
  }

  String? _validatePassword(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Ingresa tu contraseña.';
    if (text.length < 8) return 'Mínimo 8 caracteres.';
    return null;
  }

  String? _validateConfirm(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Confirma tu contraseña.';
    if (text != _password.text.trim()) return 'Las contraseñas no coinciden.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFD8F3EE),
      body: SafeArea(
        top: false,
        child: SizedBox(
          height: screen.height,
          child: Stack(
            children: [
              Container(
                height: screen.height * 0.42,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.headerTop, AppColors.headerBottom],
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: -10,
                right: -10,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 15,
                left: 18,
                child: SafeArea(
                  child: TextButton.icon(
                    onPressed: _loading ? null : widget.onBackToLogin,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                    ),
                    label: const Text('Regresar a inicio de sesión'),
                  ),
                ),
              ),
              Positioned(
                top: screen.height * 0.12,
                left: 28,
                right: 28,
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.22),
                          width: 1.4,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: screen.height * 0.26,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(34),
                      topRight: Radius.circular(34),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 34),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: MyText(
                              text: 'Registrarme',
                              variant: MyTextVariant.title,
                              customColor: AppColors.headerBottom,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const MyText(
                            text:
                                'Crea tu cuenta con correo y contraseña. Luego confirmarás tu email y completarás tu perfil.',
                            variant: MyTextVariant.subtitle,
                            fontSize: 13,
                          ),
                          const SizedBox(height: 22),
                          MyTextField(
                            controller: _email,
                            hintText: 'Correo electrónico',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.mail_outline,
                            margin: EdgeInsets.zero,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 14),
                          MyPasswordField(
                            controller: _password,
                            hintText: 'Contraseña',
                            prefixIcon: Icons.lock_outline,
                            margin: EdgeInsets.zero,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 14),
                          MyPasswordField(
                            controller: _confirm,
                            hintText: 'Confirmar contraseña',
                            prefixIcon: Icons.lock_outline,
                            margin: EdgeInsets.zero,
                            validator: _validateConfirm,
                          ),
                          const SizedBox(height: 28),
                          MyButton(
                            text: _loading ? 'Creando...' : 'Registrarme',
                            loading: _loading,
                            onTap:
                                _loading
                                    ? null
                                    : () async {
                                      final ok =
                                          _formKey.currentState?.validate() ??
                                          false;
                                      if (!ok) return;
                                      await _signUpAndGoToVerifyPage();
                                    },
                            margin: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
