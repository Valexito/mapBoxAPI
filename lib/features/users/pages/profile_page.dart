import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/users/pages/configure_profile_page.dart';
import 'package:mapbox_api/features/users/pages/notifications_page.dart';
import 'package:mapbox_api/features/reservations/pages/reservations_page.dart';
import 'package:mapbox_api/features/owners/pages/become_owner_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  static const headerHeight = 240.0;
  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  static const pageBg = Color(0xFFF2F4F7);
  static const cardDivider = Color(0xFFE9EEFF);
  static const iconCircle = Color(0xFFEFF2F6);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final name =
        (user?.displayName?.trim().isNotEmpty ?? false)
            ? user!.displayName!.trim()
            : 'Tu nombre';

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Header
            Container(
              height: headerHeight,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [navyTop, navyBottom],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40, height: 32),
                        const MyText(
                          text: 'Profile',
                          variant: MyTextVariant.title,
                          customColor: Colors.white,
                        ),
                        SizedBox(
                          height: 30,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                                    color: navyBottom,
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
                    const Text(
                      'ID: 1234 567 975',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lista
            Positioned.fill(
              top: headerHeight - 34,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Material(
                      color: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.black12,
                      borderRadius: BorderRadius.circular(22),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 6,
                        ),
                        child: Column(
                          children: const [
                            _ActionItem(
                              icon: Icons.lock_outline,
                              title: 'Password',
                              go: _Go.configure,
                            ),
                            _Divider(),
                            _ActionItem(
                              icon: Icons.email_outlined,
                              title: 'Email Address',
                              go: _Go.configure,
                            ),
                            _Divider(),
                            _ActionItem(
                              icon: Icons.fingerprint_outlined,
                              title: 'Fingerprint',
                              go: _Go.none,
                            ),
                            _Divider(),
                            _ActionItem(
                              icon: Icons.support_agent_outlined,
                              title: 'Support',
                              go: _Go.notifications,
                            ),
                            _Divider(),
                            _ActionItem(
                              icon: Icons.logout_outlined,
                              title: 'Sign Out',
                              go: _Go.signout,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Material(
                      color: Colors.white,
                      elevation: 6,
                      shadowColor: Colors.black12,
                      borderRadius: BorderRadius.circular(22),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: const [
                            _Shortcut(
                              icon: Icons.bookmark_added_outlined,
                              title: 'My Reservations',
                              go: _Go.reservations,
                            ),
                            SizedBox(height: 8),
                            _Shortcut(
                              icon: Icons.badge_outlined,
                              title: 'Become Owner',
                              go: _Go.owner,
                            ),
                            SizedBox(height: 8),
                            _Shortcut(
                              icon: Icons.notifications_active_outlined,
                              title: 'Notifications',
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
    );
  }
}

/* --------------------------- widgets auxiliares --------------------------- */

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: ProfilePage.cardDivider);
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
        ).showSnackBar(const SnackBar(content: Text('Signed out')));
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
                color: ProfilePage.iconCircle,
                shape: BoxShape.circle,
              ),
              // 🔧 FIX: usar el icono recibido, no Icons.apps
              child: Icon(icon, size: 20, color: ProfilePage.navyBottom),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  color: ProfilePage.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: ProfilePage.textSecondary,
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
      color: ProfilePage.iconCircle,
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
                  color: ProfilePage.iconCircle,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: ProfilePage.navyBottom),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: ProfilePage.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ProfilePage.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
