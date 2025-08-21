import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/components/ui/my_button.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/components/ui/my_textfield.dart';

class BecomeProviderPage extends StatefulWidget {
  const BecomeProviderPage({super.key});

  @override
  State<BecomeProviderPage> createState() => _BecomeProviderPageState();
}

class _BecomeProviderPageState extends State<BecomeProviderPage> {
  final _companyName = TextEditingController();
  final _parkingName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _capacity = TextEditingController();
  final _description = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  bool _accept = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Prefill con el usuario logueado
    final user = _auth.currentUser;
    if (user != null) {
      _email.text = user.email ?? '';
      _phone.text =
          ''; // si guardas phone en Firestore/Perfil podrías prefill aquí
    }
  }

  @override
  void dispose() {
    _companyName.dispose();
    _parkingName.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _capacity.dispose();
    _description.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            content: MyText(text: msg, variant: MyTextVariant.body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;
    if (!_accept) {
      _showError('Debes aceptar los términos para continuar.');
      return;
    }

    final cap = int.tryParse(_capacity.text.trim());
    if (cap == null || cap <= 0) {
      _showError('Capacidad debe ser un número entero mayor a 0.');
      return;
    }

    setState(() => _sending = true);
    try {
      final uid = _auth.currentUser?.uid;
      await _db.collection('provider_applications').add({
        'uid': uid,
        'companyName': _companyName.text.trim(),
        'parkingName': _parkingName.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
        'capacity': cap,
        'description': _description.text.trim(),
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const MyText(
                text: 'Solicitud enviada',
                variant: MyTextVariant.title,
              ),
              content: const MyText(
                text:
                    'Hemos recibido tu solicitud para convertirte en proveedor. '
                    'Te notificaremos cuando sea revisada.',
                variant: MyTextVariant.body,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // cierra dialog
                    Navigator.pop(context); // vuelve a la pantalla anterior
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            ),
      );
    } catch (e) {
      _showError('No se pudo enviar la solicitud. $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const navyDark = Color(0xFF0D1B2A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    const MyText(
                      text: 'BECOME A PROVIDER',
                      variant: MyTextVariant.title,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const MyText(
                      text:
                          'Completa tus datos para solicitar la verificación como proveedor.',
                      variant: MyTextVariant.bodyMuted,
                      textAlign: TextAlign.center,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 24),

                    // Company Name
                    const MyText(
                      text: 'Company Name',
                      variant: MyTextVariant.normal,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _companyName,
                      hintText: 'Enter Company Name',
                      prefixIcon: Icons.business_outlined,
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),

                    // Parking Name
                    const MyText(
                      text: 'Parking Name',
                      variant: MyTextVariant.normal,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _parkingName,
                      hintText: 'Enter Parking Name',
                      prefixIcon: Icons.local_parking_outlined,
                      obscureText: false,
                      margin: EdgeInsets.zero,
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
                      controller: _email,
                      hintText: 'Company Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline,
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),

                    // Phone
                    const MyText(
                      text: 'Mobile Number',
                      variant: MyTextVariant.normal,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _phone,
                      hintText: 'Enter your 10 digit mobile number',
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),

                    // Address
                    const MyText(
                      text: 'Address',
                      variant: MyTextVariant.normal,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _address,
                      hintText: 'Street, number, city',
                      prefixIcon: Icons.place_outlined,
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),

                    // Capacity
                    const MyText(
                      text: 'Capacity (spaces)',
                      variant: MyTextVariant.normal,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _capacity,
                      hintText: 'Number of spaces available',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.format_list_numbered_outlined,
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 14),

                    // Description
                    const MyText(
                      text: 'Description',
                      variant: MyTextVariant.normal,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _description,
                      hintText: 'Short description of your parking (optional)',
                      prefixIcon: Icons.notes_outlined,
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),

                    // Terms
                    Row(
                      children: [
                        Checkbox(
                          value: _accept,
                          onChanged:
                              (v) => setState(() => _accept = v ?? false),
                          activeColor: const Color(0xFF1B3A57),
                        ),
                        const Expanded(
                          child: MyText(
                            text: 'Acepto términos y condiciones.',
                            variant: MyTextVariant.normal,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Submit
                    _sending
                        ? const Center(child: CircularProgressIndicator())
                        : MyButton(text: 'Send Request', onTap: _submit),
                  ],
                ),
              ),
            ),

            // Close (igual que SignUp)
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: navyDark, size: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
