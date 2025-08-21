import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/components/ui/my_button.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/components/ui/my_textfield.dart';

class ConfigureProfilePage extends StatefulWidget {
  const ConfigureProfilePage({super.key});

  @override
  State<ConfigureProfilePage> createState() => _ConfigureProfilePageState();
}

class _ConfigureProfilePageState extends State<ConfigureProfilePage> {
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  final _auth = FirebaseAuth.instance;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _dobCtrl = TextEditingController(); // readOnly + date picker

  final _formKey = GlobalKey<FormState>();

  String _gender = 'male';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = _auth.currentUser;
    _nameCtrl.text = u?.displayName ?? '';
    _emailCtrl.text = u?.email ?? '';
    // _mobileCtrl, _dobCtrl, _gender: si los guardas en Firestore, precárgalos aquí
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 100, 1, 1);
    final last = DateTime(now.year, now.month, now.day);

    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: first,
      lastDate: last,
      helpText: 'Selecciona tu fecha de nacimiento',
      builder: (context, child) {
        // keep consistent with light theme
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: navyBottom, secondary: navyBottom),
          ),
          child: child!,
        );
      },
    );
    if (selected != null) {
      _dobCtrl.text =
          '${selected.day.toString().padLeft(2, '0')}/'
          '${selected.month.toString().padLeft(2, '0')}/'
          '${selected.year}';
      setState(() {});
    }
  }

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _saving = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Actualiza nombre y email en FirebaseAuth
        if (_nameCtrl.text.trim().isNotEmpty) {
          await user.updateDisplayName(_nameCtrl.text.trim());
        }
        if (_emailCtrl.text.trim().isNotEmpty &&
            _emailCtrl.text.trim() != user.email) {
          await user.verifyBeforeUpdateEmail(_emailCtrl.text.trim());
          // Nota: verifyBeforeUpdateEmail envía un correo para confirmar el cambio
        }
      }

      // TODO: si usas Firestore, guarda aquí mobile, dob y gender
      // await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({...}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Perfil guardado')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const headerHeight = 260.0;
    final user = _auth.currentUser;
    final photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // ===== HEADER (gradient + avatar + close) =====
              Stack(
                children: [
                  Container(
                    height: headerHeight,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [navyTop, navyBottom],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child:
                                    photoUrl != null
                                        ? Image.network(
                                          photoUrl,
                                          fit: BoxFit.cover,
                                        )
                                        : Container(
                                          color: Colors.white,
                                          child: const Icon(
                                            Icons.person,
                                            size: 56,
                                            color: navyBottom,
                                          ),
                                        ),
                              ),
                            ),
                            Positioned(
                              bottom: -6,
                              right: -6,
                              child: Material(
                                color: Colors.white,
                                shape: const CircleBorder(),
                                elevation: 3,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt_outlined,
                                    color: navyBottom,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    // TODO: abrir picker de imagen y subirla, luego user.updatePhotoURL(...)
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const MyText(
                          text: 'USER PROFILE',
                          variant: MyTextVariant.title,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Close (top-right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),

              // ===== CARD (fields like the mock) =====
              Transform.translate(
                offset: const Offset(0, -34),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(22),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // User Name
                            const MyText(
                              text: 'User Name',
                              variant: MyTextVariant.normal,
                              fontSize: 13,
                            ),
                            const SizedBox(height: 6),
                            MyTextField(
                              controller: _nameCtrl,
                              hintText: 'Enter User Name',
                              prefixIcon: Icons.person_outline,
                              margin: EdgeInsets.zero,
                              validator:
                                  (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? 'Escribe tu nombre'
                                          : null,
                            ),
                            const SizedBox(height: 14),

                            // Email
                            const MyText(
                              text: 'Email',
                              variant: MyTextVariant.normal,
                              fontSize: 13,
                            ),
                            const SizedBox(height: 6),
                            MyTextField(
                              controller: _emailCtrl,
                              hintText: 'Enter Email',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.mail_outline,
                              margin: EdgeInsets.zero,
                              validator: (v) {
                                final s = v?.trim() ?? '';
                                final ok = RegExp(
                                  r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$',
                                ).hasMatch(s);
                                return ok ? null : 'Correo inválido';
                              },
                            ),
                            const SizedBox(height: 14),

                            // Mobile
                            const MyText(
                              text: 'Mobile Number',
                              variant: MyTextVariant.normal,
                              fontSize: 13,
                            ),
                            const SizedBox(height: 6),
                            MyTextField(
                              controller: _mobileCtrl,
                              hintText: 'Enter your 10 digit mobile number',
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_outlined,
                              margin: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 14),

                            // DOB
                            const MyText(
                              text: 'Date of Birth',
                              variant: MyTextVariant.normal,
                              fontSize: 13,
                            ),
                            const SizedBox(height: 6),
                            MyTextField(
                              controller: _dobCtrl,
                              hintText: 'DD / MM / YYYY',
                              readOnly: true,
                              onTap: _pickDob,
                              prefixIcon: Icons.calendar_today_outlined,
                              margin: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 16),

                            // Gender
                            const MyText(
                              text: 'Sex',
                              variant: MyTextVariant.normal,
                              fontSize: 13,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _GenderChip(
                                  label: 'Male',
                                  selected: _gender == 'male',
                                  onTap: () => setState(() => _gender = 'male'),
                                ),
                                const SizedBox(width: 12),
                                _GenderChip(
                                  label: 'Female',
                                  selected: _gender == 'female',
                                  onTap:
                                      () => setState(() => _gender = 'female'),
                                ),
                              ],
                            ),

                            const SizedBox(height: 22),
                            MyButton(
                              onTap: _saving ? null : _save,
                              text: _saving ? 'Saving...' : 'Save',
                              // usa tu estilo de degradado por defecto
                            ),
                          ],
                        ),
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

class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0D1B2A);
    final bg = selected ? navy : const Color(0xFFEFF2F6);
    final fg = selected ? Colors.white : const Color(0xFF1B3A57);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(color: fg, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
