import 'package:flutter/material.dart';
import 'package:ja_rating/coloresapp.dart'; // Cambia esto

class TextFieldAutentificacion extends StatefulWidget {
  final TextEditingController controllerText;
  final String hintText;
  final FocusNode focusNode;
  final String? Function(String?) validator;
  final bool esPassword;
  final bool valorInicialOcultarEyeToggle;

  const TextFieldAutentificacion({
    super.key,
    required this.controllerText,
    required this.hintText,
    required this.focusNode,
    required this.validator,
    required this.esPassword,
    required this.valorInicialOcultarEyeToggle,
  });

  @override
  State<TextFieldAutentificacion> createState() => _TextFieldAutentificacionState();
}

class _TextFieldAutentificacionState extends State<TextFieldAutentificacion> {
  late bool _valorEyeToggle;

  @override
  void initState() {
    super.initState();
    _valorEyeToggle = widget.valorInicialOcultarEyeToggle;
  }
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      obscureText: _valorEyeToggle && widget.esPassword,
      obscuringCharacter: "隠",
      controller: widget.controllerText,
      focusNode: widget.focusNode,
      style: TextStyle(
        color: Coloresapp.colorTexto, // Cambia esto
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Coloresapp.ColorTextoFlojo.withOpacity(0.4), // Cambia esto
            blurRadius: 4,
          ),
        ]
      ),
      cursorColor: Coloresapp.colorPrimario, // Cambia esto
      cursorHeight: 24,
      cursorWidth: 2,
      decoration: InputDecoration(
        fillColor: Coloresapp.colorFondo, // Cambia esto
        filled: true,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: Coloresapp.ColorTextoFlojo.withOpacity(0.6), // Cambia esto
          fontStyle: FontStyle.italic,
          shadows: [
            Shadow(
              color: Coloresapp.ColorTextoFlojo.withOpacity(0.4), // Cambia esto
              blurRadius: 4,
            ),
          ]
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(
            color: Coloresapp.colorContorno, // Cambia esto
            width: 1
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(
            color: Coloresapp.colorPrimario, // Cambia esto
            width: 2
          ),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: widget.esPassword ? 
          IconButton(
            onPressed: () {
              setState(() {
                _valorEyeToggle = !_valorEyeToggle;
              });
            },
            icon: Icon(
              _valorEyeToggle ? Icons.visibility_off : Icons.visibility,
              color: Coloresapp.colorPrimarioAccentuado, // Cambia esto
            ),
          ) : null,
        ),
      ),
    );
  }
}