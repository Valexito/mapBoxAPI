import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_styles.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  // Comportamiento
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  // Decoración
  final IconData? prefixIcon; // opcional (omítelo en Login/SignUp)
  final bool circularPrefix;
  final Widget? suffix;
  final EdgeInsetsGeometry? margin;
  final String? labelText;
  final String? helperText;
  final String? errorText;

  // Form
  final String? Function(String?)? validator;

  // Focus externo
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.circularPrefix = false,
    this.suffix,
    this.margin,
    this.labelText,
    this.helperText,
    this.errorText,
    this.validator,
    this.focusNode,
    this.onFocusChange,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late final FocusNode _focusNode;
  bool _ownsFocus = false;

  bool get _active =>
      _focusNode.hasFocus || widget.controller.text.trim().isNotEmpty;

  void _onFocus() {
    setState(() {});
    widget.onFocusChange?.call(_focusNode.hasFocus);
  }

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocus = widget.focusNode == null;
    _focusNode.addListener(_onFocus);
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus);
    if (_ownsFocus) _focusNode.dispose();
    super.dispose();
  }

  Widget? _buildPrefix() {
    if (widget.prefixIcon == null) return null;
    final Color color = _active ? AppColors.navyBottom : AppColors.primary;

    if (!widget.circularPrefix) {
      return Padding(
        padding: const EdgeInsetsDirectional.only(start: 8.0, end: 4.0),
        child: Icon(widget.prefixIcon, color: color),
      );
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8.0, end: 6.0),
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.iconCircle,
          shape: BoxShape.circle,
        ),
        child: Icon(widget.prefixIcon, size: 16, color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).inputDecorationTheme;

    // Texto como Drawer: fuerte al enfocar, más suave al salir
    final textStyle = TextStyle(
      color: _active ? AppColors.textPrimary : AppColors.textSecondary,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );

    // Usamos InputBorder.none para asegurarnos de que NO salga la línea negra
    final decoration = const InputDecoration(border: InputBorder.none)
        .applyDefaults(theme)
        .copyWith(
          labelText: widget.labelText,
          helperText: widget.helperText,
          errorText: widget.errorText,
          hintText: widget.hintText,
          filled: true,
          fillColor: _active ? Colors.white : AppColors.formFieldBg,
          prefixIcon: _buildPrefix(),
          suffixIcon: widget.suffix,
          // padding un poco mayor para que se vean más "anchos/altos"
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16, // ↑
            horizontal: 18, // ↑
          ),
        );

    final field =
        (widget.validator == null)
            ? TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onTap: widget.onTap,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              readOnly: widget.readOnly,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              style: textStyle,
              cursorColor: AppColors.navyBottom,
              decoration: decoration,
            )
            : TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              onTap: widget.onTap,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              readOnly: widget.readOnly,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              validator: widget.validator,
              style: textStyle,
              cursorColor: AppColors.navyBottom,
              decoration: decoration,
            );

    // Contenedor que da el "borde-sombra" azul al enfocar (glow)
    return Padding(
      padding: widget.margin ?? const EdgeInsets.symmetric(horizontal: 25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDims.radiusLg),
          // “glow” + fino borde en navy al enfocar
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
