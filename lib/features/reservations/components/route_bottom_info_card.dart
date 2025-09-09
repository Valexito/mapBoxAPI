import 'package:flutter/material.dart';
import 'package:mapbox_api/components/ui/my_text.dart';
import 'package:mapbox_api/components/ui/my_button.dart';

class RouteBottomInfoCard extends StatelessWidget {
  final String parkingName;
  final String distance;
  final String duration;
  final VoidCallback onNavigate;
  final VoidCallback onCancelLater;

  const RouteBottomInfoCard({
    super.key,
    required this.parkingName,
    required this.distance,
    required this.duration,
    required this.onNavigate,
    required this.onCancelLater,
  });

  static const _navyLight = Color(0xFF1B3A57);

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).viewPadding.bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomSafe),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            MyText(
              text: parkingName,
              fontSize: 18,
              variant: MyTextVariant.title,
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                _InfoChip(icon: Icons.directions_walk, label: 'Distancia'),
                SizedBox(width: 10),
                _InfoChip(icon: Icons.timer_outlined, label: 'Tiempo'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: MyText(
                    text: distance,
                    variant: MyTextVariant.bodyBold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MyText(
                    text: duration,
                    variant: MyTextVariant.bodyBold,
                    fontSize: 14,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: MyButton(text: 'Navegar', onTap: onNavigate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: onCancelLater,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _navyLight, width: 1.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const MyText(
                        text: 'Más tarde',
                        variant: MyTextVariant.normalBold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: const Color(0xFF1B3A57), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MyText(
                text: label,
                variant: MyTextVariant.body,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
