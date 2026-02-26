import 'package:flutter/material.dart';
import 'package:ja_rating/coloresApp.dart';

class TextoNormal extends StatelessWidget {
  final String contingutText;
  final Color colorText;
  const TextoNormal({
    super.key,
    required this.contingutText,
    this.colorText = Coloresapp.colorTexto,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      contingutText,
      style: TextStyle(
        fontSize: 24,
        color: colorText,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}