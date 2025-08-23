import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/components/ui/my_button.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/components/ui/my_textfield.dart';
import 'package:mapbox_api/modules/core/pages/map_pick_page.dart';
import 'package:mapbox_api/modules/reservations/services/parking_service.dart';

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
  LatLng? _picked; // 👈 ubicación elegida

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _email.text = user.email ?? '';
      _phone.text = '';
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

  Future<void> _pickOnMap() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => const MapPickPage()),
    );
    if (result != null) {
      setState(() => _picked = result);
    }
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;
    if (!_accept)
      return _showError('Debes aceptar los términos para continuar.');

    final cap = int.tryParse(_capacity.text.trim());
    if (cap == null || cap <= 0)
      return _showError('Capacidad debe ser un número > 0.');
    if (_picked == null)
      return _showError('Selecciona la ubicación del parqueo en el mapa.');

    setState(() => _sending = true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return _showError('Debes iniciar sesión.');

      // (Opcional) solicitud para tu pipeline
      await _db.collection('provider_applications').add({
        'uid': uid,
        'companyName': _companyName.text.trim(),
        'parkingName': _parkingName.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
        'capacity': cap,
        'description': _description.text.trim(),
        'status': 'approved', // usa 'pending' si vas a revisar manualmente
        'createdAt': Timestamp.now(),
      });

      // ✅ crear parking (aparecerá en el mapa)
      await ParkingService().createParking(
        ownerID: uid,
        name: _parkingName.text.trim(),
        lat: _picked!.latitude,
        lng: _picked!.longitude,
        spaces: cap,
        descripcion: _description.text.trim(),
        price: 0, // puedes añadir un campo en el form si lo necesitas
      );

      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const MyText(
                text: '¡Listo!',
                variant: MyTextVariant.title,
              ),
              content: const MyText(
                text: 'Tu parqueo fue creado y aparecerá en el mapa.',
                variant: MyTextVariant.body,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            ),
      );
    } catch (e) {
      _showError('No se pudo completar el registro. $e');
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
                      text: 'Completa tus datos para registrar tu parqueo.',
                      variant: MyTextVariant.bodyMuted,
                      textAlign: TextAlign.center,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 24),

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

                    const MyText(
                      text: 'Description',
                      variant: MyTextVariant.normal,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _description,
                      hintText: 'Short description (optional)',
                      prefixIcon: Icons.notes_outlined,
                      obscureText: false,
                      margin: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),

                    // Ubicación
                    const MyText(
                      text: 'Ubicación del parqueo',
                      variant: MyTextVariant.normal,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickOnMap,
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('Elegir en el mapa'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    MyText(
                      text:
                          _picked == null
                              ? 'Sin ubicación seleccionada'
                              : 'Lat: ${_picked!.latitude.toStringAsFixed(6)}, Lng: ${_picked!.longitude.toStringAsFixed(6)}',
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 13,
                    ),

                    const SizedBox(height: 16),
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

                    _sending
                        ? const Center(child: CircularProgressIndicator())
                        : MyButton(text: 'Registrar parqueo', onTap: _submit),
                  ],
                ),
              ),
            ),

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
