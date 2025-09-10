import 'package:flutter/material.dart';

class MyPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final EdgeInsetsGeometry? margin;

  // extras para formularios
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
  static const primary = Color(0xFF1976D2);
  static const navy = Color.fromARGB(255, 37, 119, 206);
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
    final color = _active ? navy : primary;

    final baseDecoration = InputDecoration(
      labelText: widget.labelText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      hintText: widget.hintText,
      hintStyle: TextStyle(color: Colors.grey[500]),
      prefixIcon: Icon(Icons.lock_outline, color: color),
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: color,
        ),
      ),
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

    final field = TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscure,
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
      cursorColor: color,
      decoration: baseDecoration,
    );

    final formField = TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscure,
      validator: widget.validator,
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
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
        child: widget.validator == null ? field : formField,
      ),
    );
  }
}
