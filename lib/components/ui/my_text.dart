import 'package:flutter/material.dart';

enum MyTextVariant {
  title, // Uppercase + bold (azul)
  normal, // Azul normal
  normalBold, // Azul bold
  body, // Negro normal (para contenido/listas)
  bodyBold, // Negro bold
  bodyMuted, // Negro atenuado (subtitle, hint)
}

class MyText extends StatelessWidget {
  final String text;
  final MyTextVariant variant;
  final TextAlign? textAlign;
  final TextDecoration? decoration;
  final double? fontSize; // permite ajustar tamaño puntual

  const MyText({
    super.key,
    required this.text,
    this.variant = MyTextVariant.normal,
    this.textAlign,
    this.decoration,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    // Paleta base
    const Color blue = Color(0xFF1976D2);
    const Color black = Colors.black;
    final Color blackMuted = Colors.black54;

    TextStyle style;

    switch (variant) {
      case MyTextVariant.title:
        style = TextStyle(
          color: blue,
          fontWeight: FontWeight.bold,
          fontSize: fontSize ?? 18,
          letterSpacing: 1.2,
        );
        break;

      case MyTextVariant.normal:
        style = TextStyle(
          color: blue,
          fontWeight: FontWeight.normal,
          fontSize: fontSize ?? 14,
        );
        break;

      case MyTextVariant.normalBold:
        style = TextStyle(
          color: blue,
          fontWeight: FontWeight.bold,
          fontSize: fontSize ?? 14,
        );
        break;

      case MyTextVariant.body:
        style = TextStyle(
          color: black,
          fontWeight: FontWeight.w500,
          fontSize: fontSize ?? 15,
        );
        break;

      case MyTextVariant.bodyBold:
        style = TextStyle(
          color: black,
          fontWeight: FontWeight.w700,
          fontSize: fontSize ?? 15,
        );
        break;

      case MyTextVariant.bodyMuted:
        style = TextStyle(
          color: blackMuted,
          fontWeight: FontWeight.w400,
          fontSize: fontSize ?? 13,
        );
        break;
    }

    return Text(
      variant == MyTextVariant.title ? text.toUpperCase() : text,
      textAlign: textAlign,
      style: style.copyWith(decoration: decoration ?? TextDecoration.none),
    );
  }
}
