import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/pages/home_page.dart';
import '../../users/complete_profile_page.dart';
import '../providers/auth_providers.dart';
import '../providers/user_profile_provider.dart';
import 'auth_flow_page.dart';

/// AuthGate:
/// - user == null  -> muestra AuthFlowPage (login/registro)
/// - user != null  -> verifica perfil en Firestore y decide HomePage o CompleteProfilePage
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authUserStreamProvider);

    return userAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, _) =>
              Scaffold(body: Center(child: Text('Error de autenticación: $e'))),
      data: (user) {
        if (user == null) {
          return const AuthFlowPage();
        }
        final profileAsync = ref.watch(hasUserProfileProvider);
        return profileAsync.when(
          loading:
              () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
          error:
              (e, _) => Scaffold(body: Center(child: Text('Error perfil: $e'))),
          data: (hasProfile) {
            if (hasProfile) return const HomePage();
            return CompleteProfilePage(user: user, isNewUser: true);
          },
        );
      },
    );
  }
}
