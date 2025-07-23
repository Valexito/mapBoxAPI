import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/components/my_button.dart';
import 'package:mapbox_api/components/my_text.dart';
import 'package:mapbox_api/components/my_textfield.dart';
import 'package:mapbox_api/components/hamburger_icon.dart';

class CompleteProfilePage extends StatefulWidget {
  final User user;
  final bool isNewUser;
  final String? password; // Optional for email/password users

  const CompleteProfilePage({
    super.key,
    required this.user,
    required this.isNewUser,
    this.password,
  });

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String role = 'user';
  bool isSaving = false;
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

  Future<void> saveProfile() async {
    setState(() => isSaving = true);

    try {
      final uid = widget.user.uid;
      final email = widget.user.email ?? '';

      // Guardar en Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'role': role,
        'createdAt': Timestamp.now(),
      });

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HamburguerIcon()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => isSaving = false);
    }
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
                height: MediaQuery.of(context).size.height * 0.85,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 40,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      const MyText(
                        text: 'Complete Profile',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      MyTextField(
                        controller: nameController,
                        hintText: 'Full Name',
                        obscureText: false,
                      ),
                      const SizedBox(height: 15),
                      MyTextField(
                        controller: phoneController,
                        hintText: 'Phone',
                        obscureText: false,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(
                            value: 'provider',
                            child: Text('Provider'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => role = value);
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                      isSaving
                          ? const Center(child: CircularProgressIndicator())
                          : MyButton(
                            onTap: saveProfile,
                            text: 'Save and continue',
                            color: const Color(0xFF007BFF),
                          ),
                    ],
                  ),
                ),
              ),
            ),
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
