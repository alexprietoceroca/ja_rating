// pagina_login.dart
import 'package:flutter/material.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/Login/boton_auth.dart';
import 'package:ja_rating/Components/Login/text_field_autentificacion.dart';

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
      // Aquí iría la lógica de autenticación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Iniciando sesión...',
            style: TextStyle(color: ColorsApp.colorAcompanyamientoIntenso),
          ),
          backgroundColor: ColorsApp.colorPrimariIntenso,
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
      backgroundColor: ColorsApp.colorAcompanyamientoIntenso,
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
                  // Logo o icono de la app
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: ColorsApp.colorPrimariIntenso.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorsApp.colorSecundarioIntenso,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 70,
                      color: ColorsApp.colorPrimariIntenso,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Título de la app
                  Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: ColorsApp.colorPrimari,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: ColorsApp.colorSecundarioIntenso.withOpacity(0.4),
                          blurRadius: 10,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Subtítulo
                  Text(
                    'Inicia sesión para continuar',
                    style: TextStyle(
                      fontSize: 18,
                      color: ColorsApp.colorSecundario,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Campo de email
                  TextFieldAutentificacion(
                    controllerText: _emailController,
                    hintText: 'Correo electrónico',
                    focusNode: _emailFocus,
                    validator: _validateEmail,
                    esPassword: false,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Campo de contraseña
                  TextFieldAutentificacion(
                    controllerText: _passwordController,
                    hintText: 'Contraseña',
                    focusNode: _passwordFocus,
                    validator: _validatePassword,
                    esPassword: true,
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Enlace "¿Olvidaste tu contraseña?"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Aquí iría la navegación a recuperar contraseña
                        print('Navegar a recuperar contraseña');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: ColorsApp.colorPrimariIntenso,
                      ),
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: ColorsApp.colorPrimariIntenso,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Botón de login personalizado (con tu widget BotoAuth)
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
                          color: ColorsApp.colorPrimari.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'O CONTINÚA CON',
                          style: TextStyle(
                            color: ColorsApp.colorSecundario.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: ColorsApp.colorPrimari.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Opciones de login social
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
                  
                  // Enlace para registrarse
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes una cuenta? ',
                        style: TextStyle(
                          color: ColorsApp.colorSecundario,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Aquí iría la navegación a registro
                          print('Navegar a registro');
                        },
                        child: Text(
                          'Regístrate',
                          style: TextStyle(
                            color: ColorsApp.colorPrimariIntenso,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                            decorationColor: ColorsApp.colorSecundarioIntenso,
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

  // Widget auxiliar para botones sociales
  Widget _buildSocialButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: ColorsApp.colorAcompanyamientoIntenso,
          shape: BoxShape.circle,
          border: Border.all(
            color: ColorsApp.colorPrimari.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ColorsApp.colorSecundarioIntenso.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 35,
          color: ColorsApp.colorPrimariIntenso,
        ),
      ),
    );
  }
}