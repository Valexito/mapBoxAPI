import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/pages/home_page.dart';

class CompleteProfilePage extends StatefulWidget {
  final User user;

  const CompleteProfilePage({super.key, required this.user});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String role = 'user'; // puedes cambiar a 'provider' si deseas

  bool isSaving = false;

  Future<void> saveProfile() async {
    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .set({
            'uid': widget.user.uid,
            'email': widget.user.email,
            'name': nameController.text.trim(),
            'phone': phoneController.text.trim(),
            'role': role,
            'createdAt': Timestamp.now(),
          });

      // Ir al HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      debugPrint("Error guardando perfil: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error al guardar el perfil.')),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completa tu perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: 'user', child: Text('Usuario')),
                DropdownMenuItem(value: 'provider', child: Text('Proveedor')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => role = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Rol'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isSaving ? null : saveProfile,
              child:
                  isSaving
                      ? const CircularProgressIndicator()
                      : const Text('Guardar y continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
