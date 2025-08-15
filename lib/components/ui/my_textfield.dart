import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final IconData? prefixIcon;
  final Widget? suffix;
  final EdgeInsetsGeometry? margin;
  final String? labelText;
  final String? helperText;
  final String? errorText; // si no usas Form/validator

  // Para usar con Form + TextFormField
  final String? Function(String?)? validator;

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
    this.suffix,
    this.margin,
    this.labelText,
    this.helperText,
    this.errorText,
    this.validator,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  static const primary = Color(0xFF1976D2);
  static const navy = Color.fromARGB(255, 37, 119, 206);

  final _focusNode = FocusNode();

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
    final color = _active ? navy : primary;

    final baseDecoration = InputDecoration(
      labelText: widget.labelText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      hintText: widget.hintText,
      hintStyle: TextStyle(color: Colors.grey[500]),
      prefixIcon:
          widget.prefixIcon == null
              ? null
              : Icon(widget.prefixIcon, color: color),
      suffixIcon: widget.suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: navy,
          width: 1.5,
        ), // contorno por defecto
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: navy, width: 1.8),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final textFieldWidget =
        widget.validator == null
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
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              cursorColor: color,
              decoration: baseDecoration,
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
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              cursorColor: color,
              decoration: baseDecoration,
            );

    return Padding(
      padding: widget.margin ?? const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              _active
                  ? [
                    BoxShadow(
                      color: navy.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                      blurStyle: BlurStyle.inner, // sombra interna
                    ),
                  ]
                  : [],
        ),
        child: textFieldWidget,
      ),
    );
  }
}
