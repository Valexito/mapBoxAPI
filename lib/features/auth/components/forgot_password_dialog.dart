import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/common/utils/components/ui/my_textfield.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _emailCtrl = TextEditingController();
  String? _message;
  bool _sending = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailCtrl.text.trim();
    final isEmail = RegExp(
      r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$',
    ).hasMatch(email);

    if (!isEmail) {
      setState(() => _message = 'Escribe un correo válido.');
      return;
    }

    setState(() {
      _sending = true;
      _message = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _message = 'Te enviamos un correo para restablecer tu contraseña.';
      });
    } on FirebaseAuthException catch (e) {
      var msg = 'Ocurrió un error. Intenta de nuevo.';
      if (e.code == 'invalid-email') msg = 'El correo no es válido.';
      if (e.code == 'user-not-found') {
        msg = 'No existe una cuenta con ese correo.';
      }
      setState(() => _message = msg);
    } catch (_) {
      setState(() => _message = 'Ocurrió un error inesperado.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDims.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.10),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.headerTop, AppColors.headerBottom],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.headerBottom.withOpacity(0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const MyText(
                  text: 'Recuperar contraseña',
                  variant: MyTextVariant.normalBold,
                  customColor: AppColors.headerBottom,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              const MyText(
                text:
                    'Ingresa tu correo electrónico para recibir el enlace de restablecimiento.',
                variant: MyTextVariant.subtitle,
                textAlign: TextAlign.center,
                fontSize: 13,
              ),
              const SizedBox(height: 18),
              MyTextField(
                controller: _emailCtrl,
                hintText: 'Ingresa tu correo electrónico',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.mail_outline,
                margin: EdgeInsets.zero,
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                MyText(
                  text: _message!,
                  variant: MyTextVariant.bodyMuted,
                  textAlign: TextAlign.center,
                  fontSize: 12,
                  customColor:
                      _message!.startsWith('Te enviamos')
                          ? AppColors.success
                          : AppColors.textSecondary,
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed:
                            _sending ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.headerBottom.withOpacity(0.35),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDims.radiusLg,
                            ),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: const MyText(
                          text: 'Cancelar',
                          variant: MyTextVariant.normalBold,
                          customColor: AppColors.headerBottom,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyButton(
                      onTap: _sending ? null : _sendResetEmail,
                      text: _sending ? 'Enviando...' : 'Enviar',
                      loading: _sending,
                      margin: EdgeInsets.zero,
                      height: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
