// ==============================
// lib/features/auth/pages/verify_email_page.dart
// ==============================
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/users/pages/complete_profile_page.dart';

class VerifyEmailPage extends StatefulWidget {
  final User user;
  const VerifyEmailPage({super.key, required this.user});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _checking = false;
  bool _resending = false;
  String? _message;

  Future<void> _reloadAndContinue() async {
    setState(() {
      _checking = true;
      _message = null;
    });

    try {
      await widget.user.reload();
      final current = FirebaseAuth.instance.currentUser;

      if (current != null && current.emailVerified) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => CompleteProfilePage(user: current, isNewUser: true),
          ),
          (_) => false,
        );
        return;
      }

      setState(() {
        _message =
            'Tu correo aún no está verificado. Revisa tu bandeja de entrada o spam.';
      });
    } catch (_) {
      setState(() {
        _message =
            'No se pudo verificar el estado del correo. Intenta de nuevo.';
      });
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resendEmail() async {
    setState(() {
      _resending = true;
      _message = null;
    });

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      setState(() {
        _message = 'Correo de verificación reenviado.';
      });
    } catch (_) {
      setState(() {
        _message = 'No se pudo reenviar el correo. Intenta de nuevo.';
      });
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _backToLogin() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFD8F3EE),
      body: SafeArea(
        top: false,
        child: SizedBox(
          height: screen.height,
          child: Stack(
            children: [
              Container(
                height: screen.height * 0.42,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.headerTop, AppColors.headerBottom],
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: -10,
                right: -10,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 95,
                left: 28,
                right: 28,
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.22),
                          width: 1.4,
                        ),
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const MyText(
                      text: "Veriicar correo electrónico",
                      variant: MyTextVariant.title,
                      customColor: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MyText(
                        text:
                            "Te enviamos un correo a ${widget.user.email ?? ''}. Verifícalo para continuar.",
                        variant: MyTextVariant.subtitle,
                        customColor: Colors.white70,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: screen.height * 0.31,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(34),
                      topRight: Radius.circular(34),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: const MyText(
                              text: "Confirma tu correo electrónico",
                              variant: MyTextVariant.normalBold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const MyText(
                          text:
                              "Revisa tu bandeja principal, promociones o spam. Después toca el botón de abajo.",
                          variant: MyTextVariant.subtitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppDims.radiusLg,
                            ),
                            border: Border.all(
                              color: AppColors.headerBottom.withOpacity(0.15),
                            ),
                          ),
                          child: Column(
                            children: [
                              const MyText(
                                text: "Correo registrado",
                                variant: MyTextVariant.bodyMuted,
                                fontSize: 12,
                              ),
                              const SizedBox(height: 6),
                              MyText(
                                text: widget.user.email ?? '',
                                variant: MyTextVariant.bodyBold,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        if (_message != null) ...[
                          const SizedBox(height: 14),
                          MyText(
                            text: _message!,
                            variant: MyTextVariant.bodyMuted,
                            textAlign: TextAlign.center,
                            fontSize: 12,
                          ),
                        ],
                        const SizedBox(height: 24),
                        MyButton(
                          text:
                              _checking
                                  ? "Revisando..."
                                  : "Ya verifiqué mi correo",
                          loading: _checking,
                          onTap: _checking ? null : _reloadAndContinue,
                          margin: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _resending ? null : _resendEmail,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDims.radiusLg,
                              ),
                            ),
                            side: BorderSide(
                              color: AppColors.headerBottom.withOpacity(0.35),
                            ),
                          ),
                          child: Text(
                            _resending ? "Reenviando..." : "Reenviar correo",
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _backToLogin,
                          child: const Text("Regresar a inicio de sesión"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
