import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class BecomeProviderPage extends StatefulWidget {
  const BecomeProviderPage({super.key});

  @override
  State<BecomeProviderPage> createState() => _BecomeProviderPageState();
}

class _BecomeProviderPageState extends State<BecomeProviderPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final slotsController = TextEditingController();
  final scheduleController = TextEditingController();
  final contactPhoneController = TextEditingController();

  bool isSaving = false;
  LatLng? selectedLocation;

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

      final double lat = selectedLocation!.latitude;
      final double lng = selectedLocation!.longitude;
      final int price = 6;

      // 1. Guardar en users/{uid}
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

      // 2. Guardar en parking/
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
      appBar: AppBar(title: const Text('Convertirse en Proveedor')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Datos del Parqueo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del parqueo',
                ),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),

              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),

              TextFormField(
                controller: slotsController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad de espacios',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),

              TextFormField(
                controller: scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Horario (ej. Lun a Vie 8am - 8pm)',
                ),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),

              TextFormField(
                controller: contactPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono de contacto',
                ),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),

              const SizedBox(height: 20),

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
                    setState(() {
                      selectedLocation = result;
                    });
                  }
                },
              ),

              if (selectedLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Lat: ${selectedLocation!.latitude}, Lng: ${selectedLocation!.longitude}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label:
                    isSaving
                        ? const CircularProgressIndicator()
                        : const Text('Guardar y Activar Perfil'),
                onPressed: isSaving ? null : saveProviderInfo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
