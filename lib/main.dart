import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ja_rating/Paginas/pagina_principal/pagina_principal.dart';
import 'package:ja_rating/Paginas/pagina_login/pagina_login.dart';
import 'package:ja_rating/coloresapp.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return PaginaPrincipal();
        }
        return PaginaPrincipal();
      },
    );
  }
}