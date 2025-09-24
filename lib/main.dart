import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';

import 'firebase_options.dart';
import 'features/auth/pages/auth_gate.dart';
import 'features/core/pages/home_page.dart';
import 'features/owners/pages/become_owner_page.dart';
import 'features/reservations/components/route_view_page_wrapper.dart';
import 'features/reservations/pages/reservations_page.dart';
import 'common/utils/components/map_picker_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );
  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mapa con Parqueos',
      debugShowCheckedModeBanner: false,
      /*
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),*/
      theme: AppTheme.build(),
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
