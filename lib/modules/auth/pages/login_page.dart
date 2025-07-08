import 'package:mapbox_api/modules/auth/services/auth_service.dart';
import 'package:mapbox_api/modules/auth/components/my_button.dart';
import 'package:mapbox_api/modules/auth/components/my_textfield.dart';
import 'package:mapbox_api/modules/auth/components/square_tile.dart';
import 'package:mapbox_api/modules/auth/components/forgot_password_dialog.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;

  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),

                // Logo
                const Icon(Icons.lock, size: 85),

                const SizedBox(height: 30),

                // Welcome back
                Text(
                  'Welcome back!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 24),
                ),

                const SizedBox(height: 25),

                // Username TextField
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Password TextField
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // Forgot Password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const ForgotPasswordDialog(),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Sign In Button
                MyButton(
                  onTap: () {
                    authService.signInUser(
                      context,
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Or continue with
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.grey),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Or continue with'),
                      ),
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Google + Apple Sign In Buttons (placeholders)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google button con tap
                    GestureDetector(
                      onTap: () => AuthService().signInWithGoogle(context),
                      child: SquareTile(
                        imagePath: 'lib/modules/auth/images/google.png',
                      ),
                    ),

                    const SizedBox(width: 15),
                    //Apple
                    SquareTile(imagePath: 'lib/modules/auth/images/apple.png'),
                  ],
                ),

                const SizedBox(height: 30),

                // Not a member? Register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap:
                          widget
                              .showRegisterPage, // esto lo pasas desde AuthPage
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
