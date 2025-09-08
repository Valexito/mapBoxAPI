import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sign_up.dart'; // Asegúrate que el nombre coincida
import '../providers/auth_ui_providers.dart';
import 'login_page.dart';

class AuthFlowPage extends ConsumerWidget {
  const AuthFlowPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showingRegister = ref.watch(showRegisterProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child:
          showingRegister
              ? SignUpPage(
                key: const ValueKey('signup'),
                onBackToLogin:
                    () => ref.read(showRegisterProvider.notifier).state = false,
              )
              : LoginPage(
                key: const ValueKey('login'),
                onShowRegister:
                    () => ref.read(showRegisterProvider.notifier).state = true,
              ),
    );
  }
}
