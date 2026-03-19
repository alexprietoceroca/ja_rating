// main.dart
import 'package:flutter/material.dart';
import 'package:ja_rating/Paginas/pagina_principal/pagina_principal.dart';
import 'Paginas/Pagina_Login.dart';
import 'package:ja_rating/coloresapp.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JA Rating',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Coloresapp.colorPrimario,
        scaffoldBackgroundColor: Coloresapp.colorFondo,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Coloresapp.colorTexto),
          bodyMedium: TextStyle(color: Coloresapp.colorTextoFlojo),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      home: PaginaLogin(),
    );
  }
}