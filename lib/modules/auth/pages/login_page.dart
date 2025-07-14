import 'package:flutter/material.dart';
import 'package:mapbox_api/modules/auth/services/auth_service.dart';
import 'package:mapbox_api/components/my_button.dart';
import 'package:mapbox_api/components/my_textfield.dart';
import 'package:mapbox_api/components/my_text.dart';
import 'package:mapbox_api/modules/auth/components/square_tile.dart';
import 'package:mapbox_api/modules/auth/components/forgot_password_dialog.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;

  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  double _logoOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _logoOpacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF007BFF),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 40,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      MyTextField(
                        controller: emailController,
                        hintText: 'Email',
                        obscureText: false,
                      ),
                      const SizedBox(height: 15),

                      MyTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (context) => const ForgotPasswordDialog(),
                            );
                          },
                          child: const MyText(
                            text: 'Forgot Password?',
                            color: Colors.blue,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      MyButton(
                        onTap: () {
                          authService.signInUser(
                            context,
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );
                        },
                        text: "Login",
                        color: const Color(0xFF007BFF),
                      ),

                      const SizedBox(height: 25),

                      // Divider azul
                      Row(
                        children: const [
                          Expanded(
                            child: Divider(
                              color: Color(0xFF007BFF),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: MyText(
                              text: "Or continue with",
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xFF007BFF),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap:
                                () => AuthService().signInWithGoogle(context),
                            child: SquareTile(
                              imagePath: 'assets/images/google.png',
                            ),
                          ),
                          const SizedBox(width: 15),
                          SquareTile(imagePath: 'assets/images/apple.png'),
                        ],
                      ),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const MyText(
                            text: "Don't have any account?",
                            fontSize: 14,
                          ),
                          TextButton(
                            onPressed: widget.showRegisterPage,
                            child: const MyText(
                              text: "Sign Up",
                              color: Color(0xFF007BFF),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Logo animado con imagen desde assets/images
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: AnimatedOpacity(
                  opacity: _logoOpacity,
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/parking_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
