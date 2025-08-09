import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final TextAlign? textAlign;
  final TextDecoration? decoration;

  const MyText({
    super.key,
    required this.text,
    this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color ?? const Color(0xFF1976D2), // Azul predeterminado
        fontWeight: fontWeight ?? FontWeight.normal,
        fontSize: fontSize ?? 14,
        decoration: decoration ?? TextDecoration.none,
      ),
    );
  }
}
