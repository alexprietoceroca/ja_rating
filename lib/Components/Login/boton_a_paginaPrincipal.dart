import 'package:flutter/material.dart';
import 'package:ja_rating/coloresApp.dart';

class BotonAPaginaprincipal extends StatelessWidget {
  final String textBoto;
  final Function()? accioBoto;
  const BotonAPaginaprincipal({
    super.key,
    required this.textBoto,
    required this.accioBoto,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: accioBoto,
      child: Container(
        width: 300,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            Center(
              child: Text(
                textBoto,
                style: TextStyle(
                  fontSize: 36,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                  color: Coloresapp.colorPrimario,
                  shadows: [
                    Shadow(
                      color: Coloresapp.colorPrimarioAccentuado,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
