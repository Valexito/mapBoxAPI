import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'modules/user_parking/firebase_options.dart';
import 'package:mapbox_api/modules/user_parking/pages/map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapa con Parqueos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const MapScreen(),
    );
  }
}
