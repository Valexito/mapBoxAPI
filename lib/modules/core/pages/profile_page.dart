import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/components/my_button.dart';
import 'package:mapbox_api/components/my_text.dart';
import 'package:mapbox_api/components/my_textfield.dart';
import 'package:mapbox_api/modules/core/pages/become_provider_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final User user = FirebaseAuth.instance.currentUser!;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  bool isSaving = false;
  double _logoOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    fetchUserData();

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _logoOpacity = 1.0);
    });
  }

  Future<void> fetchUserData() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data['name'] ?? '';
      phoneController.text = data['phone'] ?? '';
    }
  }

  Future<void> saveProfile() async {
    setState(() => isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
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
                      const MyText(
                        text: 'Perfil',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      MyTextField(
                        controller: nameController,
                        hintText: 'Nombre completo',
                        obscureText: false,
                      ),
                      const SizedBox(height: 15),
                      MyTextField(
                        controller: phoneController,
                        hintText: 'Teléfono',
                        obscureText: false,
                      ),
                      const SizedBox(height: 30),
                      isSaving
                          ? const Center(child: CircularProgressIndicator())
                          : MyButton(
                            onTap: saveProfile,
                            text: 'Guardar cambios',
                            color: const Color(0xFF007BFF),
                          ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BecomeProviderPage(),
                            ),
                          );
                        },
                        child: const MyText(
                          text: 'Volverse proveedor...',
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          textAlign: TextAlign.center,
                        ),
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
