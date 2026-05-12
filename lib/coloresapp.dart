import 'package:flutter/material.dart';

class Coloresapp {
  // ==================== COLORES BASE DEL TEMA ====================
  static const Color colorFondo = Color.fromARGB(255, 242, 242, 242);
  static const Color colorPrimario = Color.fromARGB(255, 207, 75, 58);
  static const Color colorPrimarioAccentuado = Color.fromARGB(255, 225, 139, 129);
  static const Color colorTexto = Color.fromARGB(255, 51, 51, 51);
  static const Color colorTextoFlojo = Color.fromARGB(255, 102, 102, 102);
  static const Color colorTextoLigero = Color.fromARGB(255, 144, 144, 144);
  static const Color colorContorno = Color.fromARGB(255, 75, 75, 75);
  static const Color colorBlanco = Color.fromARGB(255, 255, 255, 255);
  static const Color colorNaranja = Color.fromARGB(255, 232, 150, 58);
  static const Color colorMorado = Color.fromARGB(255, 123, 108, 246);
  static const Color colorVerde = Color.fromARGB(255, 43, 168, 154);
  static const Color colorRojoOscuro = Color.fromARGB(255, 139, 26, 13);
  static const Color colorSombraCard = Color.fromARGB(18, 0, 0, 0);
  static const Color colorSombraNav = Color.fromARGB(20, 0, 0, 0);
  static const Color colorFonsInici = Color.fromARGB(255, 37, 37, 37);

  // ==================== COLORES PARA TEXTINPUTS (CONTRASTE MEJORADO) ====================
  static const Color colorInputFondo = Color(0xFF2D2D44);      // Fondo del input
  static const Color colorInputBorde = Color(0xFF3D3D5C);      // Borde del input
  static const Color colorInputTexto = Color(0xFFEEEEEE);      // Texto escrito
  static const Color colorInputHint = Color(0xFF888888);       // Hint text
  static const Color colorInputFoco = Color(0xFFE94560);       // Color al enfocar

  // ==================== COLORES PARA FONDOS Y ELEMENTOS ====================
  static const Color colorRosaClaro = Color.fromARGB(235, 248, 219, 219);
  static const Color colorGrisClaro = Color.fromARGB(255, 224, 224, 224);
  static const Color colorCasiNegro = Color(0xFF111111);
  static const Color colorLavanda = Color(0xFFE9D5FF);
  static const Color colorDurazno = Color(0xFFFED7AA);
  static const Color colorAzulClaro = Color(0xFFBAE6FD);
  static const Color colorOro = Color(0xFFD4AF37);
  
  // ==================== COLORES MATERIAL DESIGN ====================
  static const Color colorAzulMaterial = Color(0xFF1976D2);
  static const Color colorVerdeMaterial = Color(0xFF388E3C);
  static const Color colorAmarilloMaterial = Color(0xFFF57F17);
  static const Color colorNaranjaMaterial = Color(0xFFE65100);
  static const Color colorRojoMaterial = Color(0xFFC62828);
  static const Color colorGrisOscuro = Color(0xFF424242);
  static const Color colorPurpuraMaterial = Color(0xFF6A1B9A);
  static const Color colorCyanMaterial = Color(0xFF00838F);
  
  // ==================== OTROS COLORES ÚTILES ====================
  static const Color colorAzul = Color(0xFF2196F3);
  static const Color colorGris600 = Color(0xFF757575);
  static const Color colorFondoMapa = Color(0xFF2C3E50);
  static const Color colorArena = Color.fromARGB(255, 210, 180, 140);
  static const Color colorBlancoOpaco = Color.fromARGB(144, 255, 255, 255);
  static const Color colorBlancoTransparente = Colors.white54;
  
  // Colores con opacidad (se usan con .withOpacity() en el código)
  static Color get colorBlancoMuyOpaco => Colors.white.withOpacity(0.08);
}