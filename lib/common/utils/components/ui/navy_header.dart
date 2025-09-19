import 'package:flutter/material.dart';

class NavyHeader extends StatelessWidget {
  const NavyHeader({
    super.key,
    required this.height,
    this.roundedBottom = false,
    this.leading,
    this.trailing,
    this.children = const <Widget>[],
  });

  final double height;
  final bool roundedBottom;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget> children;

  static const navyTop = Color(0xFF0D1B2A);
  static const navyBottom = Color(0xFF1B3A57);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [navyTop, navyBottom],
            ),
            borderRadius:
                roundedBottom
                    ? const BorderRadius.only(
                      bottomLeft: Radius.circular(26),
                      bottomRight: Radius.circular(26),
                    )
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // fila superior opcional (leading/trailing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    leading ?? const SizedBox(width: 40, height: 32),
                    const SizedBox(
                      width: 40,
                      height: 32,
                    ), // spacer para centrar
                    trailing ?? const SizedBox(width: 40, height: 32),
                  ],
                ),
                const SizedBox(height: 8),
                ...children,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
