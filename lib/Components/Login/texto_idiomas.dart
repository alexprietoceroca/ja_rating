import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextoIdiomas extends StatefulWidget {
  final Duration duracionAnimacion;
  final Duration duracionPausa;
  final TextStyle? estiloBase;

  const TextoIdiomas({
    Key? key,
    this.duracionAnimacion = const Duration(milliseconds: 800),
    this.duracionPausa = const Duration(seconds: 2),
    this.estiloBase,
  }) : super(key: key);

  @override
  State<TextoIdiomas> createState() => _TextoIdiomasState();
}

class _TextoIdiomasState extends State<TextoIdiomas> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<MensajeIdioma> _mensajes = [
    MensajeIdioma(
      texto: '¡Bienvenidos!',
      idioma: 'Español',
      estilo: GoogleFonts.poppins(),
    ),
    MensajeIdioma(
      texto: 'ようこそ',
      idioma: 'Japonés',
      estilo: GoogleFonts.notoSansJp(),
    ),
    MensajeIdioma(
      texto: '환영합니다',
      idioma: 'Coreano',
      estilo: GoogleFonts.notoSansKr(),
    ),
    MensajeIdioma(
      texto: '欢迎', 
      idioma: 'Chino',
      estilo: GoogleFonts.notoSansSc(),
    ),
  ];

  int _indiceActual = 0;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: widget.duracionAnimacion,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _iniciarCicloAnimacion();
  }

  void _iniciarCicloAnimacion() {
    Future.delayed(widget.duracionPausa, () {
      if (mounted) {
        setState(() {
          _indiceActual = (_indiceActual + 1) % _mensajes.length;
        });
        
        _controller.forward(from: 0.0);
        _iniciarCicloAnimacion();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mensajeActual = _mensajes[_indiceActual];
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Text(
                  mensajeActual.texto,
                  style: mensajeActual.estilo?.copyWith(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    letterSpacing: 2,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          mensajeActual.idioma,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class MensajeIdioma {
  final String texto;
  final String idioma;
  final TextStyle? estilo;

  MensajeIdioma({
    required this.texto, 
    required this.idioma, 
    this.estilo
  });
}