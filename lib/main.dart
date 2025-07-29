import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mapbox_api/modules/core/pages/home_page.dart';
import 'package:mapbox_api/modules/auth/services/auth_page.dart';
import 'package:mapbox_api/modules/core/pages/reservations_page.dart';
import 'package:mapbox_api/modules/user_parking/pages/map_navigation_page.dart';
import 'package:mapbox_api/modules/user_parking/widgets/route_view_page_wrapper.dart';
import 'modules/user_parking/firebase_options.dart';
import 'package:mapbox_api/modules/core/pages/become_provider_page.dart';
import 'package:mapbox_api/components/map_picker_page.dart';

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
      initialRoute: '/auth', // puedes cambiarlo si usas login automático
      routes: {
        '/auth': (_) => const AuthPage(),
        '/homePage': (_) => const HomePage(),
        '/becomeProvider': (_) => const BecomeProviderPage(),
        //from a user becoming a provider
        '/mapPicker': (_) => const MapPickerPage(),
        '/routeView': (_) => const RouteViewPageWrapper(), // con args adentro
        '/navigate': (_) => const MapNavigationPage(),
        '/reservationsPage': (_) => const ReservationsPage(),
      },
    );
  }
}
