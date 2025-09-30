import 'package:flutter/material.dart';
import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';

class LegalInformationPage extends StatelessWidget {
  const LegalInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card(String title, String body) => Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(text: title, variant: MyTextVariant.normalBold),
            const SizedBox(height: 8),
            MyText(
              text: body,
              variant: MyTextVariant.body,
              customColor: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );

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
          'Información legal',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          card(
            'Términos de servicio',
            'Al usar la app aceptas los términos y condiciones. El uso indebido, '
                'fraude o violación de las políticas puede resultar en la suspensión de la cuenta.',
          ),
          const SizedBox(height: 12),
          card(
            'Privacidad',
            'Protegemos tu información y solo la usamos para proveer las funciones del servicio. '
                'Puedes solicitar la eliminación de tu cuenta y datos desde Soporte.',
          ),
          const SizedBox(height: 12),
          card(
            'Responsabilidad',
            'La app conecta a usuarios con parqueos registrados. Cada proveedor es responsable '
                'por su establecimiento. Reporta cualquier problema desde “Reportar un problema”.',
          ),
          const SizedBox(height: 12),
          card('Contacto', '¿Dudas legales? Escríbenos a soporte@tuapp.com'),
        ],
      ),
    );
  }
}
