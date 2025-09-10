// lib/features/users/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/users/models/notification_settings.dart';
import 'package:mapbox_api/features/users/providers/user_providers.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});
  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  NotificationSettings? _editing;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    const headerHeight = 200.0;
    final asyncSettings = ref.watch(notificationSettingsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: asyncSettings.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (s) {
            final settings = _editing ?? s;

            void onMaster(bool v) {
              setState(() {
                _editing = (settings).copyWith(
                  enableAll: v,
                  emailAlerts: v ? settings.emailAlerts : false,
                  reservationAlerts: v ? settings.reservationAlerts : false,
                  generalAlerts: v ? settings.generalAlerts : false,
                );
              });
            }

            return SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // HEADER
                  Stack(
                    children: [
                      Container(
                        height: headerHeight,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [navyTop, navyBottom],
                          ),
                        ),
                        child: const Center(
                          child: MyText(
                            text: 'NOTIFICATIONS',
                            variant: MyTextVariant.title,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // CARD
                  Transform.translate(
                    offset: const Offset(0, -34),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(22),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
                          child: Column(
                            children: [
                              _NotifyTile(
                                title: 'Enable Notifications',
                                subtitle: 'You will receive daily updates.',
                                value: settings.enableAll,
                                onChanged: onMaster,
                                enabled: true,
                              ),
                              const _DividerInset(),
                              _NotifyTile(
                                title: 'Email Alerts',
                                subtitle: 'Expect daily updates from us.',
                                value: settings.emailAlerts,
                                enabled: settings.enableAll,
                                onChanged:
                                    (v) => setState(() {
                                      _editing = settings.copyWith(
                                        emailAlerts: v,
                                      );
                                    }),
                              ),
                              const _DividerInset(),
                              _NotifyTile(
                                title: 'Reservation Alerts',
                                subtitle: 'Updates about your reservations.',
                                value: settings.reservationAlerts,
                                enabled: settings.enableAll,
                                onChanged:
                                    (v) => setState(() {
                                      _editing = settings.copyWith(
                                        reservationAlerts: v,
                                      );
                                    }),
                              ),
                              const _DividerInset(),
                              _NotifyTile(
                                title: 'General Alerts',
                                subtitle: 'You will receive daily updates.',
                                value: settings.generalAlerts,
                                enabled: settings.enableAll,
                                onChanged:
                                    (v) => setState(() {
                                      _editing = settings.copyWith(
                                        generalAlerts: v,
                                      );
                                    }),
                              ),
                              const SizedBox(height: 20),
                              _saving
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : MyButton(
                                    text: 'Save',
                                    onTap: () async {
                                      setState(() => _saving = true);
                                      try {
                                        await ref.read(
                                          saveNotificationSettingsProvider,
                                        )(_editing ?? settings);
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Notificaciones guardadas',
                                            ),
                                          ),
                                        );
                                        Navigator.pop(context);
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted)
                                          setState(() => _saving = false);
                                      }
                                    },
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotifyTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  static const navyLight = Color(0xFF1B3A57);
  const _NotifyTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: title,
                    variant: MyTextVariant.normal,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 4),
                  MyText(
                    text: subtitle,
                    variant: MyTextVariant.bodyMuted,
                    fontSize: 12,
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: navyLight,
              activeTrackColor: navyLight.withOpacity(0.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerInset extends StatelessWidget {
  const _DividerInset();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Divider(height: 1),
  );
}
