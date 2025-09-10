// lib/components/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/reservations/pages/reservations_page.dart';
import 'package:mapbox_api/features/core/pages/favorites_page.dart';
import 'package:mapbox_api/features/users/pages/profile_page.dart';

// Providers de auth (Riverpod)
import 'package:mapbox_api/features/auth/providers/auth_providers.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  static const primary = Color(0xFF1976D2);
  static const navy = Color(0xFF0D1B2A);
  static const navyLight = Color(0xFF1B3A57);

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(authActionsProvider).signOut();
    if (!context.mounted) return;

    // Volvemos al entrypoint de auth. AuthGate decidirá qué mostrar.
    Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
  }

  // ---- Helper: mejor URL de foto (incluye providerData y upscaling de Google) ----
  String? _bestPhotoUrl(fb.User? u) {
    if (u == null) return null;
    String? url = u.photoURL;

    if (url == null || url.isEmpty) {
      for (final p in u.providerData) {
        if (p.photoURL != null && p.photoURL!.isNotEmpty) {
          url = p.photoURL;
          break;
        }
      }
    }
    if (url == null) return null;

    // Subir resolución típica de Google (s96- -> s200-)
    if (url.contains('googleusercontent.com') && url.contains('/s')) {
      url = url.replaceFirst(RegExp(r'/s\d+-'), '/s200-');
    }
    return url;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Leemos el usuario de forma reactiva con Riverpod
    final user = ref.watch(currentUserProvider);
    final photoUrl = _bestPhotoUrl(user);

    return Drawer(
      child: Column(
        children: [
          // ===== HEADER (gradiente) =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 48, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [navy, navyLight],
              ),
            ),
            child: Column(
              children: [
                // Avatar cuadrado redondeado con foto real
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child:
                        (photoUrl != null)
                            ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (c, e, s) => const Icon(
                                    Icons.person,
                                    size: 44,
                                    color: Colors.grey,
                                  ),
                            )
                            : const Icon(
                              Icons.person,
                              size: 44,
                              color: Colors.grey,
                            ),
                  ),
                ),
                const SizedBox(height: 12),
                MyText(
                  text: user?.displayName ?? 'Usuario',
                  variant: MyTextVariant.normalBold,
                  fontSize: 16,
                ),
                const SizedBox(height: 2),
                if (user?.email != null)
                  MyText(
                    text: user!.email!,
                    variant: MyTextVariant.bodyMuted,
                    fontSize: 12,
                  ),
              ],
            ),
          ),

          // ===== ITEMS (fondo blanco) =====
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 8),

                  _DrawerItem(
                    icon: Icons.bookmark,
                    label: 'Mis reservas',
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
                  _DrawerItem(
                    icon: Icons.favorite,
                    label: 'Favoritos',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FavoritesPage(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.person,
                    label: 'Perfil',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings,
                    label: 'Configuraciones',
                    onTap: () {
                      // TODO: ir a configuraciones
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.logout,
                    label: 'Cerrar sesión',
                    labelVariant: MyTextVariant.normalBold,
                    onTap: () => _signOut(context, ref),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ítem del Drawer con highlight al presionar (hold)
class _DrawerItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final MyTextVariant labelVariant;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelVariant = MyTextVariant.normal,
  });

  @override
  State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  static const primary = Color(0xFF1976D2);
  static const navy = Color(0xFF0D1B2A);
  static const navyLight = Color(0xFF1B3A57);

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final Color bg = _pressed ? navyLight : Colors.transparent;
    final Color ic = _pressed ? Colors.white : primary;

    // Texto: normal con MyText; cuando está presionado, lo pinto blanco
    final Widget title =
        _pressed
            ? Text(
              widget.label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight:
                    widget.labelVariant == MyTextVariant.normalBold
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            )
            : MyText(
              text: widget.label,
              variant: widget.labelVariant,
              fontSize: 16,
            );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(12),
          splashColor: navy.withOpacity(0.15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(widget.icon, color: ic),
                const SizedBox(width: 12),
                Expanded(child: title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
