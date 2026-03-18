import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/firebase_providers.dart';
import '../../users/pages/complete_profile_page.dart';
import '../../users/providers/user_providers.dart';
import '../../core/pages/home_switch.dart';
import 'auth_flow_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateChangesProvider);

    return authAsync.when(
      loading: () => const _CenterWait(),
      error: (_, __) => const AuthFlowPage(),
      data: (user) {
        if (user == null) {
          return const AuthFlowPage();
        }

        final canEnterAsync = ref.watch(canEnterAppProvider(user.uid));

        return canEnterAsync.when(
          loading: () => const _CenterWait(),
          error: (_, __) => CompleteProfilePage(user: user, isNewUser: false),
          data: (canEnter) {
            if (canEnter) {
              return const HomeSwitch();
            }

            return CompleteProfilePage(user: user, isNewUser: false);
          },
        );
      },
    );
  }
}

class _CenterWait extends StatelessWidget {
  const _CenterWait();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
