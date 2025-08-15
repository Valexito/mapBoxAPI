import 'package:flutter/material.dart';
import 'package:mapbox_api/components/ui/my_textfield.dart';
import 'package:mapbox_api/components/ui/my_password_field.dart';
import 'package:mapbox_api/components/ui/my_button.dart';
import 'package:mapbox_api/components/ui/my_text.dart'; // <- con MyTextVariant
import 'package:mapbox_api/modules/auth/services/auth_service.dart';
import 'package:mapbox_api/modules/auth/components/square_tile.dart';
import 'package:mapbox_api/modules/auth/components/forgot_password_dialog.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();

  bool _rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const headerHeight = 240.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // ===== HEADER =====
              Container(
                height: headerHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0D1B2A), Color(0xFF1B3A57)],
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                ),
              ),

              // ===== CARD =====
              Transform.translate(
                offset: const Offset(0, -34),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(22),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MyText(
                            text: "Inicia sesión",
                            variant: MyTextVariant.title, // TITLE
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),

                          // Email
                          MyTextField(
                            controller: emailController,
                            hintText: 'Nombre de usuario o email',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            obscureText: false,
                            prefixIcon: Icons.person_outline,
                            margin: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 14),

                          // Password
                          MyPasswordField(
                            controller: passwordController,
                            hintText: 'Contraseña',
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
                                activeColor: const Color(0xFF1B3A57),
                              ),
                              const MyText(
                                text: "Recordarme",
                                variant: MyTextVariant.normal, // NORMAL (blue)
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
                                  variant:
                                      MyTextVariant.normalBold, // NORMAL BOLD
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Botón Sign In (degradado azul marino)
                          MyButton(
                            text: "Iniciar sesión",
                            onTap: () {
                              authService.signInUser(
                                context,
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                            },
                          ),

                          const SizedBox(height: 14),

                          // Still not connected?  /  Sign Up
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const MyText(
                                text: "Still not connected?",
                                variant: MyTextVariant.normal, // NORMAL
                                fontSize: 14,
                              ),
                              TextButton(
                                onPressed: widget.showRegisterPage,
                                child: const MyText(
                                  text: "Sign Up",
                                  variant:
                                      MyTextVariant.normalBold, // NORMAL BOLD
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          // OR
                          const SizedBox(height: 6),
                          Row(
                            children: const [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: MyText(
                                  text: "OR",
                                  variant: MyTextVariant.normal, // NORMAL
                                  fontSize: 14,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Social buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SquareTile(
                                imagePath: 'assets/images/google.png',
                                onTap:
                                    () => authService.signInWithGoogle(context),
                              ),
                              const SizedBox(width: 16),
                              SquareTile(
                                imagePath: 'assets/images/apple.png',
                                onTap: () {
                                  // TODO: Implementar Sign in with Apple
                                },
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
