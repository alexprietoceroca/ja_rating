import 'package:flutter/material.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/Login/text_field_autentificacion.dart';
import 'package:ja_rating/Components/Login/texto_idiomas.dart';
import 'package:ja_rating/Paginas/pagina_login/pagina_login.dart';
import 'package:ja_rating/Paginas/pagina_principal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaginaRegistro extends StatefulWidget {
  const PaginaRegistro({super.key});

  @override
  State<PaginaRegistro> createState() => _PaginaRegistroState();
}

class _PaginaRegistroState extends State<PaginaRegistro> {
  final TextEditingController _nombreUsuarioController = TextEditingController();
  final TextEditingController _nombreCompletoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final FocusNode _nombreUsuarioFocus = FocusNode();
  final FocusNode _nombreCompletoFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  
  final _formKey = GlobalKey<FormState>();
  
  bool _isHovering = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreUsuarioController.dispose();
    _nombreCompletoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreUsuarioFocus.dispose();
    _nombreCompletoFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  String? _validateNombreUsuario(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un nombre de usuario';
    }
    if (value.length < 3) {
      return 'El nombre de usuario debe tener al menos 3 caracteres';
    }
    if (value.length > 20) {
      return 'El nombre de usuario no puede tener más de 20 caracteres';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Solo letras, números y guión bajo';
    }
    return null;
  }

  String? _validateNombreCompleto(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu nombre completo';
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      print("🔄 INICIANDO REGISTRO...");
      
      // 1. CREAR USUARIO EN AUTHENTICATION
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user == null) throw Exception("No se pudo crear el usuario");

      print("✅ Usuario creado en Auth: ${user.uid}");

      // 2. ACTUALIZAR DISPLAY NAME
      await user.updateDisplayName(_nombreCompletoController.text.trim());
      
      // 3. GUARDAR EN FIRESTORE - VERSIÓN SIMPLIFICADA
      try {
        print("📝 Guardando en Firestore...");
        
        // Datos simples para asegurar que funcione
        Map<String, dynamic> userData = {
          'uid': user.uid,
          'Usuario': _nombreUsuarioController.text.trim().toLowerCase(),
          'Nombre_Completo': _nombreCompletoController.text.trim(),
          'Correo_electronico': _emailController.text.trim(),
          'fechaRegistro': FieldValue.serverTimestamp(),
        };

        // Intentar guardar
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .set(userData);

        print("✅ Usuario guardado en Firestore");
        
      } catch (firestoreError) {
        print("❌ Error Firestore: $firestoreError");
        // Si falla, eliminar usuario de Auth
        await user.delete();
        throw Exception("No se pudo guardar en Firestore. Verifica las reglas en Firebase Console > Firestore > Rules");
      }

      // 4. ÉXITO
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Registro exitoso!',
            style: TextStyle(color: Coloresapp.colorBlanco),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navegar a página principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PaginaPrincipal()),
      );

    } on FirebaseAuthException catch (e) {
      print("❌ Error Auth: ${e.code}");
      
      String mensaje;
      if (e.code == 'email-already-in-use') {
        mensaje = 'Este correo ya está registrado';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña es muy débil';
      } else if (e.code == 'invalid-email') {
        mensaje = 'Email no válido';
      } else {
        mensaje = e.message ?? 'Error de autenticación';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      
    } catch (e) {
      print("❌ Error general: $e");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloresapp.colorFonsInici,
      body: Stack(
        children: [
          Container(color: Coloresapp.colorFonsInici),
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
                      const SizedBox(height: 30),
                      
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
                      
                      TextFieldAutentificacion(
                        controllerText: _nombreUsuarioController,
                        hintText: 'Nombre de usuario',
                        focusNode: _nombreUsuarioFocus,
                        validator: _validateNombreUsuario,
                        esPassword: false,
                        valorInicialOcultarEyeToggle: true,
                        enabled: !_isLoading,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      TextFieldAutentificacion(
                        controllerText: _nombreCompletoController,
                        hintText: 'Nombre completo',
                        focusNode: _nombreCompletoFocus,
                        validator: _validateNombreCompleto,
                        esPassword: false,
                        valorInicialOcultarEyeToggle: true,
                        enabled: !_isLoading,
                      ),
                      
                      const SizedBox(height: 20),
                      
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
                              'Requisitos:',
                              style: TextStyle(
                                color: Coloresapp.colorBlanco,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '• Nombre de usuario: mínimo 3 caracteres (solo letras, números y _)\n'
                              '• Contraseña: mínimo 6 caracteres, una mayúscula y un número',
                              style: TextStyle(
                                color: Coloresapp.colorTextoFlojo,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
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