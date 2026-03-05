import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ja_rating/coloresApp.dart';

// Controlador global compartido para sincronizar animaciones
class _ControladorIdioma {
  static final _ControladorIdioma _instancia = _ControladorIdioma._interno();
  factory _ControladorIdioma() => _instancia;
  _ControladorIdioma._interno();

  final List<VoidCallback> _oyentes = [];
  int indiceActual = 0;
  bool _iniciado = false;

  void iniciar() {
    if (_iniciado) return;
    _iniciado = true;
    _ciclo();
  }

  void _ciclo() {
    Future.delayed(const Duration(seconds: 3), () {
      indiceActual = (indiceActual + 1) % 3;
      for (final oyente in List.from(_oyentes)) {
        oyente();
      }
      _ciclo();
    });
  }

  void agregarOyente(VoidCallback oyente) {
    _oyentes.add(oyente);
  }

  void eliminarOyente(VoidCallback oyente) {
    _oyentes.remove(oyente);
  }
}

class ProductosCarta extends StatelessWidget {
  final String titulo;
  final String tituloIngles;
  final String tituloOriginal;
  final String genero;
  final String tipo;
  final double puntuacion;
  final String urlImagen;
  final double anchoCarta;

  const ProductosCarta({
    super.key,
    required this.titulo,
    required this.tituloIngles,
    required this.tituloOriginal,
    required this.genero,
    required this.tipo,
    required this.puntuacion,
    required this.urlImagen,
    this.anchoCarta = 160,
  });

  Color get colorTipo {
    switch (tipo) {
      case 'Anime': return Coloresapp.colorPrimario;
      case 'Manga': return Coloresapp.colorContorno;
      case 'Manhwa': return Coloresapp.colorMorado;
      case 'Manhua': return Coloresapp.colorVerde;
      case 'Donghua': return Coloresapp.colorNaranja;
      default: return Coloresapp.colorPrimario;
    }
  }

  List<MensajeTipo> get _mensajesTipo {
    switch (tipo) {
      case 'Anime':
        return [
          MensajeTipo(texto: 'Anime', estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: 'Anime', estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: 'アニメ', estilo: GoogleFonts.notoSansJp()),
        ];
      case 'Manga':
        return [
          MensajeTipo(texto: 'Manga', estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: 'Manga', estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: 'マンガ', estilo: GoogleFonts.notoSansJp()),
        ];
      case 'Manhwa':
        return [
          MensajeTipo(texto: 'Manhwa', estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: 'Manhwa', estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: '만화', estilo: GoogleFonts.notoSansKr()),
        ];
      case 'Manhua':
        return [
          MensajeTipo(texto: 'Manhua', estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: 'Manhua', estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: '漫画', estilo: GoogleFonts.notoSansSc()),
        ];
      case 'Donghua':
        return [
          MensajeTipo(texto: 'Donghua', estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: 'Donghua', estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: '动画', estilo: GoogleFonts.notoSansSc()),
        ];
      default:
        return [
          MensajeTipo(texto: tipo, estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: tipo, estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: tipo, estilo: GoogleFonts.poppins()),
        ];
    }
  }

  List<MensajeTipo> get _mensajesTitulo {
    switch (tipo) {
      case 'Anime':
      case 'Manga':
        return [
          MensajeTipo(texto: titulo, estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: tituloIngles, estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: tituloOriginal, estilo: GoogleFonts.notoSansJp()),
        ];
      case 'Manhwa':
        return [
          MensajeTipo(texto: titulo, estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: tituloIngles, estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: tituloOriginal, estilo: GoogleFonts.notoSansKr()),
        ];
      case 'Manhua':
      case 'Donghua':
        return [
          MensajeTipo(texto: titulo, estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: tituloIngles, estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: tituloOriginal, estilo: GoogleFonts.notoSansSc()),
        ];
      default:
        return [
          MensajeTipo(texto: titulo, estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: tituloIngles, estilo: GoogleFonts.poppins()),
          MensajeTipo(texto: tituloOriginal, estilo: GoogleFonts.poppins()),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    _ControladorIdioma().iniciar();

    return Container(
      width: anchoCarta,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Coloresapp.colorBlanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Coloresapp.colorSombraCard,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  urlImagen,
                  height: anchoCarta * 1.25,
                  width: anchoCarta,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: anchoCarta * 1.25,
                    width: anchoCarta,
                    color: Coloresapp.colorPrimario,
                    child: const Icon(Icons.image_not_supported_rounded, color: Colors.white, size: 40),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: _EtiquetaTipoAnimada(
                  mensajes: _mensajesTipo,
                  colorFondo: colorTipo,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _TituloAnimado(mensajes: _mensajesTitulo, anchoCarta: anchoCarta),
                const SizedBox(height: 4),
                Text(
                  genero,
                  style: const TextStyle(fontSize: 11, color: Coloresapp.colorTextoFlojo),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _EstrellasPuntuacion(puntuacion: puntuacion),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _EtiquetaTipoAnimada extends StatefulWidget {
  final List<MensajeTipo> mensajes;
  final Color colorFondo;

  const _EtiquetaTipoAnimada({required this.mensajes, required this.colorFondo});

  @override
  State<_EtiquetaTipoAnimada> createState() => _EtiquetaTipoAnimadaState();
}

class _EtiquetaTipoAnimadaState extends State<_EtiquetaTipoAnimada>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _indiceActual = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _indiceActual = _ControladorIdioma().indiceActual;
    _controller.forward();
    _ControladorIdioma().agregarOyente(_alCambiarIdioma);
  }

  void _alCambiarIdioma() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _indiceActual = _ControladorIdioma().indiceActual;
        });
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _ControladorIdioma().eliminarOyente(_alCambiarIdioma);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mensaje = widget.mensajes[_indiceActual];
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: widget.colorFondo,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          mensaje.texto,
          style: mensaje.estilo?.copyWith(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}


class _TituloAnimado extends StatefulWidget {
  final List<MensajeTipo> mensajes;
  final double anchoCarta;

  const _TituloAnimado({required this.mensajes, required this.anchoCarta});

  @override
  State<_TituloAnimado> createState() => _TituloAnimadoState();
}

class _TituloAnimadoState extends State<_TituloAnimado>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _indiceActual = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _indiceActual = _ControladorIdioma().indiceActual;
    _controller.forward();
    _ControladorIdioma().agregarOyente(_alCambiarIdioma);
  }

  void _alCambiarIdioma() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          _indiceActual = _ControladorIdioma().indiceActual;
        });
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _ControladorIdioma().eliminarOyente(_alCambiarIdioma);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mensaje = widget.mensajes[_indiceActual];
    return SizedBox(
      height: 36,
      width: widget.anchoCarta - 20,
      child: OverflowBox(
        maxHeight: 36,
        alignment: Alignment.centerLeft,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            mensaje.texto,
            style: mensaje.estilo?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111111),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}


class _EstrellasPuntuacion extends StatelessWidget {
  final double puntuacion;

  const _EstrellasPuntuacion({required this.puntuacion});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(
          5,
          (i) => Icon(
            i < puntuacion.round() ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 14,
            color: i < puntuacion.round() ? Coloresapp.colorPrimario : Colors.grey.shade300,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          puntuacion.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Coloresapp.colorTexto,
          ),
        ),
      ],
    );
  }
}


class MensajeTipo {
  final String texto;
  final TextStyle? estilo;

  MensajeTipo({required this.texto, this.estilo});
}