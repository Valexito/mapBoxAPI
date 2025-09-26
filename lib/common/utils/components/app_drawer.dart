import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/reservations/pages/reservations_page.dart';
import 'package:mapbox_api/features/core/pages/favorites_page.dart';
import 'package:mapbox_api/features/users/pages/profile_page.dart';

// 👇 Importa el stream del usuario y las acciones de auth
import 'package:mapbox_api/features/auth/providers/auth_providers.dart'
    show authUserStreamProvider, authActionsProvider;

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    // cierra el drawer para evitar que quede montado con datos viejos
    Navigator.of(context).pop();
    await ref.read(authActionsProvider).signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/auth', (_) => false);
  }

  String? _bestPhotoUrl(fb.User? u) {
    if (u == null) return null;
    String? url = u.photoURL;

    // Si no hay en user principal, intenta con los proveedores vinculados
    if (url == null || url.isEmpty) {
      for (final p in u.providerData) {
        final pUrl = p.photoURL;
        if (pUrl != null && pUrl.isNotEmpty) {
          url = pUrl;
          break;
        }
      }
    }
    if (url == null) return null;

    // Mejora tamaño típico de Google
    if (url.contains('googleusercontent.com') && url.contains('/s')) {
      url = url.replaceFirst(RegExp(r'/s\d+-'), '/s200-');
    }
    return url;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔴 AHORA escuchamos el stream del usuario
    final userAsync = ref.watch(authUserStreamProvider);

    return userAsync.when(
      loading:
          () => const Drawer(child: Center(child: CircularProgressIndicator())),
      error:
          (e, _) => Drawer(child: Center(child: Text('Error de sesión: $e'))),
      data: (user) {
        final photoUrl = _bestPhotoUrl(user);

        return Drawer(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 54, bottom: 22),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.navyTop, AppColors.navyBottom],
                  ),
                ),
                child: Column(
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
                            (photoUrl != null)
                                // clave atada al uid -> fuerza recarga al cambiar de usuario
                                ? Image.network(
                                  photoUrl,
                                  key: ValueKey(user?.uid),
                                  fit: BoxFit.cover,
                                )
                                : const Icon(
                                  Icons.person,
                                  size: 54,
                                  color: Colors.white70,
                                ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    MyText(
                      text:
                          (user?.displayName?.trim().isNotEmpty ?? false)
                              ? user!.displayName!.trim().toUpperCase()
                              : 'TU NOMBRE',
                      variant: MyTextVariant.title,
                      customColor: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    if (user?.email != null)
                      MyText(
                        text: user!.email!,
                        variant: MyTextVariant.bodyMuted,
                        fontSize: 12,
                        customColor: Colors.white70,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 8),
                    _DrawerItem(
                      icon: Icons.bookmark_added_outlined,
                      label: 'Mis reservaciones',
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
                      icon: Icons.favorite_outline,
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
                      icon: Icons.person_outline,
                      label: 'Perfil',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfilePage(),
                          ),
                        );
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      label: 'Configuraciones',
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 8),
                    _DrawerItem(
                      icon: Icons.logout_outlined,
                      label: 'Cerrar sesión',
                      bold: true,
                      danger: true,
                      onTap: () => _signOut(context, ref),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DrawerItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool bold;
  final bool danger;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.bold = false,
    this.danger = false,
  });

  @override
  State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final Color bg = _pressed ? AppColors.navyBottom : Colors.transparent;
    final isDanger = widget.danger;

    final Color textColor =
        _pressed
            ? Colors.white
            : (isDanger ? Colors.red[700]! : AppColors.textPrimary);
    final Color iconColor =
        _pressed
            ? Colors.white
            : (isDanger ? Colors.red[700]! : AppColors.navyBottom);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.navyTop.withOpacity(0.12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _pressed ? Colors.white24 : AppColors.iconCircle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight:
                          widget.bold ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _pressed ? Colors.white70 : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
