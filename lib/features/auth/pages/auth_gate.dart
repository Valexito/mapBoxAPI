// lib/features/auth/pages/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/firebase_providers.dart';
import '../../users/pages/complete_profile_page.dart';
import '../../users/providers/user_providers.dart';
import '../../core/pages/home_switch.dart';
import '../components/verify_email_page.dart';
import 'auth_flow_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  bool _isPasswordUser(User user) {
    return user.providerData.any((p) => p.providerId == 'password');
  }

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

        final isPasswordUser = _isPasswordUser(user);

        if (isPasswordUser && !user.emailVerified) {
          return VerifyEmailPage(user: user);
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
