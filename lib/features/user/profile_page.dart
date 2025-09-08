import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/features/user/configure_profile_page.dart';
// ⬇️ dialog we define below
import 'package:mapbox_api/features/auth/components/reset_passwod_dialog.dart';
import 'package:mapbox_api/features/auth/components/reset_passwod_dialog.dart';
import 'package:mapbox_api/features/reservations/pages/reservations_page.dart';
import 'package:mapbox_api/features/provider/become_provider_page.dart';
import 'package:mapbox_api/features/user/notifications_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    const headerHeight = 260.0;
    const navyTop = Color(0xFF0D1B2A);
    const navyBottom = Color(0xFF1B3A57);

    final user = _auth.currentUser;
    final photoUrl = user?.photoURL;
    final name = user?.displayName?.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // ===== HEADER (gradiente como login) =====
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            photoUrl != null
                                ? Image.network(photoUrl, fit: BoxFit.cover)
                                : Container(
                                  color: Colors.white,
                                  child: const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: navyBottom,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MyText(
                      text: (name?.isNotEmpty ?? false) ? name! : 'Tu nombre',
                      variant: MyTextVariant.title,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Botón pequeño "Editar perfil"
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ConfigureProfilePage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit Profile'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== CARD con opciones =====
              Transform.translate(
                offset: const Offset(0, -34),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(22),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
                      child: Column(
                        children: [
                          _SettingsTile(
                            icon: Icons.person_outline,
                            label: 'Configure Profile',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ConfigureProfilePage(),
                                ),
                              );
                            },
                          ),
                          const _DividerInset(),

                          _SettingsTile(
                            icon: Icons.lock_outline,
                            label: 'Change Password',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => const ResetPasswordDialog(),
                              );
                            },
                          ),
                          const _DividerInset(),

                          _SettingsTile(
                            icon: Icons.bookmark_outline,
                            label: 'View Reservations',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ReservationsPage(),
                                ),
                              );
                            },
                          ),
                          const _DividerInset(),

                          _SettingsTile(
                            icon: Icons.business_outlined,
                            label: 'Become a Provider',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => const BecomeProviderPage(),
                              );
                            },
                          ),
                          const _DividerInset(),

                          _SettingsTile(
                            icon: Icons.notifications_none,
                            label: 'Display & Notifications',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationsPage(),
                                ),
                              );
                            },
                          ),
                          const _DividerInset(),

                          _SettingsTile(
                            icon: Icons.logout,
                            label: 'Logout',
                            iconColor: Colors.red,
                            labelColor: Colors.red,
                            onTap: () async {
                              await _auth.signOut();
                              if (!mounted) return;
                              Navigator.of(context).popUntil((r) => r.isFirst);
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
        ),
      ),
    );
  }
}

/// Tile de ajustes con el mismo “feeling” de tus inputs/btns:
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? labelColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    const tileBg = Color(0xFFF7F7F9);
    final labelWidget =
        labelColor == null
            ? MyText(text: label, variant: MyTextVariant.normal, fontSize: 14)
            : Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            );

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor ?? const Color(0xFF1B3A57)),
            ),
            const SizedBox(width: 12),
            Expanded(child: labelWidget),
            const Icon(Icons.chevron_right, color: Color(0xFF9AA3AF)),
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
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Divider(height: 1),
    );
  }
}
