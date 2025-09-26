import 'package:flutter/material.dart';
import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';

class FrequentQuestionsPage extends StatelessWidget {
  const FrequentQuestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <({String q, String a})>[
      (
        q: '¿Cómo creo una reserva?',
        a:
            'Desde el mapa, selecciona un parqueo disponible y sigue los pasos. '
            'Verás el precio, horario y confirmación antes de finalizar.',
      ),
      (
        q: '¿Puedo cancelar una reserva?',
        a: 'Sí. Mientras no haya iniciado, puedes cancelarla desde Mis reservaciones.',
      ),
      (
        q: '¿Qué métodos de inicio de sesión hay?',
        a: 'Puedes usar Google o correo/contraseña.',
      ),
      (
        q: '¿Cómo me hago proveedor?',
        a: 'En tu perfil, entra a “Registrar un parqueo” y completa la información.',
      ),
    ];

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
          'Preguntas frecuentes',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final it = items[i];
          return Material(
            color: Colors.white,
            elevation: 1.5,
            shadowColor: Colors.black12,
            borderRadius: BorderRadius.circular(14),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: MyText(text: it.q, variant: MyTextVariant.normalBold),
              children: [
                const SizedBox(height: 4),
                MyText(
                  text: it.a,
                  variant: MyTextVariant.body,
                  customColor: AppColors.textSecondary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
