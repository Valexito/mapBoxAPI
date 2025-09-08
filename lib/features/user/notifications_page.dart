import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/components/ui/my_button.dart';
import 'package:mapbox_api/components/ui/my_text.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);
  static const tileBg = Color(0xFFF7F7F9);

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  bool _loading = true;
  bool _saving = false;

  // master + sub opciones
  bool _enableAll = true;
  bool _emailAlerts = false;
  bool _reservationAlerts = true;
  bool _generalAlerts = true;

  @override
  void initState() {
    super.initState();
    _loadFromStore();
  }

  Future<void> _loadFromStore() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final doc =
          await _db
              .collection('users')
              .doc(uid)
              .collection('settings')
              .doc('notifications')
              .get();
      if (doc.exists) {
        final d = doc.data()!;
        _enableAll = (d['enableAll'] as bool?) ?? _enableAll;
        _emailAlerts = (d['emailAlerts'] as bool?) ?? _emailAlerts;
        _reservationAlerts =
            (d['reservationAlerts'] as bool?) ?? _reservationAlerts;
        _generalAlerts = (d['generalAlerts'] as bool?) ?? _generalAlerts;
      }
    } catch (_) {
      // si falla, usamos los defaults
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para guardar.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('notifications')
          .set({
            'enableAll': _enableAll,
            'emailAlerts': _emailAlerts,
            'reservationAlerts': _reservationAlerts,
            'generalAlerts': _generalAlerts,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Notificaciones guardadas')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toggleMaster(bool v) {
    setState(() {
      _enableAll = v;
      if (!v) {
        // opcional: apaga todas cuando se desactiva maestro
        _emailAlerts = false;
        _reservationAlerts = false;
        _generalAlerts = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const headerHeight = 200.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      // ===== HEADER (gradiente + título + back) =====
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

                      // ===== CARD =====
                      Transform.translate(
                        offset: const Offset(0, -34),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(22),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                16,
                                14,
                                18,
                              ),
                              child: Column(
                                children: [
                                  _NotifyTile(
                                    title: 'Enable Notifications',
                                    subtitle: 'You will receive daily updates.',
                                    value: _enableAll,
                                    onChanged: _toggleMaster,
                                    enabled: true,
                                  ),
                                  const _DividerInset(),

                                  _NotifyTile(
                                    title: 'Email Alerts',
                                    subtitle: 'Expect daily updates from us.',
                                    value: _emailAlerts,
                                    onChanged:
                                        (v) => setState(() => _emailAlerts = v),
                                    enabled: _enableAll,
                                  ),
                                  const _DividerInset(),

                                  _NotifyTile(
                                    title: 'Reservation Alerts',
                                    subtitle:
                                        'Updates about your reservations.',
                                    value: _reservationAlerts,
                                    onChanged:
                                        (v) => setState(
                                          () => _reservationAlerts = v,
                                        ),
                                    enabled: _enableAll,
                                  ),
                                  const _DividerInset(),

                                  _NotifyTile(
                                    title: 'General Alerts',
                                    subtitle: 'You will receive daily updates.',
                                    value: _generalAlerts,
                                    onChanged:
                                        (v) =>
                                            setState(() => _generalAlerts = v),
                                    enabled: _enableAll,
                                  ),

                                  const SizedBox(height: 20),
                                  _saving
                                      ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                      : MyButton(text: 'Save', onTap: _save),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
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
    final titleWidget = MyText(
      text: title,
      variant: MyTextVariant.normal,
      fontSize: 14,
    );

    final subWidget = MyText(
      text: subtitle,
      variant: MyTextVariant.bodyMuted,
      fontSize: 12,
    );

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
                children: [titleWidget, const SizedBox(height: 4), subWidget],
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
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1),
    );
  }
}
