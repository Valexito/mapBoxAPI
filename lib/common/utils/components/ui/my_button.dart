import 'package:flutter/material.dart';
import 'app_styles.dart';

class MyButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final bool loading;
  final EdgeInsetsGeometry? margin;
  final double? height;

  const MyButton({
    super.key,
    required this.onTap,
    this.text = "Continue",
    this.loading = false,
    this.margin,
    this.height,
  });

  bool get _enabled => onTap != null && !loading;

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child:
          loading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
              : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
              ),
    );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Opacity(
        opacity: _enabled ? 1 : 0.65,
        child: IgnorePointer(
          ignoring: !_enabled,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: height ?? AppDims.buttonHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDims.radiusLg),
                gradient: const LinearGradient(
                  colors: [AppColors.headerTop, AppColors.headerBottom],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
