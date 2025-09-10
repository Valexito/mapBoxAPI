import 'package:flutter/material.dart';

class HomeIcons extends StatelessWidget {
  final VoidCallback onOpenDrawer;
  final VoidCallback onOpenSettings;

  const HomeIcons({
    super.key,
    required this.onOpenDrawer,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 16),
          _FloatingIcon(icon: Icons.menu, onTap: onOpenDrawer),
          const Spacer(),
          _FloatingIcon(icon: Icons.settings, onTap: onOpenSettings),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FloatingIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}
