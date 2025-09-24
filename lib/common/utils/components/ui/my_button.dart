import 'package:flutter/material.dart';
import 'app_styles.dart';

class MyButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;
  final bool loading;

  const MyButton({
    super.key,
    required this.onTap,
    this.text = "Iniciar sesión",
    this.loading = false,
  });

  bool get _enabled => onTap != null && !loading;

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child:
          loading
              ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
    );

    return Opacity(
      opacity: _enabled ? 1 : 0.6,
      child: IgnorePointer(
        ignoring: !_enabled,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(13),
            margin: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [AppColors.navyTop, AppColors.navyBottom],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
