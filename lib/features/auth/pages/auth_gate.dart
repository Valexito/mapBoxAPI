import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../users/providers/user_providers.dart';
import '../../users/pages/complete_profile_page.dart';
import '../../core/pages/home_switch.dart';
import 'auth_flow_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStream = FirebaseAuth.instance.authStateChanges();

    return StreamBuilder<User?>(
      stream: authStream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _CenterWait('Inicializando...');
        }

        final user = snap.data;

        if (user == null) {
          return const AuthFlowPage(); // Login / SignUp
        }

        return FutureBuilder<bool>(
          future: ref.read(canEnterAppProvider(user.uid).future),
          builder: (context, canSnap) {
            if (canSnap.connectionState == ConnectionState.waiting) {
              return const _CenterWait('Verificando perfil...');
            }

            final canEnter = canSnap.data ?? false;
            if (canEnter) {
              return const HomeSwitch();
            }

            return CompleteProfilePage(
              user: FirebaseAuth.instance.currentUser!,
              isNewUser: false,
            );
          },
        );
      },
    );
  }
}

class _CenterWait extends StatelessWidget {
  final String msg;
  const _CenterWait(this.msg);

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
