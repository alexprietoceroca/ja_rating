import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:ja_rating/coloresApp.dart';

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

class ProductosCarta extends StatefulWidget {
  final String titulo;
  final String tituloIngles;
  final String tituloOriginal;
  final String genero;
  final String tipo;
  final double puntuacion;
  final String urlImagen;
  final double anchoCarta;
  final String descripcion;

  const ProductosCarta({
    super.key,
    required this.titulo,
    required this.tituloIngles,
    required this.tituloOriginal,
    required this.genero,
    required this.tipo,
    required this.puntuacion,
    required this.urlImagen,
    required this.descripcion,
    this.anchoCarta = 185,
  });

  @override
  State<ProductosCarta> createState() => _ProductosCartaState();
}

class _ProductosCartaState extends State<ProductosCarta>
    with SingleTickerProviderStateMixin {
  late AnimationController _controladorGiro;
  late Animation<double> _animacionGiro;
  bool _girada = false;

  @override
  void initState() {
    super.initState();
    _controladorGiro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animacionGiro = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _controladorGiro, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controladorGiro.dispose();
    super.dispose();
  }

  Color get colorTipo {
    switch (widget.tipo) {
      case 'Anime':
        return Coloresapp.colorPrimario;
      case 'Manga':
        return Coloresapp.colorContorno;
      case 'Manhwa':
        return Coloresapp.colorMorado;
      case 'Manhua':
        return Coloresapp.colorVerde;
      case 'Donghua':
        return Coloresapp.colorNaranja;
      default:
        return Coloresapp.colorPrimario;
    }
  }

  List<MensajeTipo> get _mensajesTipo {
    switch (widget.tipo) {
      case 'Anime':
        return [
          MensajeTipo(texto: 'Anime', estilo: null),
          MensajeTipo(texto: 'Anime', estilo: null),
          MensajeTipo(texto: 'アニメ', estilo: GoogleFonts.notoSansJp()),
        ];
      case 'Manga':
        return [
          MensajeTipo(texto: 'Manga', estilo: null),
          MensajeTipo(texto: 'Manga', estilo: null),
          MensajeTipo(texto: 'マンガ', estilo: GoogleFonts.notoSansJp()),
        ];
      case 'Manhwa':
        return [
          MensajeTipo(texto: 'Manhwa', estilo: null),
          MensajeTipo(texto: 'Manhwa', estilo: null),
          MensajeTipo(texto: '만화', estilo: GoogleFonts.notoSansKr()),
        ];
      case 'Manhua':
        return [
          MensajeTipo(texto: 'Manhua', estilo: null),
          MensajeTipo(texto: 'Manhua', estilo: null),
          MensajeTipo(texto: '漫画', estilo: GoogleFonts.notoSansSc()),
        ];
      case 'Donghua':
        return [
          MensajeTipo(texto: 'Donghua', estilo: null),
          MensajeTipo(texto: 'Donghua', estilo: null),
          MensajeTipo(texto: '动画', estilo: GoogleFonts.notoSansSc()),
        ];
      default:
        return [
          MensajeTipo(texto: widget.tipo, estilo: null),
          MensajeTipo(texto: widget.tipo, estilo: null),
          MensajeTipo(texto: widget.tipo, estilo: null),
        ];
    }
  }

  List<MensajeTipo> get _mensajesTitulo {
    switch (widget.tipo) {
      case 'Anime':
      case 'Manga':
        return [
          MensajeTipo(texto: widget.titulo, estilo: null),
          MensajeTipo(texto: widget.tituloIngles, estilo: null),
          MensajeTipo(
            texto: widget.tituloOriginal,
            estilo: GoogleFonts.notoSansJp(),
          ),
        ];
      case 'Manhwa':
        return [
          MensajeTipo(texto: widget.titulo, estilo: null),
          MensajeTipo(texto: widget.tituloIngles, estilo: null),
          MensajeTipo(
            texto: widget.tituloOriginal,
            estilo: GoogleFonts.notoSansKr(),
          ),
        ];
      case 'Manhua':
      case 'Donghua':
        return [
          MensajeTipo(texto: widget.titulo, estilo: null),
          MensajeTipo(texto: widget.tituloIngles, estilo: null),
          MensajeTipo(
            texto: widget.tituloOriginal,
            estilo: GoogleFonts.notoSansSc(),
          ),
        ];
      default:
        return [
          MensajeTipo(texto: widget.titulo, estilo: null),
          MensajeTipo(texto: widget.tituloIngles, estilo: null),
          MensajeTipo(texto: widget.tituloOriginal, estilo: null),
        ];
    }
  }

  double get _alturaCarta {
    final double altoImagen = widget.anchoCarta * 1.25;
    final double altoInfo = 10 + 36 + 4 + 16 + 6 + 16 + 10;
    return altoImagen + altoInfo;
  }

  @override
  Widget build(BuildContext context) {
    _ControladorIdioma().iniciar();

    return GestureDetector(
      onDoubleTap: () {
        if (!_girada) {
          _controladorGiro.forward();
          setState(() => _girada = true);
        } else {
          _controladorGiro.reverse();
          setState(() => _girada = false);
        }
      },
      child: AnimatedBuilder(
        animation: _animacionGiro,
        builder: (context, child) {
          final double angulo = _animacionGiro.value;
          final bool mostrarDetras = angulo > math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angulo),
            child: mostrarDetras
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CaraDetras(
                      titulo: widget.titulo,
                      genero: widget.genero,
                      descripcion: widget.descripcion,
                      colorTipo: colorTipo,
                      anchoCarta: widget.anchoCarta,
                      altura: _alturaCarta,
                    ),
                  )
                : _CaraDelantera(
                    mensajesTipo: _mensajesTipo,
                    mensajesTitulo: _mensajesTitulo,
                    genero: widget.genero,
                    puntuacion: widget.puntuacion,
                    urlImagen: widget.urlImagen,
                    colorTipo: colorTipo,
                    anchoCarta: widget.anchoCarta,
                  ),
          );
        },
      ),
    );
  }
}

class _CaraDelantera extends StatelessWidget {
  final List<MensajeTipo> mensajesTipo;
  final List<MensajeTipo> mensajesTitulo;
  final String genero;
  final double puntuacion;
  final String urlImagen;
  final Color colorTipo;
  final double anchoCarta;

  const _CaraDelantera({
    required this.mensajesTipo,
    required this.mensajesTitulo,
    required this.genero,
    required this.puntuacion,
    required this.urlImagen,
    required this.colorTipo,
    required this.anchoCarta,
  });

  @override
  Widget build(BuildContext context) {
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  urlImagen,
                  height: anchoCarta * 1.25,
                  width: anchoCarta,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: anchoCarta * 1.25,
                    width: anchoCarta,
                    color: Coloresapp.colorPrimario,
                    child: const Icon(
                      Icons.image_not_supported_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: _EtiquetaTipoAnimada(
                  mensajes: mensajesTipo,
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
                _TituloAnimado(
                  mensajes: mensajesTitulo,
                  anchoCarta: anchoCarta,
                ),
                const SizedBox(height: 4),
                Text(
                  genero,
                  style: const TextStyle(
                    fontFamily: 'HoshikoSatsuki',
                    fontSize: 11,
                    color: Coloresapp.colorTextoFlojo,
                  ),
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

class _CaraDetras extends StatelessWidget {
  final String titulo;
  final String genero;
  final String descripcion;
  final Color colorTipo;
  final double anchoCarta;
  final double altura;

  const _CaraDetras({
    required this.titulo,
    required this.genero,
    required this.descripcion,
    required this.colorTipo,
    required this.anchoCarta,
    required this.altura,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: anchoCarta,
      height: altura,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorTipo, colorTipo.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorTipo.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      genero.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'HoshikoSatsuki',
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontFamily: 'HoshikoSatsuki',
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Container(height: 1, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 10),
                  Text(
                    descripcion,
                    style: TextStyle(
                      fontFamily: 'HoshikoSatsuki',
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      height: 1.4,
                    ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 14,
            right: 14,
            child: Row(
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: Colors.white.withOpacity(0.6),
                  size: 12,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Doble click para volver',
                    style: TextStyle(
                      fontFamily: 'HoshikoSatsuki',
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 9,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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

  const _EtiquetaTipoAnimada({
    required this.mensajes,
    required this.colorFondo,
  });

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
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
          style:
              mensaje.estilo?.copyWith(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ) ??
              const TextStyle(
                fontFamily: 'HoshikoSatsuki',
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
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
            style:
                mensaje.estilo?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111111),
                  height: 1.2,
                ) ??
                const TextStyle(
                  fontFamily: 'HoshikoSatsuki',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
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
        ...List.generate(5, (i) {
          final double valorEstrella = puntuacion - i;
          if (valorEstrella >= 1) {
            return Icon(
              Icons.star_rounded,
              size: 14,
              color: Coloresapp.colorPrimario,
            );
          } else if (valorEstrella <= 0) {
            return Icon(
              Icons.star_outline_rounded,
              size: 14,
              color: Colors.grey.shade300,
            );
          } else {
            return _EstrellaFraccion(fraccion: valorEstrella);
          }
        }),
        const SizedBox(width: 4),
        Text(
          puntuacion.toStringAsFixed(1),
          style: const TextStyle(
            fontFamily: 'HoshikoSatsuki',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Coloresapp.colorTexto,
          ),
        ),
      ],
    );
  }
}

class _EstrellaFraccion extends StatelessWidget {
  final double fraccion;

  const _EstrellaFraccion({required this.fraccion});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        children: [
          Icon(
            Icons.star_outline_rounded,
            size: 14,
            color: Colors.grey.shade300,
          ),
          ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: fraccion,
              child: Icon(
                Icons.star_rounded,
                size: 14,
                color: Coloresapp.colorPrimario,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MensajeTipo {
  final String texto;
  final TextStyle? estilo;

  MensajeTipo({required this.texto, this.estilo});
}
