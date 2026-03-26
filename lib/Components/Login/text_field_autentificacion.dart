import 'package:flutter/material.dart';
import 'package:ja_rating/coloresapp.dart';

class TextFieldAutentificacion extends StatelessWidget {
  final TextEditingController controllerText;
  final String hintText;
  final FocusNode focusNode;
  final String? Function(String?)? validator;
  final bool esPassword;
  final bool valorInicialOcultarEyeToggle;
  final bool enabled; // AÑADE ESTA LÍNEA

  const TextFieldAutentificacion({
    super.key,
    required this.controllerText,
    required this.hintText,
    required this.focusNode,
    this.validator,
    required this.esPassword,
    required this.valorInicialOcultarEyeToggle,
    this.enabled = true, // AÑADE ESTA LÍNEA CON VALOR POR DEFECTO
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controllerText,
      focusNode: focusNode,
      validator: validator,
      obscureText: esPassword ? valorInicialOcultarEyeToggle : false,
      enabled: enabled, // AÑADE ESTA LÍNEA
      style: TextStyle(
        color: enabled ? Coloresapp.colorBlanco : Coloresapp.colorTextoFlojo,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: enabled 
              ? Coloresapp.colorTextoFlojo.withOpacity(0.7)
              : Coloresapp.colorTextoFlojo.withOpacity(0.3),
        ),
        filled: true,
        fillColor: enabled 
            ? Coloresapp.colorPrimario.withOpacity(0.1)
            : Coloresapp.colorPrimario.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: enabled 
                ? Coloresapp.colorContorno.withOpacity(0.3)
                : Coloresapp.colorContorno.withOpacity(0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: enabled 
                ? Coloresapp.colorContorno.withOpacity(0.3)
                : Coloresapp.colorContorno.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: enabled ? Coloresapp.colorPrimario : Coloresapp.colorContorno,
            width: enabled ? 2 : 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: enabled ? Coloresapp.colorRojoOscuro : Coloresapp.colorContorno,
            width: enabled ? 2 : 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: enabled ? Coloresapp.colorRojoOscuro : Coloresapp.colorContorno,
            width: enabled ? 2 : 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        suffixIcon: esPassword
            ? IconButton(
                icon: Icon(
                  valorInicialOcultarEyeToggle
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: enabled 
                      ? Coloresapp.colorPrimario
                      : Coloresapp.colorTextoFlojo,
                ),
                onPressed: enabled ? () {
                  // Aquí iría la lógica para mostrar/ocultar contraseña
                  // Por ahora solo imprimimos
                  print('Toggle password visibility');
                } : null,
              )
            : null,
      ),
    );
  }
}