import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mapbox_api/firebase_options.dart';

import 'package:mapbox_api/modules/core/pages/home_page.dart';
import 'package:mapbox_api/modules/auth/services/auth_page.dart';
import 'package:mapbox_api/modules/reservations/pages/reservations_page.dart';
import 'package:mapbox_api/modules/reservations/pages/map_navigation_page.dart';
import 'package:mapbox_api/modules/reservations/widgets/route_view_page_wrapper.dart';
import 'package:mapbox_api/modules/provider/become_provider_page.dart';
import 'package:mapbox_api/components/map_picker_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Evita [core/duplicate-app] si ya existe una instancia (auto-init o hot restart)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

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
      initialRoute: '/auth',
      routes: {
        '/auth': (_) => const AuthPage(),
        '/homePage': (_) => const HomePage(),
        '/becomeProvider': (_) => const BecomeProviderPage(),
        '/mapPicker': (_) => const MapPickerPage(),
        '/routeView': (_) => const RouteViewPageWrapper(),
        '/navigate': (_) => const MapNavigationPage(),
        '/reservationsPage': (_) => const ReservationsPage(),
      },
    );
  }
}
