import 'package:flutter/material.dart';
import 'app_styles.dart';

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.headerTop, AppColors.headerBottom],
              ),
              borderRadius:
                  roundedBottom
                      ? const BorderRadius.only(
                        bottomLeft: Radius.circular(AppDims.radiusXl),
                        bottomRight: Radius.circular(AppDims.radiusXl),
                      )
                      : null,
            ),
          ),
          Positioned(
            top: -40,
            right: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: -30,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      leading ?? const SizedBox(width: 40, height: 32),
                      const SizedBox(width: 40, height: 32),
                      trailing ?? const SizedBox(width: 40, height: 32),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...children,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
