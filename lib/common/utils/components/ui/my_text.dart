import 'package:flutter/material.dart';
import 'app_styles.dart';

enum MyTextVariant { title, normal, normalBold, body, bodyBold, bodyMuted }

class MyText extends StatelessWidget {
  final String text;
  final MyTextVariant variant;
  final TextAlign? textAlign;
  final TextDecoration? decoration;
  final double? fontSize;
  final Color? customColor;

  const MyText({
    super.key,
    required this.text,
    this.variant = MyTextVariant.normal,
    this.textAlign,
    this.decoration,
    this.fontSize,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    // Paleta consistente con el Drawer
    const blue = Color.fromARGB(255, 13, 47, 80); // acento/enlaces
    const main = Color.fromARGB(255, 38, 63, 117); // textos principales
    const muted = Color.fromARGB(255, 55, 89, 156); // textos secundarios

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
          color: main,
          fontWeight: FontWeight.normal,
          fontSize: fontSize ?? 14,
        );
        break;
      case MyTextVariant.normalBold:
        style = TextStyle(
          color: main,
          fontWeight: FontWeight.bold,
          fontSize: fontSize ?? 14,
        );
        break;
      case MyTextVariant.body:
        style = TextStyle(
          color: main,
          fontWeight: FontWeight.w500,
          fontSize: fontSize ?? 15,
        );
        break;
      case MyTextVariant.bodyBold:
        style = TextStyle(
          color: main,
          fontWeight: FontWeight.w700,
          fontSize: fontSize ?? 15,
        );
        break;
      case MyTextVariant.bodyMuted:
        style = TextStyle(
          color: muted,
          fontWeight: FontWeight.w400,
          fontSize: fontSize ?? 13,
        );
        break;
    }

    return Text(
      variant == MyTextVariant.title ? text.toUpperCase() : text,
      textAlign: textAlign,
      style: style.copyWith(
        color: customColor ?? style.color,
        decoration: decoration ?? TextDecoration.none,
      ),
    );
  }
}
