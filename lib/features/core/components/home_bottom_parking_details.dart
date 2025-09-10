import 'package:flutter/material.dart';
import 'package:mapbox_api/common/utils/components/ui/my_button.dart';
import 'package:mapbox_api/common/utils/components/ui/my_text.dart';
import 'package:mapbox_api/features/reservations/models/parking.dart';
import 'package:mapbox_api/features/reservations/pages/reserve_space_page.dart';

class HomeParkingDetailBottomSheet extends StatefulWidget {
  final Parking parking;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const HomeParkingDetailBottomSheet({
    super.key,
    required this.parking,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  @override
  State<HomeParkingDetailBottomSheet> createState() =>
      _HomeParkingDetailBottomSheetState();
}

class _HomeParkingDetailBottomSheetState
    extends State<HomeParkingDetailBottomSheet> {
  static const navyBottom = Color(0xFF1B3A57);

  late final PageController _pager;
  int _page = 0;

  // Galería a mostrar (1) photos[] (2) coverUrl (3) imageUrl (4) placeholder
  List<String> get _gallery {
    final g = <String>[];
    if (widget.parking.photos.isNotEmpty) g.addAll(widget.parking.photos);

    final cover = widget.parking.coverUrl ?? widget.parking.imageUrl;
    if (g.isEmpty && (cover ?? '').isNotEmpty) g.add(cover!);

    // Como backup final, un placeholder visible
    if (g.isEmpty) {
      g.add('https://via.placeholder.com/800x400?text=Parking');
    }
    return g;
  }

  @override
  void initState() {
    super.initState();
    _pager = PageController();
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  String _money(num v) => 'Q${v.toStringAsFixed(v % 1 == 0 ? 0 : 2)}';

  @override
  Widget build(BuildContext context) {
    final gallery = _gallery;
    final hasMultiple = gallery.length > 1;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: Material(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== Carrusel =====
            SizedBox(
              width: double.infinity,
              height: 220,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pager,
                    itemCount: gallery.length,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemBuilder: (_, i) {
                      final url = gallery[i];
                      // Si preferías assets locales, podrías chequear localImagePath aquí.
                      return Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        // Evita feo crash cuando el emulador no resuelve host
                        errorBuilder: (_, __, ___) => const _ImageFallback(),
                        loadingBuilder: (c, child, progress) {
                          if (progress == null) return child;
                          return const _ImageShimmer();
                        },
                      );
                    },
                  ),

                  // Oscurecer abajo para legibilidad
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black26],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Acciones (fav / cerrar)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                      children: [
                        _RoundIcon(
                          icon:
                              widget.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                          color:
                              widget.isFavorite ? navyBottom : Colors.black38,
                          onTap: widget.onToggleFavorite ?? () {},
                        ),
                        const SizedBox(width: 8),
                        _RoundIcon(
                          icon: Icons.close,
                          color: navyBottom,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Dots del carrusel
                  if (hasMultiple)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          gallery.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 7,
                            width: _page == i ? 18 : 7,
                            decoration: BoxDecoration(
                              color: _page == i ? Colors.white : Colors.white70,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ===== Contenido =====
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: 'Parqueo en ${widget.parking.name}',
                    variant: MyTextVariant.title,
                    fontSize: 18,
                  ),
                  const SizedBox(height: 6),
                  if ((widget.parking.descripcion ?? '').isNotEmpty)
                    MyText(
                      text: widget.parking.descripcion!,
                      variant: MyTextVariant.body,
                      fontSize: 14,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      MyText(
                        text: '${_money(widget.parking.price)} por noche',
                        variant: MyTextVariant.bodyBold,
                        fontSize: 16,
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star,
                        size: 18,
                        color: Color(0xFFFBBF24),
                      ),
                      const SizedBox(width: 4),
                      MyText(
                        text: (widget.parking.rating ?? 4.8).toStringAsFixed(2),
                        variant: MyTextVariant.body,
                        fontSize: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MyText(
                    text: 'Espacios disponibles: ${widget.parking.spaces}',
                    variant: MyTextVariant.body,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  MyButton(
                    text: 'Reservar espacio',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ReserveSpacePage(parking: widget.parking),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoundIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

/// Placeholder mientras carga
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

/// Placeholder de error de red / URL
class _ImageFallback extends StatelessWidget {
  const _ImageFallback();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE9EDF3),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}
