import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/components/ui/my_password_field.dart';
import 'package:mapbox_api/components/ui/my_button.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  final _auth = FirebaseAuth.instance;
  bool _busy = false;
  String? _error;
  bool _hasPasswordProvider = false;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    final u = _auth.currentUser;
    final email = u?.email;
    if (email == null) return;

    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      setState(() => _hasPasswordProvider = methods.contains('password'));
    } catch (_) {
      // ignora silenciosamente
    }
  }

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final u = _auth.currentUser;
    final email = u?.email;
    if (u == null || email == null) {
      setState(() => _error = 'No hay sesión de usuario activa.');
      return;
    }

    final current = _current.text.trim();
    final np = _new.text.trim();
    final cp = _confirm.text.trim();

    if (np.length < 8) {
      setState(
        () => _error = 'La nueva contraseña debe tener al menos 8 caracteres.',
      );
      return;
    }
    if (np != cp) {
      setState(() => _error = 'Las contraseñas no coinciden.');
      return;
    }
    if (current == np) {
      setState(
        () => _error = 'La nueva contraseña no puede ser igual a la actual.',
      );
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      // Reautenticación requerida para operación sensible
      final cred = EmailAuthProvider.credential(
        email: email,
        password: current,
      );
      await u.reauthenticateWithCredential(cred);
      await u.updatePassword(np);

      if (!mounted) return;
      Navigator.of(context).pop(true); // cierra el diálogo con éxito
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'wrong-password':
          msg = 'Contraseña actual incorrecta.';
          break;
        case 'weak-password':
          msg = 'La nueva contraseña es demasiado débil.';
          break;
        case 'requires-recent-login':
          msg = 'Vuelve a iniciar sesión e inténtalo de nuevo.';
          break;
        default:
          msg = e.message ?? 'Error de autenticación.';
      }
      setState(() => _error = msg);
    } catch (e) {
      setState(() => _error = 'Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content =
        _hasPasswordProvider
            ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyPasswordField(
                  controller: _current,
                  hintText: 'Contraseña actual',
                  margin: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                MyPasswordField(
                  controller: _new,
                  hintText: 'Nueva contraseña',
                  margin: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                MyPasswordField(
                  controller: _confirm,
                  hintText: 'Confirmar nueva contraseña',
                  margin: EdgeInsets.zero,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  MyText(
                    text: _error!,
                    variant: MyTextVariant.bodyMuted,
                    customColor: Colors.red,
                    fontSize: 12,
                  ),
                ],
                const SizedBox(height: 16),
                _busy
                    ? const Center(child: CircularProgressIndicator())
                    : MyButton(
                      text: 'Cambiar contraseña',
                      onTap: _changePassword,
                    ),
              ],
            )
            : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                MyText(
                  text:
                      'Tu cuenta inició sesión con Google u otro proveedor y no tiene contraseña local.',
                  variant: MyTextVariant.body,
                  fontSize: 14,
                ),
                SizedBox(height: 8),
                MyText(
                  text:
                      'Vincula un método de correo/contraseña desde "Configure Profile" para poder cambiarla.',
                  variant: MyTextVariant.bodyMuted,
                  fontSize: 13,
                ),
              ],
            );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const MyText(
        text: 'Change Password',
        variant: MyTextVariant.title,
      ),
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
