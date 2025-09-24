import 'package:flutter/material.dart';
import 'app_styles.dart';

class MyPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final EdgeInsetsGeometry? margin;

  final String? labelText;
  final String? helperText;
  final String? errorText;
  final String? Function(String?)? validator;

  const MyPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    this.margin,
    this.labelText,
    this.helperText,
    this.errorText,
    this.validator,
  });

  @override
  State<MyPasswordField> createState() => _MyPasswordFieldState();
}

class _MyPasswordFieldState extends State<MyPasswordField> {
  final _focusNode = FocusNode();
  bool _obscure = true;

  bool get _active =>
      _focusNode.hasFocus || widget.controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).inputDecorationTheme;

    final textStyle = TextStyle(
      color: _active ? AppColors.textPrimary : AppColors.textSecondary,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );

    final decoration = const InputDecoration(border: InputBorder.none)
        .applyDefaults(theme)
        .copyWith(
          labelText: widget.labelText,
          helperText: widget.helperText,
          errorText: widget.errorText,
          hintText: widget.hintText,
          filled: true,
          fillColor: _active ? Colors.white : AppColors.formFieldBg,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16, // ↑
            horizontal: 18, // ↑
          ),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(
              _obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.navyBottom,
            ),
          ),
        );

    final field =
        (widget.validator == null)
            ? TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: _obscure,
              style: textStyle,
              cursorColor: AppColors.navyBottom,
              decoration: decoration,
            )
            : TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: _obscure,
              validator: widget.validator,
              style: textStyle,
              cursorColor: AppColors.navyBottom,
              decoration: decoration,
            );

    return Padding(
      padding: widget.margin ?? const EdgeInsets.symmetric(horizontal: 25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDims.radiusLg),
          border:
              _active
                  ? Border.all(
                    color: AppColors.navyBottom.withOpacity(0.45),
                    width: 1,
                  )
                  : null,
          boxShadow:
              _active
                  ? [
                    BoxShadow(
                      color: AppColors.navyBottom.withOpacity(0.28),
                      blurRadius: 20,
                      spreadRadius: 0.5,
                      offset: const Offset(0, 6),
                    ),
                  ]
                  : [],
        ),
        child: field,
      ),
    );
  }
}
