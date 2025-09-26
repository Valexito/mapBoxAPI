import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  static const _navyDark = Color(0xFF0D1B2A);
  static const _navyLight = Color(0xFF1B3A57);

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
      setState(
        () =>
            _message = 'Te enviamos un correo para restablecer tu contraseña.',
      );
    } on FirebaseAuthException catch (e) {
      var msg = 'Ocurrió un error. Intenta de nuevo.';
      if (e.code == 'invalid-email') msg = 'El correo no es válido.';
      if (e.code == 'user-not-found')
        msg = 'No existe una cuenta con ese correo.';
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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MyText(
              text: '¿OLVIDASTE TU CONTRASEÑA?',
              variant: MyTextVariant.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const MyText(
              text: 'Ingresa tu correo electrónico para recibir el enlace.',
              variant: MyTextVariant.bodyMuted,
              textAlign: TextAlign.center,
              fontSize: 13,
            ),
            const SizedBox(height: 16),

            // ÍCONO DENTRO DEL TEXTFIELD (igual al login)
            MyTextField(
              controller: _emailCtrl,
              hintText: 'Ingresa tu correo electrónico',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              obscureText: false,
              prefixIcon: Icons.mail_outline, // ← aquí el ícono interno
              margin: EdgeInsets.zero,
            ),

            if (_message != null) ...[
              const SizedBox(height: 12),
              MyText(
                text: _message!,
                variant: MyTextVariant.body,
                textAlign: TextAlign.center,
                fontSize: 12,
              ),
            ],
            const SizedBox(height: 18),

            // BOTONES CENTRADOS, BAJITOS, SIMÉTRICOS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                  width: 120,
                  child: OutlinedButton(
                    onPressed: _sending ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _navyLight, width: 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const MyText(
                      text: 'Cancelar',
                      variant: MyTextVariant.normalBold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 40,
                  width: 120,
                  child: InkWell(
                    onTap: _sending ? null : _sendResetEmail,
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_navyDark, _navyLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _sending ? 'Enviando...' : 'Enviar',
                          style: const TextStyle(
                            color: Colors.white, // ← Texto blanco
                            fontWeight: FontWeight.bold, // igual que normalBold
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
