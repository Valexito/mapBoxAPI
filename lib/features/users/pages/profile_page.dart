// lib/features/users/pages/profile_page.dart
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const headerHeight = 260.0;
    const navyTop = Color(0xFF0D1B2A);
    const navyBottom = Color(0xFF1B3A57);

    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final name = user?.displayName?.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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

              // Aquí tu lista de acciones (Mis Reservas, Become Owner, Notifications, etc.)
              // Mantén tu mismo layout actual.
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.bookmark_added_outlined),
                      title: const Text('My Reservations'),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReservationsPage(),
                            ),
                          ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Become Owner'),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BecomeOwnerPage(),
                            ),
                          ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications_active_outlined),
                      title: const Text('Notifications'),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsPage(),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
