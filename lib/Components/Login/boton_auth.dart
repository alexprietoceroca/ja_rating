import 'package:flutter/material.dart';
import 'package:ja_rating/coloresapp.dart'; // Cambia esto

class BotoAuth extends StatelessWidget {
  final String textBoto;
  
  const BotoAuth({super.key, required this.textBoto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Image.asset("assets/imatges/boto.png", fit: BoxFit.fill),
          Center(
            child: Text(
              textBoto,
              style: TextStyle(
                fontSize: 36,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
                color: Coloresapp.colorFondo, // Cambia esto
                shadows: [
                  Shadow(
                    color: Coloresapp.colorPrimarioAccentuado.withOpacity(0.6), // Cambia esto
                    blurRadius: 8,
                  )
                ]
              ),
            ),
          )
        ]
      ),
    );
  }
}