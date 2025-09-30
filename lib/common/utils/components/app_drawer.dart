import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:mapbox_api/common/utils/components/ui/app_styles.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';

// Páginas
import 'package:mapbox_api/features/core/pages/userv/configurations_page.dart';
import 'package:mapbox_api/features/core/pages/userv/frequent_questions_page.dart';
import 'package:mapbox_api/features/core/pages/userv/legal_information_page.dart';
import 'package:mapbox_api/features/core/pages/userv/report_problem_page.dart';
import 'package:mapbox_api/features/reservations/pages/reservations_page.dart';
import 'package:mapbox_api/features/core/pages/userv/favorites_page.dart';
import 'package:mapbox_api/features/users/pages/profile_page.dart';

// Auth
import 'package:mapbox_api/features/auth/providers/auth_providers.dart'
    show authUserStreamProvider, authActionsProvider;

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  // Navega y reabre el drawer al volver
  Future<void> _openFromDrawer(BuildContext context, Widget page) async {
    // Captura el Scaffold antes de cerrar el drawer
    final scaffoldState = Scaffold.maybeOf(context);

    // Cierra el drawer
    Navigator.of(context).pop();

    // Navega a la página
    await Navigator.of(
      scaffoldState!.context,
    ).push(MaterialPageRoute(builder: (_) => page));

    // Cuando el usuario vuelve, reabre el drawer
    if (scaffoldState.mounted) {
      scaffoldState.openDrawer();
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop(); // cierra el drawer
    await ref.read(authActionsProvider).signOut();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/auth', (_) => false);
  }

  String? _bestPhotoUrl(fb.User? u) {
    if (u == null) return null;
    String? url = u.photoURL;

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

    if (url.contains('googleusercontent.com') && url.contains('/s')) {
      url = url.replaceFirst(RegExp(r'/s\d+-'), '/s200-');
    }
    return url;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      onTap:
                          () => _openFromDrawer(
                            context,
                            const ReservationsPage(),
                          ),
                    ),
                    _DrawerItem(
                      icon: Icons.favorite_outline,
                      label: 'Favoritos',
                      onTap:
                          () => _openFromDrawer(context, const FavoritesPage()),
                    ),
                    _DrawerItem(
                      icon: Icons.person_outline,
                      label: 'Perfil',
                      onTap:
                          () => _openFromDrawer(context, const ProfilePage()),
                    ),
                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      label: 'Configuraciones',
                      onTap:
                          () => _openFromDrawer(
                            context,
                            const ConfigurationsPage(),
                          ),
                    ),
                    const SizedBox(height: 8),
                    _DrawerItem(
                      icon: Icons.help_outline,
                      label: 'Preguntas frecuentes',
                      onTap:
                          () => _openFromDrawer(
                            context,
                            const FrequentQuestionsPage(),
                          ),
                    ),
                    const SizedBox(height: 8),
                    _DrawerItem(
                      icon: Icons.gavel_outlined,
                      label: 'Información legal',
                      onTap:
                          () => _openFromDrawer(
                            context,
                            const LegalInformationPage(),
                          ),
                    ),
                    const SizedBox(height: 8),
                    _DrawerItem(
                      icon: Icons.report_gmailerrorred_outlined,
                      label: 'Reportar un problema',
                      onTap:
                          () => _openFromDrawer(
                            context,
                            const ReportProblemPage(),
                          ),
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
