import 'package:flutter/material.dart';
import 'package:ja_rating/Paginas/pagina_principal/pagina_principal.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/Login/boton_auth.dart';
import 'package:ja_rating/Components/Login/text_field_autentificacion.dart';
import 'package:ja_rating/Components/Login/texto_idiomas.dart';
import 'package:ja_rating/Paginas/pagina_login/pagina_registro.dart';
import 'package:ja_rating/Paginas/pagina_principal/pagina_principal.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  
  bool _isHovering = false;
  bool _isLoading = false;

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

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Iniciar sesión con Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '¡Inicio de sesión exitoso!',
                style: TextStyle(color: Coloresapp.colorBlanco),
              ),
              backgroundColor: Coloresapp.colorVerde,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 1),
            ),
          );
          
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PaginaPrincipal()),
              );
            }
          });
        }
      } on FirebaseAuthException catch (e) {
        String mensajeError;
        if (e.code == 'user-not-found') {
          mensajeError = 'No existe usuario con este email';
        } else if (e.code == 'wrong-password') {
          mensajeError = 'Contraseña incorrecta';
        } else if (e.code == 'invalid-email') {
          mensajeError = 'El email no es válido';
        } else if (e.code == 'user-disabled') {
          mensajeError = 'Este usuario ha sido deshabilitado';
        } else {
          mensajeError = 'Error al iniciar sesión: ${e.message}';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                mensajeError,
                style: TextStyle(color: Coloresapp.colorBlanco),
              ),
              backgroundColor: Coloresapp.colorRojoOscuro,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error inesperado: ${e.toString()}',
                style: TextStyle(color: Coloresapp.colorBlanco),
              ),
              backgroundColor: Coloresapp.colorRojoOscuro,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloresapp.colorFonsInici,
      body: Stack(
        children: [
          // Fondo negro sólido
          Container(
            color: Coloresapp.colorFonsInici,
          ),
          
          // Contenido principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Espacio donde estaba el logo
                      const SizedBox(height: 120),
                      
                      const SizedBox(height: 30),
                      
                      // Widget animado de bienvenida en múltiples idiomas - ROJO
                      TextoIdiomas(
                        duracionAnimacion: const Duration(milliseconds: 800),
                        duracionPausa: const Duration(seconds: 2),
                        estiloBase: TextStyle(
                          color: Coloresapp.colorRojoOscuro,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
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
                        enabled: !_isLoading,
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
                        enabled: !_isLoading,
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Enlace "¿Olvidaste tu contraseña?"
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading ? null : () {
                            print('Navegar a recuperar contraseña');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: _isLoading 
                                ? Coloresapp.colorTextoFlojo 
                                : Coloresapp.colorPrimario,
                          ),
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: _isLoading 
                                  ? Coloresapp.colorTextoFlojo 
                                  : Coloresapp.colorPrimario,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Botón de login con efecto hover y loading
                      MouseRegion(
                        onEnter: _isLoading ? null : (_) => setState(() => _isHovering = true),
                        onExit: _isLoading ? null : (_) => setState(() => _isHovering = false),
                        child: GestureDetector(
                          onTap: _isLoading ? null : _handleLogin,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: 55,
                            decoration: BoxDecoration(
                              color: _isLoading 
                                  ? Coloresapp.colorNaranja.withOpacity(0.5)
                                  : (_isHovering 
                                      ? Coloresapp.colorNaranja.withOpacity(0.9)
                                      : Coloresapp.colorNaranja),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: _isHovering && !_isLoading
                                  ? [
                                      BoxShadow(
                                        color: Coloresapp.colorNaranja.withOpacity(0.5),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      )
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Text(
                                      'ENTRAR',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
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
                            onTap: _isLoading ? null : () => print('Login con Google'),
                          ),
                          const SizedBox(width: 20),
                          _buildSocialButton(
                            icon: Icons.facebook_rounded,
                            onTap: _isLoading ? null : () => print('Login con Facebook'),
                          ),
                          const SizedBox(width: 20),
                          _buildSocialButton(
                            icon: Icons.apple_rounded,
                            onTap: _isLoading ? null : () => print('Login con Apple'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Enlace de registro - REDIRIGE A PAGINA_REGISTRO
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
                            onTap: _isLoading ? null : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PaginaRegistro()),
                              );
                            },
                            child: Text(
                              'Regístrate',
                              style: TextStyle(
                                color: _isLoading 
                                    ? Coloresapp.colorTextoFlojo 
                                    : Coloresapp.colorPrimario,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                                decorationColor: _isLoading 
                                    ? Coloresapp.colorTextoFlojo
                                    : Coloresapp.colorPrimarioAccentuado,
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
        ],
      ),
    );
  }

  Widget _buildSocialButton({required IconData icon, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Coloresapp.colorBlanco.withOpacity(onTap == null ? 0.3 : 1.0),
          shape: BoxShape.circle,
          border: Border.all(
            color: Coloresapp.colorContorno.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: onTap == null ? [] : [
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
          color: onTap == null 
              ? Coloresapp.colorTextoFlojo 
              : Coloresapp.colorPrimario,
        ),
      ),
    );
  }
}