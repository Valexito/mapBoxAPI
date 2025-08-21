import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/components/ui/my_button.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/components/ui/my_textfield.dart';
import 'package:mapbox_api/modules/core/pages/home_page.dart';

class CompleteProfilePage extends StatefulWidget {
  final User user;
  final bool isNewUser;
  final String? password;

  const CompleteProfilePage({
    super.key,
    required this.user,
    required this.isNewUser,
    this.password,
  });

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String role = 'user';
  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    setState(() => isSaving = true);
    try {
      final uid = widget.user.uid;
      final email = widget.user.email ?? '';
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'role': role,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const navyDark = Color(0xFF0D1B2A); // mismo tono que usas en SignUp
    return Scaffold(
      backgroundColor: Colors.white, // igual que SignUp
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido principal (igual estructura que SignUp: título, subtítulo, labels y campos)
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Título
                  const MyText(
                    text: 'COMPLETE PROFILE',
                    variant: MyTextVariant.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),

                  // Subtítulo
                  const MyText(
                    text:
                        'Agrega tus datos para continuar y habilitar todas las funciones.',
                    variant: MyTextVariant.bodyMuted,
                    textAlign: TextAlign.center,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 24),

                  // Label + Campo: Full Name
                  const MyText(
                    text: 'Full Name',
                    variant: MyTextVariant.normal,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 6),
                  MyTextField(
                    controller: nameController,
                    hintText: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    obscureText: false,
                    margin: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 14),

                  // Label + Campo: Phone
                  const MyText(
                    text: 'Phone',
                    variant: MyTextVariant.normal,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 6),
                  MyTextField(
                    controller: phoneController,
                    hintText: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    obscureText: false,
                    margin: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 14),

                  // Label + Campo: Role (Dropdown estilizado para encajar con los inputs)
                  const MyText(
                    text: 'Role',
                    variant: MyTextVariant.normal,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: role,
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('User')),
                      DropdownMenuItem(
                        value: 'provider',
                        child: Text('Provider'),
                      ),
                    ],
                    onChanged: (v) => setState(() => role = v ?? 'user'),
                    decoration: InputDecoration(
                      hintText: 'Select role',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F9),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Botón principal (mismo componente MyButton)
                  isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : MyButton(text: 'Save and continue', onTap: saveProfile),
                ],
              ),
            ),

            // Botón cerrar en esquina superior derecha (igual a SignUp)
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: navyDark, size: 26),
                tooltip: 'Close',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
