import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        fontFamily: 'HoshikoSatsuki',
        fontSize: 24,
        letterSpacing: 2,
      ),
      
    );
  }
}