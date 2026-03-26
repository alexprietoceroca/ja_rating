// texto_titulo.dart
import 'package:flutter/material.dart';
import 'package:ja_rating/coloresApp.dart';

class TextoTitulo extends StatelessWidget {
  final String contingutText;
  final Color? colorText;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? height;

  const TextoTitulo({
    super.key,
    required this.contingutText,
    this.colorText,
    this.fontSize,
    this.fontWeight,
    this.overflow,
    this.maxLines,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      contingutText,
      style: TextStyle(
        fontFamily: 'HoshikoSatsuki',
        fontSize: fontSize ?? 16,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: colorText ?? Coloresapp.colorTexto,
        height: height,
        letterSpacing: 1,
      ),
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}