import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/components/ui/my_button.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/components/ui/my_textfield.dart';

class BecomeProviderPage extends StatefulWidget {
  const BecomeProviderPage({super.key});

  @override
  State<BecomeProviderPage> createState() => _BecomeProviderPageState();
}

class _BecomeProviderPageState extends State<BecomeProviderPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final slotsController = TextEditingController();
  final scheduleController = TextEditingController();
  final contactPhoneController = TextEditingController();
  bool isSaving = false;
  LatLng? selectedLocation;
  double _logoOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _logoOpacity = 1.0);
    });
  }

  Future<void> saveProviderInfo() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona la ubicación.')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final parkingName = nameController.text.trim();
      final address = addressController.text.trim();
      final slots = int.tryParse(slotsController.text.trim()) ?? 0;
      final schedule = scheduleController.text.trim();
      final contactPhone = contactPhoneController.text.trim();
      final lat = selectedLocation!.latitude;
      final lng = selectedLocation!.longitude;
      const int price = 6;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'role': 'provider',
        'providerProfile': {
          'parkingName': parkingName,
          'address': address,
          'slots': slots,
          'schedule': schedule,
          'contactPhone': contactPhone,
          'location': {'lat': lat, 'lng': lng},
          'price': price,
        },
      });

      await FirebaseFirestore.instance.collection('parking').add({
        'name': parkingName,
        'lat': lat,
        'lng': lng,
        'price': price,
        'spaces': slots,
        'ownerID': uid,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Ahora eres proveedor de parqueos!')),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar. Intenta de nuevo.')),
      );
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
                height: MediaQuery.of(context).size.height * 0.88,
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const MyText(
                          text: 'Convertirse en Proveedor',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        MyTextField(
                          controller: nameController,
                          hintText: 'Nombre del parqueo',
                          obscureText: false,
                        ),
                        const SizedBox(height: 15),
                        MyTextField(
                          controller: addressController,
                          hintText: 'Dirección',
                          obscureText: false,
                        ),
                        const SizedBox(height: 15),
                        MyTextField(
                          controller: slotsController,
                          hintText: 'Cantidad de espacios',
                          obscureText: false,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 15),
                        MyTextField(
                          controller: scheduleController,
                          hintText: 'Horario (ej. Lun a Vie 8am - 8pm)',
                          obscureText: false,
                        ),
                        const SizedBox(height: 15),
                        MyTextField(
                          controller: contactPhoneController,
                          hintText: 'Teléfono de contacto',
                          obscureText: false,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.map),
                          label: Text(
                            selectedLocation != null
                                ? 'Ubicación seleccionada'
                                : 'Seleccionar ubicación en el mapa',
                          ),
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/mapPicker',
                            );
                            if (result is LatLng) {
                              setState(() => selectedLocation = result);
                            }
                          },
                        ),
                        if (selectedLocation != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Lat: ${selectedLocation!.latitude}, Lng: ${selectedLocation!.longitude}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        const SizedBox(height: 25),
                        isSaving
                            ? const CircularProgressIndicator()
                            : MyButton(
                              onTap: saveProviderInfo,
                              text: 'Guardar y Activar Perfil',
                              color: const Color(0xFF007BFF),
                            ),
                      ],
                    ),
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
