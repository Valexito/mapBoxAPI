import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/common/utils/components/ui/navy_header.dart';

import 'package:mapbox_api/features/users/pages/configure_profile_page.dart';
import 'package:mapbox_api/features/users/pages/notifications_page.dart';
import 'package:mapbox_api/features/reservations/pages/reservations_page.dart';
import 'package:mapbox_api/features/owners/pages/become_owner_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final name =
        (user?.displayName?.trim().isNotEmpty ?? false)
            ? user!.displayName!.trim().toUpperCase()
            : 'TU NOMBRE';

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // ===== Header navy + botón volver "<" + "Editar perfil" =====
              Stack(
                children: [
                  NavyHeader(
                    height: 240,
                    roundedBottom: false,
                    trailing: SizedBox(
                      height: 30,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ConfigureProfilePage(),
                            ),
                          );
                        },
                        child: const Text('Editar perfil'),
                      ),
                    ),
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 6),
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
                                      size: 54,
                                      color: AppColors.navyBottom,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MyText(
                        text: name,
                        variant: MyTextVariant.title,
                        customColor: Colors.white,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                  // Botón volver "<" alineado como en otras páginas
                  Positioned(
                    left: 6,
                    top: 35,
                    child: SafeArea(
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 35,
                        ),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Regresar',
                      ),
                    ),
                  ),
                ],
              ),

              // ===== Cuerpo =====
              Transform.translate(
                offset: const Offset(0, -27),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Bloque de acciones
                      Material(
                        color: Colors.white,
                        elevation: 8,
                        shadowColor: Colors.black12,
                        borderRadius: BorderRadius.circular(22),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 6,
                          ),
                          child: Column(
                            children: [
                              _ActionItem(
                                icon: Icons.lock_outline,
                                title: 'Contraseña',
                                go: _Go.configure,
                              ),
                              _Divider(),
                              _ActionItem(
                                icon: Icons.email_outlined,
                                title: 'Correo electrónico',
                                go: _Go.configure,
                              ),
                              _Divider(),
                              _ActionItem(
                                icon: Icons.fingerprint_outlined,
                                title: 'Huella digital',
                                go: _Go.none,
                              ),
                              _Divider(),
                              _ActionItem(
                                icon: Icons.support_agent_outlined,
                                title: 'Soporte',
                                go: _Go.notifications,
                              ),
                              _Divider(),
                              _ActionItem(
                                icon: Icons.logout_outlined,
                                title: 'Cerrar sesión',
                                go: _Go.signout,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Atajos
                      Material(
                        color: Colors.white,
                        elevation: 6,
                        shadowColor: Colors.black12,
                        borderRadius: BorderRadius.circular(22),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              _Shortcut(
                                icon: Icons.bookmark_added_outlined,
                                title: 'Mis reservaciones',
                                go: _Go.reservations,
                              ),
                              SizedBox(height: 8),
                              _Shortcut(
                                icon: Icons.badge_outlined,
                                title: 'Registrar un parqueo',
                                go: _Go.owner,
                              ),
                              SizedBox(height: 8),
                              _Shortcut(
                                icon: Icons.notifications_active_outlined,
                                title: 'Notificaciones',
                                go: _Go.notifications,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: AppColors.cardDivider);
}

enum _Go { configure, notifications, reservations, owner, signout, none }

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.title,
    required this.go,
  });

  final IconData icon;
  final String title;
  final _Go go;

  void _handleTap(BuildContext context) {
    switch (go) {
      case _Go.configure:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ConfigureProfilePage()),
        );
        break;
      case _Go.notifications:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
        break;
      case _Go.signout:
        FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cerrar sesión')));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _handleTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.iconCircle,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 20, color: AppColors.navyBottom),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.icon, required this.title, required this.go});
  final IconData icon;
  final String title;
  final _Go go;

  void _handleTap(BuildContext context) {
    switch (go) {
      case _Go.reservations:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReservationsPage()),
        );
        break;
      case _Go.owner:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BecomeOwnerPage()),
        );
        break;
      case _Go.notifications:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.iconCircle,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _handleTap(context),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.iconCircle,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: AppColors.navyBottom),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
