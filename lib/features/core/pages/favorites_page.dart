// features/core/pages/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/reservations/pages/reserve_space_page.dart';
import '../providers/favorites_provider.dart';

enum FavFilter { all, rating45, cheapest, spaces }

final favFilterProvider = StateProvider<FavFilter>((_) => FavFilter.all);

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

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
    const headerH = 140.0;
    final asyncFavs = ref.watch(favoritesStreamProvider);
    final filter = ref.watch(favFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            SizedBox(
              height: headerH,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [navyTop, navyBottom],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 4,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Center(
                    child: MyText(
                      text: 'FAVORITES',
                      variant: MyTextVariant.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // ===== FILTER CHIPS =====
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
                            label: 'All',
                            selected: filter == FavFilter.all,
                            onTap:
                                () =>
                                    ref.read(favFilterProvider.notifier).state =
                                        FavFilter.all,
                          ),
                          const SizedBox(width: 8),
                          _Chip(
                            label: 'Rating 4.5+',
                            selected: filter == FavFilter.rating45,
                            onTap:
                                () =>
                                    ref.read(favFilterProvider.notifier).state =
                                        FavFilter.rating45,
                          ),
                          const SizedBox(width: 8),
                          _Chip(
                            label: 'Cheapest',
                            selected: filter == FavFilter.cheapest,
                            onTap:
                                () =>
                                    ref.read(favFilterProvider.notifier).state =
                                        FavFilter.cheapest,
                          ),
                          const SizedBox(width: 8),
                          _Chip(
                            label: 'With spaces',
                            selected: filter == FavFilter.spaces,
                            onTap:
                                () =>
                                    ref.read(favFilterProvider.notifier).state =
                                        FavFilter.spaces,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ===== LIST =====
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -16),
                child: asyncFavs.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
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
                          text: 'No favorites yet',
                          variant: MyTextVariant.bodyMuted,
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
    const navy = Color(0xFF1B3A57);
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

class _FavoriteCard extends ConsumerStatefulWidget {
  final FavoriteItem item;
  const _FavoriteCard({required this.item});

  @override
  ConsumerState<_FavoriteCard> createState() => _FavoriteCardState();
}

class _FavoriteCardState extends ConsumerState<_FavoriteCard> {
  bool _fav = true;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF1B3A57);
    final heroImg =
        widget.item.heroImage ??
        'https://via.placeholder.com/800x450?text=Parking';

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        final parking = widget.item.toParking();
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
                      errorBuilder:
                          (_, __, ___) => Container(
                            color: const Color(0xFFE7ECF3),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                      loadingBuilder:
                          (c, child, p) =>
                              p == null ? child : const _ImageShimmer(),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      icon: Icon(
                        _fav ? Icons.favorite : Icons.favorite_border,
                        color: _fav ? Colors.red : navy,
                      ),
                      onPressed: () async {
                        setState(() => _fav = !_fav);
                        try {
                          if (!_fav) {
                            await ref.read(removeFavoriteByDocIdProvider)(
                              widget.item.id,
                            );
                          }
                        } catch (_) {
                          setState(() => _fav = !_fav);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No se pudo actualizar favorito'),
                              ),
                            );
                          }
                        }
                      },
                    ),
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
                          text: widget.item.name,
                          variant: MyTextVariant.bodyBold,
                          fontSize: 15,
                        ),
                      ),
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      MyText(
                        text: widget.item.rating.toStringAsFixed(1),
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
                        text: 'Q${widget.item.price}',
                        variant: MyTextVariant.body,
                        fontSize: 13,
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.local_parking, size: 16, color: navy),
                      const SizedBox(width: 6),
                      MyText(
                        text: 'Spaces: ${widget.item.spaces}',
                        variant: MyTextVariant.bodyMuted,
                        fontSize: 12,
                      ),
                    ],
                  ),
                  if ((widget.item.descripcion ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    MyText(
                      text: widget.item.descripcion!,
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
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE9EDF3),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
