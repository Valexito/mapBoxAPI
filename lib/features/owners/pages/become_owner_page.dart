import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/common/utils/components/ui/my_textfield.dart';
import 'package:mapbox_api/features/core/pages/map_pick_page.dart';

import 'package:mapbox_api/features/core/providers/firebase_providers.dart';
import 'package:mapbox_api/features/owners/providers/owners_providers.dart';

class BecomeOwnerPage extends ConsumerStatefulWidget {
  const BecomeOwnerPage({super.key});
  @override
  ConsumerState<BecomeOwnerPage> createState() => _BecomeOwnerPageState();
}

class _BecomeOwnerPageState extends ConsumerState<BecomeOwnerPage> {
  final _companyName = TextEditingController();
  final _parkingName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _capacity = TextEditingController();
  final _description = TextEditingController();
  final _pricePerHour = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final List<XFile> _images = [];

  bool _accept = false;
  bool _sending = false;
  LatLng? _picked;

  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);

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
    _pricePerHour.dispose();
    super.dispose();
  }

  Future<void> _pickOnMap() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => const MapPickPage()),
    );
    if (result != null) setState(() => _picked = result);
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked.isNotEmpty) {
      setState(() {
        const maxTotal = 10;
        final remaining = maxTotal - _images.length;
        _images.addAll(picked.take(remaining));
      });
    }
  }

  void _removeImage(XFile img) => setState(() => _images.remove(img));

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
    if (!_accept)
      return _showError('Debes aceptar los términos para continuar.');

    final cap = int.tryParse(_capacity.text.trim());
    if (cap == null || cap <= 0)
      return _showError('Capacidad debe ser un número > 0.');

    final price = int.tryParse(_pricePerHour.text.trim());
    if (price == null || price < 0)
      return _showError('Precio por hora inválido.');

    if (_picked == null)
      return _showError('Selecciona la ubicación del parqueo en el mapa.');
    if (_images.length < 3)
      return _showError('Sube al menos 3 fotos del parqueo.');

    setState(() => _sending = true);
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return _showError('Debes iniciar sesión.');

      final create = ref.read(createOwnerAndParkingProvider);
      await create(
        uid: uid,
        companyName: _companyName.text.trim(),
        parkingName: _parkingName.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        capacity: cap,
        description: _description.text.trim(),
        lat: _picked!.latitude,
        lng: _picked!.longitude,
        images: _images,
        price: price,
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
                      text: 'BECOME AN OWNER',
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
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    const MyText(
                      text: 'Price per hour (Q)',
                      variant: MyTextVariant.normal,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 6),
                    MyTextField(
                      controller: _pricePerHour,
                      hintText: 'e.g. 10',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money_outlined,
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        if (n == null || n < 0) return 'Inválido';
                        return null;
                      },
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
                    ),

                    const SizedBox(height: 16),
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
                    const MyText(
                      text: 'Fotos del parqueo (mín. 3)',
                      variant: MyTextVariant.normal,
                      fontSize: 13,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final img in _images)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: FutureBuilder<Uint8List>(
                                    future: img.readAsBytes(),
                                    builder: (context, snap) {
                                      if (snap.connectionState !=
                                              ConnectionState.done ||
                                          !snap.hasData) {
                                        return Container(
                                          color: const Color(0xFFE0E0E0),
                                        );
                                      }
                                      return Image.memory(
                                        snap.data!,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -8,
                                top: -8,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    size: 20,
                                    color: Colors.black54,
                                  ),
                                  onPressed: () => _removeImage(img),
                                ),
                              ),
                            ],
                          ),
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: const Icon(Icons.add_a_photo_outlined),
                          ),
                        ),
                      ],
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
