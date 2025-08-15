import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/modules/auth/services/auth_page.dart';
import 'package:mapbox_api/modules/core/pages/reservations_page.dart';
import 'package:mapbox_api/modules/core/pages/favorites_page.dart';
import 'package:mapbox_api/modules/core/pages/profile_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const primary = Color(0xFF1976D2);
  static const navy = Color(0xFF0D1B2A);
  static const navyLight = Color(0xFF1B3A57);

  Future<void> _signUserOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
                  child: const Icon(Icons.person, size: 44, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                MyText(
                  text: user?.displayName ?? 'Usuario',
                  variant: MyTextVariant.normalBold,
                  fontSize: 16,
                ),
                const SizedBox(height: 2),
                MyText(
                  text: user?.email ?? '',
                  variant: MyTextVariant.normal,
                  fontSize: 12,
                ),
              ],
            ),
          ),

          // ===== ITEMS (fondo blanco) =====
          Expanded(
            child: Container(
              color: Colors.white, // ← fondo blanco solo en la zona de opciones
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
                    onTap: () => _signUserOut(context),
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
