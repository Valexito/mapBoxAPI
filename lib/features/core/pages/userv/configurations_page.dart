import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';

// Providers que ya tienes
import 'package:mapbox_api/features/core/providers/firebase_providers.dart'
    show currentUserProvider;
import 'package:mapbox_api/features/users/providers/user_providers.dart'
    show myNotificationSettingsStreamProvider, saveNotificationSettingsProvider;

class ConfigurationsPage extends ConsumerWidget {
  const ConfigurationsPage({super.key});

  Future<void> _save(
    WidgetRef ref, {
    required String uid,
    required Map<String, dynamic> newValues,
  }) async {
    await ref.read(saveNotificationSettingsProvider).call(uid, newValues);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final uid = user?.uid;

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
          'Configuraciones',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body:
          uid == null
              ? const Center(
                child: MyText(
                  text: 'Inicia sesión para administrar tus configuraciones.',
                  variant: MyTextVariant.bodyMuted,
                  textAlign: TextAlign.center,
                ),
              )
              : _SettingsBody(uid: uid),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(myNotificationSettingsStreamProvider);

    return notifAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) => Center(
            child: MyText(
              text: 'Error cargando configuraciones: $e',
              variant: MyTextVariant.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ),
      data: (data) {
        final enabled = (data?['enabled'] as bool?) ?? true;
        final reminders = (data?['reminders'] as bool?) ?? true;
        final marketing = (data?['marketing'] as bool?) ?? false;
        final updates = (data?['updates'] as bool?) ?? true;

        Widget sectionTitle(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: MyText(
            text: t,
            variant: MyTextVariant.bodyMuted,
            fontSize: 13,
          ),
        );

        Widget card(List<Widget> children) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Material(
            color: Colors.white,
            elevation: 1.5,
            shadowColor: Colors.black12,
            borderRadius: BorderRadius.circular(14),
            child: Column(children: children),
          ),
        );

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            sectionTitle('Notificaciones'),
            card([
              _SwitchTile(
                title: 'Activadas',
                subtitle: 'Permitir notificaciones de la app',
                value: enabled,
                onChanged:
                    (v) => ref.read(saveNotificationSettingsProvider).call(
                      uid,
                      {'enabled': v},
                    ),
              ),
              const Divider(height: 0),
              _SwitchTile(
                title: 'Recordatorios',
                subtitle: 'Antes de iniciar/terminar una reservación',
                value: reminders,
                onChanged:
                    (v) => ref.read(saveNotificationSettingsProvider).call(
                      uid,
                      {'reminders': v},
                    ),
              ),
              const Divider(height: 0),
              _SwitchTile(
                title: 'Actualizaciones',
                subtitle: 'Cambios importantes y estado del servicio',
                value: updates,
                onChanged:
                    (v) => ref.read(saveNotificationSettingsProvider).call(
                      uid,
                      {'updates': v},
                    ),
              ),
              const Divider(height: 0),
              _SwitchTile(
                title: 'Promociones',
                subtitle: 'Ofertas y recomendaciones personalizadas',
                value: marketing,
                onChanged:
                    (v) => ref.read(saveNotificationSettingsProvider).call(
                      uid,
                      {'marketing': v},
                    ),
              ),
            ]),

            sectionTitle('Preferencias (local)'),
            card(const [
              _ArrowTile(
                icon: Icons.translate_rounded,
                title: 'Idioma',
                subtitle: 'Español',
              ),
              Divider(height: 0),
              _ArrowTile(
                icon: Icons.palette_outlined,
                title: 'Tema',
                subtitle: 'Predeterminado del sistema',
              ),
            ]),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MyText(
                text:
                    'Estos ajustes se guardan en tu cuenta. '
                    'Puedes cambiarlos en cualquier momento.',
                variant: MyTextVariant.bodyMuted,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: (subtitle == null) ? null : Text(subtitle!),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      activeColor: AppColors.navyBottom,
    );
  }
}

class _ArrowTile extends StatelessWidget {
  const _ArrowTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.iconCircle,
        child: Icon(icon, color: AppColors.navyBottom),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: (subtitle == null) ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right_rounded),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}
