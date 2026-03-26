import 'package:flutter/material.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/Login/boton_auth.dart';
import 'package:ja_rating/Components/Login/text_field_autentificacion.dart';
import 'package:ja_rating/Components/Login/texto_idiomas.dart';
import 'package:ja_rating/Paginas/pagina_login/pagina_login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaginaRegistro extends StatefulWidget {
  const PaginaRegistro({super.key});

  @override
  State<PaginaRegistro> createState() => _PaginaRegistroState();
}

class _PaginaRegistroState extends State<PaginaRegistro> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final FocusNode _nombreFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  
  final _formKey = GlobalKey<FormState>();
  
  bool _isHovering = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  String? _validateNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu nombre';
    }
    if (value.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
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
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe contener al menos una mayúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe contener al menos un número';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Crear usuario en Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Actualizar el perfil del usuario con el nombre
        await userCredential.user?.updateDisplayName(_nombreController.text.trim());
        await userCredential.user?.reload();

        // Mostrar mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '¡Registro exitoso! Bienvenido ${_nombreController.text}',
                style: TextStyle(color: Coloresapp.colorBlanco),
              ),
              backgroundColor: Coloresapp.colorVerde,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Redirigir a login después de 2 segundos
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PaginaLogin()),
              );
            }
          });
        }
      } on FirebaseAuthException catch (e) {
        String mensajeError;
        if (e.code == 'weak-password') {
          mensajeError = 'La contraseña es demasiado débil';
        } else if (e.code == 'email-already-in-use') {
          mensajeError = 'Este email ya está registrado';
        } else if (e.code == 'invalid-email') {
          mensajeError = 'El email no es válido';
        } else {
          mensajeError = 'Error al registrar: ${e.message}';
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
          Container(
            color: Coloresapp.colorFonsInici,
          ),
          
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
                      const SizedBox(height: 50),
                      
                      // Widget animado de bienvenida
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
                      
                      const SizedBox(height: 30),
                      
                      // Campo de nombre
                      TextFieldAutentificacion(
                        controllerText: _nombreController,
                        hintText: 'Nombre completo',
                        focusNode: _nombreFocus,
                        validator: _validateNombre,
                        esPassword: false,
                        valorInicialOcultarEyeToggle: true,
                        enabled: !_isLoading,
                      ),
                      
                      const SizedBox(height: 20),
                      
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
                      
                      const SizedBox(height: 20),
                      
                      // Campo de confirmar contraseña
                      TextFieldAutentificacion(
                        controllerText: _confirmPasswordController,
                        hintText: 'Confirmar contraseña',
                        focusNode: _confirmPasswordFocus,
                        validator: _validateConfirmPassword,
                        esPassword: true,
                        valorInicialOcultarEyeToggle: true,
                        enabled: !_isLoading,
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Requisitos de contraseña (texto informativo)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Coloresapp.colorPrimario.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Coloresapp.colorPrimarioAccentuado.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Requisitos de contraseña:',
                              style: TextStyle(
                                color: Coloresapp.colorBlanco,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '• Mínimo 6 caracteres\n• Al menos una mayúscula\n• Al menos un número',
                              style: TextStyle(
                                color: Coloresapp.colorTextoFlojo,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Botón de registro con efecto hover y loading
                      MouseRegion(
                        onEnter: _isLoading ? null : (_) => setState(() => _isHovering = true),
                        onExit: _isLoading ? null : (_) => setState(() => _isHovering = false),
                        child: GestureDetector(
                          onTap: _isLoading ? null : _handleRegister,
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
                                      'REGISTRARSE',
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
                      
                      const SizedBox(height: 30),
                      
                      // Enlace para ir a login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes una cuenta? ',
                            style: TextStyle(
                              color: Coloresapp.colorTextoFlojo,
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: _isLoading ? null : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const PaginaLogin()),
                              );
                            },
                            child: Text(
                              'Inicia sesión',
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
                      
                      const SizedBox(height: 30),
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
}