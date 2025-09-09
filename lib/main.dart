import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ⬅️ Riverpod
import 'package:firebase_core/firebase_core.dart';
import 'package:mapbox_api/features/auth/pages/auth_gate.dart';
import 'package:mapbox_api/firebase_options.dart';
import 'package:mapbox_api/features/core/pages/home_page.dart';
import 'package:mapbox_api/features/reservations/pages/reservations_page.dart';
import 'package:mapbox_api/features/reservations/components/route_view_page_wrapper.dart';
import 'package:mapbox_api/features/owners/pages/become_owner_page.dart';
import 'package:mapbox_api/components/map_picker_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Avoids [core/duplicate-app] if hot restart or auto-init
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    const ProviderScope(
      // ⬅️ this is the only real change
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapa con Parqueos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      initialRoute: '/auth',
      routes: {
        '/auth': (_) => const AuthGate(),
        '/homePage': (_) => const HomePage(),
        '/becomeProvider': (_) => const BecomeOwnerPage(),
        '/mapPicker': (_) => const MapPickerPage(),
        '/routeView': (_) => const RouteViewPageWrapper(),
        '/reservationsPage': (_) => const ReservationsPage(),
      },
    );
  }
}
