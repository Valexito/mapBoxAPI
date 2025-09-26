import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/pages/home_page.dart';
import '../../users/pages/complete_profile_page.dart';
import '../providers/auth_providers.dart';
import '../../users/providers/user_providers.dart';
import 'auth_flow_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authUserStreamProvider);

    return userAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Auth error: $e'))),
      data: (user) {
        // 1) Sin sesión → login/registro
        if (user == null) return const AuthFlowPage();

        // 2) Si quieres requerir verificación de email para email/password:
        //    deja esto activo; para Google normalmente ya viene verificado.
        if (!(user.emailVerified) &&
            user.providerData.any((p) => p.providerId == 'password')) {
          return const AuthFlowPage();
        }

        // 3) Con sesión → ¿perfil completo?
        final profileAsync = ref.watch(isProfileCompleteProvider(user.uid));
        return profileAsync.when(
          loading:
              () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
          // Si Firestore falla, muestra CompleteProfile para no bloquear
          error: (e, _) => CompleteProfilePage(user: user, isNewUser: true),
          data:
              (complete) =>
                  complete
                      ? const HomePage()
                      : CompleteProfilePage(user: user, isNewUser: true),
        );
      },
    );
  }
}
