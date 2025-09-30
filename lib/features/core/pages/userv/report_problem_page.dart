import 'package:flutter/material.dart';
import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';

class ReportProblemPage extends StatefulWidget {
  const ReportProblemPage({super.key});

  @override
  State<ReportProblemPage> createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = _form.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 800)); // simula envío
    if (!mounted) return;

    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Gracias! Recibimos tu reporte.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration deco(String hint, {IconData? icon, int? maxLines}) {
      return InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: const Color(0xFFF7F7F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.navyBottom,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            size: 32,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Regresar',
        ),
        title: const Text(
          'Reportar un problema',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Material(
          color: Colors.white,
          elevation: 1.5,
          shadowColor: Colors.black12,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const MyText(
                    text: 'Cuéntanos qué ocurrió',
                    variant: MyTextVariant.title,
                  ),
                  const SizedBox(height: 6),
                  const MyText(
                    text:
                        'Describe el problema para que podamos ayudarte. '
                        'Incluye pasos para reproducir si es posible.',
                    variant: MyTextVariant.bodyMuted,
                    fontSize: 13,
                  ),
                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: deco(
                      'Tu correo (opcional)',
                      icon: Icons.mail_outline,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final ok = RegExp(
                        r'^[^@]+@[^@]+\.[^@]+$',
                      ).hasMatch(v.trim());
                      if (!ok) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _subject,
                    decoration: deco('Asunto', icon: Icons.subject),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Escribe un asunto'
                                : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _message,
                    minLines: 5,
                    maxLines: 8,
                    decoration: deco(
                      'Describe el problema',
                      icon: Icons.chat_outlined,
                    ),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Escribe el detalle'
                                : null,
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyBottom,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _sending ? null : _submit,
                    child: Text(_sending ? 'Enviando...' : 'Enviar reporte'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
