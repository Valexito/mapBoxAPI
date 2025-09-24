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
    return Stack(
      children: [
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.navyTop, AppColors.navyBottom],
            ),
            borderRadius:
                roundedBottom
                    ? const BorderRadius.only(
                      bottomLeft: Radius.circular(AppDims.radiusLg),
                      bottomRight: Radius.circular(AppDims.radiusLg),
                    )
                    : null,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
