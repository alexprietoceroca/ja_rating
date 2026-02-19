import 'package:flutter/material.dart';
import 'package:ja_rating/coloresApp.dart';

class TextFieldAutentificacion extends StatefulWidget {
  final TextEditingController controllerText;
  final bool valorInicialOcultarEyeToggle;
  final bool esPassword;
  final String hintText;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;

  const TextFieldAutentificacion({
    super.key,
    required this.controllerText,
    this.valorInicialOcultarEyeToggle = true,
    this.esPassword = false,
    required this.hintText,
    this.focusNode,
    this.validator,
  });

  @override
  State<TextFieldAutentificacion> createState() =>
      _TextFieldAutentificacionState();
}

class _TextFieldAutentificacionState extends State<TextFieldAutentificacion> {
  late bool _valorEyeToggle;

  // ✔️ Instancia correcta de tu clase
  final colores = Coloresapp();

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
        color: colores.colorTexto,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: colores.ColorTextoFlojo.withOpacity(0.4),
            blurRadius: 4,
          ),
        ],
      ),

      cursorColor: colores.colorPrimario,
      cursorHeight: 24,
      cursorWidth: 2,

      decoration: InputDecoration(
        fillColor: colores.colorFondo,
        filled: true,

        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: colores.ColorTextoFlojo.withOpacity(0.6),
          fontStyle: FontStyle.italic,
          shadows: [
            Shadow(
              color: colores.ColorTextoFlojo.withOpacity(0.4),
              blurRadius: 4,
            ),
          ],
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(
            color: colores.colorContorno,
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(
            color: colores.colorPrimario,
            width: 2,
          ),
        ),

        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: widget.esPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _valorEyeToggle = !_valorEyeToggle;
                    });
                  },
                  icon: Icon(
                    _valorEyeToggle
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: colores.colorPrimarioAccentuado,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
