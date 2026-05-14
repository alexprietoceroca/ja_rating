import 'package:flutter/material.dart';
import 'package:ja_rating/coloresapp.dart';

class TextFieldAutentificacion extends StatefulWidget {
  final TextEditingController controllerText;
  final String hintText;
  final FocusNode focusNode;
  final String? Function(String?)? validator;
  final bool esPassword;
  final bool valorInicialOcultarEyeToggle;
  final bool enabled;

  const TextFieldAutentificacion({
    super.key,
    required this.controllerText,
    required this.hintText,
    required this.focusNode,
    this.validator,
    required this.esPassword,
    required this.valorInicialOcultarEyeToggle,
    this.enabled = true,
  });

  @override
  State<TextFieldAutentificacion> createState() =>
      _TextFieldAutentificacionState();
}

class _TextFieldAutentificacionState extends State<TextFieldAutentificacion> {
  late bool _ocultarTexto;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _ocultarTexto = widget.valorInicialOcultarEyeToggle;
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = widget.focusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _ocultarTexto = !_ocultarTexto;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determinar el color de fondo según el estado
    Color getFillColor() {
      if (!widget.enabled) return Coloresapp.colorInputFondo.withOpacity(0.5);
      if (_hasFocus) return Coloresapp.colorInputFondo.withOpacity(1.0);
      return Coloresapp.colorInputFondo;
    }

    // Determinar el color del borde
    Color getBorderColor() {
      if (!widget.enabled) return Coloresapp.colorInputBorde.withOpacity(0.3);
      if (_hasFocus) return Coloresapp.colorInputFoco;
      return Coloresapp.colorInputBorde;
    }

    // Determinar el ancho del borde
    double getBorderWidth() {
      if (!widget.enabled) return 1;
      if (_hasFocus) return 2;
      return 1;
    }

    return TextFormField(
      controller: widget.controllerText,
      focusNode: widget.focusNode,
      validator: widget.validator,
      obscureText: widget.esPassword ? _ocultarTexto : false,
      enabled: widget.enabled,
      style: TextStyle(
        color: widget.enabled
            ? Coloresapp.colorInputTexto
            : Coloresapp.colorTextoFlojo,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: widget.enabled
              ? Coloresapp.colorInputHint
              : Coloresapp.colorInputHint.withOpacity(0.4),
          fontSize: 14,
        ),
        filled: true,
        fillColor: getFillColor(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: getBorderColor(),
            width: getBorderWidth(),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Coloresapp.colorInputBorde,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Coloresapp.colorInputFoco,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Coloresapp.colorRojoOscuro,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Coloresapp.colorRojoOscuro,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        suffixIcon: widget.esPassword
            ? IconButton(
                icon: Icon(
                  _ocultarTexto ? Icons.visibility_off : Icons.visibility,
                  color: _hasFocus && widget.enabled
                      ? Coloresapp.colorInputFoco
                      : (widget.enabled
                          ? Coloresapp.colorInputHint
                          : Coloresapp.colorInputHint.withOpacity(0.4)),
                ),
                onPressed: widget.enabled ? _togglePasswordVisibility : null,
              )
            : null,
      ),
    );
  }
}