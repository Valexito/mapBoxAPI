import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_api/common/utils/components/ui/my_textfield.dart';
import 'package:mapbox_api/common/utils/components/ui/my_password_field.dart';
import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/common/utils/components/ui/navy_header.dart';
import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';

import 'package:mapbox_api/features/auth/components/square_tile.dart';
import 'package:mapbox_api/features/auth/components/forgot_password_dialog.dart';
import 'package:mapbox_api/features/auth/providers/auth_providers.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_api/features/users/pages/complete_profile_page.dart';
import 'package:mapbox_api/features/users/providers/user_providers.dart';
import 'package:mapbox_api/features/core/pages/home_switch.dart';

class LoginPage extends ConsumerStatefulWidget {
  final VoidCallback onShowRegister;
  const LoginPage({Key? key, required this.onShowRegister}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _goToCompleteProfile(User user) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => CompleteProfilePage(user: user, isNewUser: false),
      ),
      (_) => false,
    );
  }

  // ⬇⬇ AQUI VA LO QUE PEDISTE (completo) ⬇⬇
  Future<void> _routeAfterAuth(User user) async {
    final ready = await ref.read(canEnterAppProvider(user.uid).future);
    if (!mounted) return;

    if (ready) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeSwitch()),
        (_) => false,
      );
    } else {
      _goToCompleteProfile(user);
    }
  }

  Future<void> _signInWithGoogle() async {
    final signInGoogle = ref.read(signInWithGoogleProvider);
    setState(() => _loading = true);
    try {
      final cred = await signInGoogle();
      final user = (cred as UserCredential).user;
      if (!mounted || user == null) return;
      await _routeAfterAuth(user);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  // ⬆⬆ FIN de lo que pediste ⬆⬆

  Future<void> _signInEmailPassword() async {
    final auth = ref.read(authActionsProvider);
    setState(() => _loading = true);
    try {
      final cred = await auth.signInWithEmailPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final user = cred.user;
      if (!mounted || user == null) return;
      await _routeAfterAuth(user);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const headerHeight = 240.0;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const NavyHeader(
                height: headerHeight,
                children: [
                  SizedBox(height: 22),
                  Icon(Icons.directions_car, size: 60, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'LOGO APP',
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -34),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Material(
                    elevation: 8,
                    shadowColor: Colors.black12,
                    borderRadius: BorderRadius.circular(AppDims.radiusLg),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const MyText(
                            text: "Inicia sesión",
                            variant: MyTextVariant.title,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          const MyText(
                            text: 'Correo electrónico',
                            variant: MyTextVariant.bodyMuted,
                            fontSize: 13,
                          ),
                          const SizedBox(height: 6),
                          MyTextField(
                            controller: emailController,
                            hintText: 'Ingresa tu correo electrónico',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            margin: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 14),
                          const MyText(
                            text: 'Contraseña',
                            variant: MyTextVariant.bodyMuted,
                            fontSize: 13,
                          ),
                          const SizedBox(height: 6),
                          MyPasswordField(
                            controller: passwordController,
                            hintText: '••••••••',
                            margin: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged:
                                    (v) => setState(
                                      () => _rememberMe = v ?? false,
                                    ),
                                activeColor: AppColors.navyBottom,
                              ),
                              const MyText(
                                text: "Recordarme",
                                variant: MyTextVariant.bodyMuted,
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (_) => const ForgotPasswordDialog(),
                                  );
                                },
                                child: const MyText(
                                  text: '¿Olvidaste contraseña?',
                                  variant: MyTextVariant.normalBold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          MyButton(
                            text: _loading ? "Entrando..." : "Iniciar sesión",
                            loading: _loading,
                            onTap: _loading ? null : _signInEmailPassword,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const MyText(
                                text: "¿No estás registrado?",
                                variant: MyTextVariant.bodyMuted,
                                fontSize: 14,
                              ),
                              TextButton(
                                onPressed:
                                    _loading ? null : widget.onShowRegister,
                                child: const MyText(
                                  text: "Regístrate",
                                  variant: MyTextVariant.normalBold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: const [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: MyText(
                                  text: "O",
                                  variant: MyTextVariant.bodyMuted,
                                  fontSize: 14,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SquareTile(
                                imagePath: 'assets/images/google.png',
                                onTap: _loading ? null : _signInWithGoogle,
                              ),
                              const SizedBox(width: 16),
                              const SquareTile(
                                imagePath: 'assets/images/apple.png',
                                onTap: null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
