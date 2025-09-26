import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/common/utils/components/ui/my_textfield.dart';
import 'package:mapbox_api/features/core/pages/home_page.dart';
import 'package:mapbox_api/features/users/providers/user_providers.dart';

class CompleteProfilePage extends ConsumerStatefulWidget {
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
  ConsumerState<CompleteProfilePage> createState() =>
      _CompleteProfilePageState();
}

class _CompleteProfilePageState extends ConsumerState<CompleteProfilePage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String role = 'user';
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    if (u.displayName?.isNotEmpty == true) nameController.text = u.displayName!;
    phoneController.text =
        u.phoneNumber?.isNotEmpty == true ? u.phoneNumber! : '+502 ';
  }

  Future<void> _save() async {
    setState(() => isSaving = true);
    try {
      await ref.read(saveProfileProvider)(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        role: role,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
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
    const navyDark = Color(0xFF0D1B2A);

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return false;
        }
        Navigator.of(context).pushReplacementNamed('/auth');
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    const MyText(
                      text: 'COMPLETA TU PERFIL',
                      variant: MyTextVariant.title,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const MyText(
                      text:
                          'Agrega tus datos para continuar y habilitar todas las funciones.',
                      variant: MyTextVariant.bodyMuted,
                      textAlign: TextAlign.center,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 24),
                    const MyText(
                      text: 'Nombre completo',
                      variant: MyTextVariant.normal,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: nameController,
                      hintText: 'Ingresa tu nombre completo',
                      prefixIcon: Icons.person_outline,
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),
                    const MyText(
                      text: 'Teléfono',
                      variant: MyTextVariant.normal,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: phoneController,
                      hintText: 'Ingresa tu número de teléfono',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),
                    const MyText(
                      text: 'Rol',
                      variant: MyTextVariant.normal,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: role,
                      items: const [
                        DropdownMenuItem(value: 'user', child: Text('Usuario')),
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
                    isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : MyButton(text: 'Guardar y continuar', onTap: _save),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed('/auth');
                    }
                  },
                  icon: const Icon(Icons.close, color: navyDark, size: 26),
                  tooltip: 'Close',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
