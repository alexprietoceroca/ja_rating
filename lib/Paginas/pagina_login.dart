import 'package:flutter/material.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/Login/boton_auth.dart';
import 'package:ja_rating/Components/Login/text_field_autentificacion.dart';
import 'package:ja_rating/Components/Login/texto_idiomas.dart';

class PaginaLogin extends StatefulWidget {
  const PaginaLogin({super.key});

  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Iniciando sesión...',
            style: TextStyle(color: Coloresapp.colorBlanco),
          ),
          backgroundColor: Coloresapp.colorPrimario,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloresapp.colorFondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo de la app - IMAGEN PNG
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Coloresapp.colorPrimario.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Coloresapp.colorPrimarioAccentuado,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/imagenes/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.restaurant_menu,
                            size: 70,
                            color: Coloresapp.colorPrimario,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Widget animado de bienvenida en múltiples idiomas
                  TextoIdiomas(
                    duracionAnimacion: const Duration(milliseconds: 800),
                    duracionPausa: const Duration(seconds: 2),
                    estiloBase: TextStyle(
                      color: Coloresapp.colorTexto,
                      shadows: [
                        Shadow(
                          color: Coloresapp.colorPrimarioAccentuado.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Campo de email
                  TextFieldAutentificacion(
                    controllerText: _emailController,
                    hintText: 'Correo electrónico',
                    focusNode: _emailFocus,
                    validator: _validateEmail,
                    esPassword: false, 
                    valorInicialOcultarEyeToggle: true,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Campo de contraseña
                  TextFieldAutentificacion(
                    controllerText: _passwordController,
                    hintText: 'Contraseña',
                    focusNode: _passwordFocus,
                    validator: _validatePassword,
                    esPassword: true, 
                    valorInicialOcultarEyeToggle: true,
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Enlace "¿Olvidaste tu contraseña?"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        print('Navegar a recuperar contraseña');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Coloresapp.colorPrimario,
                      ),
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Coloresapp.colorPrimario,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Botón de login
                  GestureDetector(
                    onTap: _handleLogin,
                    child: BotoAuth(textBoto: 'ENTRAR'),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Separador "o"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Coloresapp.colorContorno.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'O CONTINÚA CON',
                          style: TextStyle(
                            color: Coloresapp.colorTextoFlojo.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Coloresapp.colorContorno.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Botones sociales
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.g_mobiledata_rounded,
                        onTap: () => print('Login con Google'),
                      ),
                      const SizedBox(width: 20),
                      _buildSocialButton(
                        icon: Icons.facebook_rounded,
                        onTap: () => print('Login con Facebook'),
                      ),
                      const SizedBox(width: 20),
                      _buildSocialButton(
                        icon: Icons.apple_rounded,
                        onTap: () => print('Login con Apple'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Enlace de registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes una cuenta? ',
                        style: TextStyle(
                          color: Coloresapp.colorTextoFlojo,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          print('Navegar a registro');
                        },
                        child: Text(
                          'Regístrate',
                          style: TextStyle(
                            color: Coloresapp.colorPrimario,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                            decorationColor: Coloresapp.colorPrimarioAccentuado,
                            decorationThickness: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Coloresapp.colorBlanco,
          shape: BoxShape.circle,
          border: Border.all(
            color: Coloresapp.colorContorno.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Coloresapp.colorSombraCard,
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 35,
          color: Coloresapp.colorPrimario,
        ),
      ),
    );
  }
}