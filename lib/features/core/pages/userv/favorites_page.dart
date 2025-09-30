import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/common/utils/components/ui/navy_header.dart';
import 'package:mapbox_api/features/core/providers/favorites_provider.dart';
import 'package:mapbox_api/features/reservations/pages/reserve_space_page.dart';

// 👇 Para leer el rol actual y bloquear si es provider/admin
import 'package:mapbox_api/features/users/providers/user_providers.dart';
import 'package:mapbox_api/features/users/models/user_role.dart';
// 👇 HomeSwitch para redirigir al shell correcto si no es user
import 'package:mapbox_api/features/core/pages/home_switch.dart';

enum FavFilter { all, rating45, cheapest, spaces }

final favFilterProvider = StateProvider<FavFilter>((_) => FavFilter.all);

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  static const bg = Color(0xFFF2F4F7);
  static const navy = Color(0xFF1B3A57);

  List<FavoriteItem> _applyFilter(List<FavoriteItem> items, FavFilter f) {
    switch (f) {
      case FavFilter.rating45:
        return items.where((e) => e.rating >= 4.5).toList()
          ..sort((a, b) => b.rating.compareTo(a.rating));
      case FavFilter.cheapest:
        return [...items]..sort((a, b) => a.price.compareTo(b.price));
      case FavFilter.spaces:
        return items.where((e) => e.spaces > 0).toList();
      case FavFilter.all:
      default:
        return items;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ===== Guard de rol: esta pantalla es SOLO para role=user =====
    final roleAsync = ref.watch(myRoleStreamProvider);
    return roleAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error de rol: $e'))),
      data: (role) {
        if (role == UserRole.provider || role == UserRole.admin) {
          return _OnlyForUsers(
            onGoHome: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeSwitch()),
              );
            },
          );
        }

        // ===== Pantalla normal de favoritos (usuarios) =====
        final asyncFavs = ref.watch(favoritesStreamProvider);
        final filter = ref.watch(favFilterProvider);

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Column(
              children: [
                // Header navy + botón volver
                Stack(
                  children: [
                    const NavyHeader(
                      height: 150,
                      roundedBottom: false,
                      children: [
                        MyText(
                          text: 'FAVORITOS',
                          variant: MyTextVariant.title,
                          textAlign: TextAlign.center,
                          customColor: Colors.white,
                        ),
                      ],
                    ),
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

                // Filtros
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      elevation: 6,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _Chip(
                                label: 'Todos',
                                selected: filter == FavFilter.all,
                                onTap:
                                    () =>
                                        ref
                                            .read(favFilterProvider.notifier)
                                            .state = FavFilter.all,
                              ),
                              const SizedBox(width: 8),
                              _Chip(
                                label: 'Rating 4.5+',
                                selected: filter == FavFilter.rating45,
                                onTap:
                                    () =>
                                        ref
                                            .read(favFilterProvider.notifier)
                                            .state = FavFilter.rating45,
                              ),
                              const SizedBox(width: 8),
                              _Chip(
                                label: 'Más barato',
                                selected: filter == FavFilter.cheapest,
                                onTap:
                                    () =>
                                        ref
                                            .read(favFilterProvider.notifier)
                                            .state = FavFilter.cheapest,
                              ),
                              const SizedBox(width: 8),
                              _Chip(
                                label: 'Con espacios',
                                selected: filter == FavFilter.spaces,
                                onTap:
                                    () =>
                                        ref
                                            .read(favFilterProvider.notifier)
                                            .state = FavFilter.spaces,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Lista
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -16),
                    child: asyncFavs.when(
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (_, __) => const Center(
                            child: MyText(
                              text: 'Error loading favorites',
                              variant: MyTextVariant.body,
                            ),
                          ),
                      data: (all) {
                        final items = _applyFilter(all, filter);
                        if (items.isEmpty) {
                          return const Center(
                            child: MyText(
                              text: 'No tienes favoritos aún',
                              variant: MyTextVariant.bodyMuted,
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          itemCount: items.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => _FavoriteCard(item: items[i]),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnlyForUsers extends StatelessWidget {
  const _OnlyForUsers({required this.onGoHome});
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_person, size: 58, color: Colors.grey),
                const SizedBox(height: 12),
                const MyText(
                  text:
                      'Esta sección es solo para usuarios. '
                      'Tu cuenta es de propietario.',
                  variant: MyTextVariant.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onGoHome,
                  child: const Text('Ir a mi inicio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const navy = FavoritesPage.navy;
    final bg = selected ? navy : const Color(0xFFEFF2F6);
    final fg = selected ? Colors.white : navy;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: fg, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _FavoriteCard extends ConsumerWidget {
  final FavoriteItem item;
  const _FavoriteCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const navy = FavoritesPage.navy;
    final heroImg =
        item.heroImage ?? 'https://via.placeholder.com/800x450?text=Parking';

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        final parking = item.toParking();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReserveSpacePage(parking: parking)),
        );
      },
      child: Material(
        elevation: 4,
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // Imagen + heart
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      heroImg,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _ImageFallback(),
                      loadingBuilder:
                          (c, child, p) =>
                              p == null ? child : const _ImageShimmer(),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Consumer(
                    builder: (_, r, __) {
                      final favStream = r.watch(
                        isFavoriteStreamProvider(item.parkingId),
                      );
                      final isFav = favStream.maybeWhen(
                        data: (v) => v,
                        orElse: () => true,
                      );
                      return Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : navy,
                          ),
                          onPressed: () async {
                            try {
                              if (isFav) {
                                await r.read(removeFavoriteByDocIdProvider)(
                                  item.id,
                                );
                              } else {
                                await r.read(toggleFavoriteProvider)(
                                  toFav: true,
                                  p: item.toParking(),
                                );
                              }
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'No se pudo actualizar favorito',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyText(
                          text: item.name,
                          variant: MyTextVariant.bodyBold,
                          fontSize: 15,
                        ),
                      ),
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      MyText(
                        text: item.rating.toStringAsFixed(1),
                        variant: MyTextVariant.body,
                        fontSize: 13,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16, color: navy),
                      const SizedBox(width: 6),
                      MyText(
                        text: 'Q${item.price}',
                        variant: MyTextVariant.body,
                        fontSize: 13,
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.local_parking, size: 16, color: navy),
                      const SizedBox(width: 6),
                      MyText(
                        text: 'Spaces: ${item.spaces}',
                        variant: MyTextVariant.bodyMuted,
                        fontSize: 12,
                      ),
                    ],
                  ),
                  if ((item.descripcion ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    MyText(
                      text: item.descripcion!,
                      variant: MyTextVariant.bodyMuted,
                      fontSize: 12,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageShimmer extends StatelessWidget {
  const _ImageShimmer();
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFE9EDF3),
    alignment: Alignment.center,
    child: const SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFE7ECF3),
    alignment: Alignment.center,
    child: const Icon(Icons.image_not_supported, color: Colors.grey),
  );
}
