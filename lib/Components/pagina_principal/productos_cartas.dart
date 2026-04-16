// productos_cartas.dart
// Ahora: long press para mostrar trasera, soltar para volver a delantera.
// Tap simple → navegación a detalle.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:ja_rating/coloresApp.dart';
import 'package:ja_rating/Components/Services/image_service.dart';

// ------------------------------------------------------------
// Controlador global para la animación de cambio de idioma
// ------------------------------------------------------------
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

// ------------------------------------------------------------
// Widget principal de la carta
// ------------------------------------------------------------
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
  final bool mostrarExtra;
  final String autor;
  final int anio;
  final String estudio;
  final VoidCallback? onTap;

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
    this.anchoCarta = 200,
    this.mostrarExtra = false,
    this.autor = '',
    this.anio = 0,
    this.estudio = '',
    this.onTap,
  });

  static double calcularAltura(double ancho, {bool mostrarExtra = false}) {
    final double altoImagen = ancho * 1.25;
    if (mostrarExtra) {
      return altoImagen + 50;
    } else {
      return altoImagen + 80;
    }
  }

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

  List<MensajeIdioma> get _mensajesTipo {
    switch (widget.tipo) {
      case 'Anime':
        return [
          MensajeIdioma(texto: 'Anime', estilo: GoogleFonts.oswald()),
          MensajeIdioma(texto: 'Anime', estilo: GoogleFonts.oswald()),
          MensajeIdioma(texto: 'アニメ', estilo: GoogleFonts.notoSansJp()),
        ];
      case 'Manga':
        return [
          MensajeIdioma(texto: 'Manga', estilo: GoogleFonts.oswald()),
          MensajeIdioma(texto: 'Manga', estilo: GoogleFonts.oswald()),
          MensajeIdioma(texto: 'マンガ', estilo: GoogleFonts.notoSansJp()),
        ];
      case 'Manhwa':
        return [
          MensajeIdioma(texto: 'Manhwa', estilo: GoogleFonts.oswald()),
          MensajeIdioma(texto: 'Manhwa', estilo: GoogleFonts.oswald()),
          MensajeIdioma(texto: '만화', estilo: GoogleFonts.notoSansKr()),
        ];
      case 'Manhua':
        return [
          MensajeIdioma(texto: 'Manhua', estilo: GoogleFonts.oswald()),
          MensajeIdioma(texto: 'Manhua', estilo: GoogleFonts.oswald()),
          MensajeIdioma(texto: '漫画', estilo: GoogleFonts.notoSansSc()),
        ];
      case 'Donghua':
        return [
          MensajeIdioma(texto: 'Donghua', estilo: GoogleFonts.oswald()),
          MensajeIdioma(texto: 'Donghua', estilo: GoogleFonts.oswald()),
          MensajeIdioma(texto: '动画', estilo: GoogleFonts.notoSansSc()),
        ];
      default:
        return [
          MensajeIdioma(texto: widget.tipo, estilo: null),
          MensajeIdioma(texto: widget.tipo, estilo: null),
          MensajeIdioma(texto: widget.tipo, estilo: null),
        ];
    }
  }

  List<MensajeIdioma> get _mensajesTitulo {
    switch (widget.tipo) {
      case 'Anime':
      case 'Manga':
        return [
          MensajeIdioma(texto: widget.titulo, estilo: GoogleFonts.oswald()),
          MensajeIdioma(
            texto: widget.tituloIngles,
            estilo: GoogleFonts.oswald(),
          ),
          MensajeIdioma(
            texto: widget.tituloOriginal,
            estilo: GoogleFonts.notoSansJp(),
          ),
        ];
      case 'Manhwa':
        return [
          MensajeIdioma(texto: widget.titulo, estilo: GoogleFonts.oswald()),
          MensajeIdioma(
            texto: widget.tituloIngles,
            estilo: GoogleFonts.oswald(),
          ),
          MensajeIdioma(
            texto: widget.tituloOriginal,
            estilo: GoogleFonts.notoSansKr(),
          ),
        ];
      case 'Manhua':
      case 'Donghua':
        return [
          MensajeIdioma(texto: widget.titulo, estilo: GoogleFonts.oswald()),
          MensajeIdioma(
            texto: widget.tituloIngles,
            estilo: GoogleFonts.oswald(),
          ),
          MensajeIdioma(
            texto: widget.tituloOriginal,
            estilo: GoogleFonts.notoSansSc(),
          ),
        ];
      default:
        return [
          MensajeIdioma(texto: widget.titulo, estilo: null),
          MensajeIdioma(texto: widget.tituloIngles, estilo: null),
          MensajeIdioma(texto: widget.tituloOriginal, estilo: null),
        ];
    }
  }

  void _mostrarTrasera() {
    if (!_girada && !_controladorGiro.isAnimating) {
      _controladorGiro.forward();
      setState(() => _girada = true);
    }
  }

  void _ocultarTrasera() {
    if (_girada && !_controladorGiro.isAnimating) {
      _controladorGiro.reverse();
      setState(() => _girada = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _ControladorIdioma().iniciar();

    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: (_) => _mostrarTrasera(),
      onLongPressUp: _ocultarTrasera,
      onLongPressCancel: _ocultarTrasera,
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
                      altura: ProductosCarta.calcularAltura(
                        widget.anchoCarta,
                        mostrarExtra: widget.mostrarExtra,
                      ),
                      autor: widget.autor,
                      anio: widget.anio,
                      estudio: widget.estudio,
                      mostrarExtra: widget.mostrarExtra,
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

// ------------------------------------------------------------
// Cara delantera (sin información extra)
// ------------------------------------------------------------
class _CaraDelantera extends StatelessWidget {
  final List<MensajeIdioma> mensajesTipo;
  final List<MensajeIdioma> mensajesTitulo;
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
    // Usar la URL de imagen directamente (ya viene de ImageService)
    final String imagenUrl = urlImagen;

    return Container(
      width: anchoCarta,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Coloresapp.colorBlanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(235, 248, 219, 219),
            blurRadius: 4,
            offset: const Offset(0, 0),
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imagenUrl,
                  height: anchoCarta * 1.25,
                  width: anchoCarta,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    print('Error cargando imagen: $imagenUrl');
                    return Container(
                      height: anchoCarta * 1.25,
                      width: anchoCarta,
                      color: Coloresapp.colorPrimario,
                      child: const Icon(Icons.image_not_supported_rounded,
                          color: Colors.white, size: 40),
                    );
                  },
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
                    mensajes: mensajesTitulo, anchoCarta: anchoCarta),
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
                const SizedBox(height: 4),
                _EstrellasPuntuacion(puntuacion: puntuacion),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// Cara trasera (sinopsis + información extra opcional)
// ------------------------------------------------------------
class _CaraDetras extends StatelessWidget {
  final String titulo;
  final String genero;
  final String descripcion;
  final Color colorTipo;
  final double anchoCarta;
  final double altura;
  final String autor;
  final int anio;
  final String estudio;
  final bool mostrarExtra;

  const _CaraDetras({
    required this.titulo,
    required this.genero,
    required this.descripcion,
    required this.colorTipo,
    required this.anchoCarta,
    required this.altura,
    required this.autor,
    required this.anio,
    required this.estudio,
    required this.mostrarExtra,
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
            color: const Color.fromARGB(235, 248, 219, 219),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (mostrarExtra) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              autor,
                              style: TextStyle(
                                fontFamily: 'HoshikoSatsuki',
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            anio.toString(),
                            style: TextStyle(
                              fontFamily: 'HoshikoSatsuki',
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.business_center_rounded,
                            size: 11,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              estudio,
                              style: TextStyle(
                                fontFamily: 'HoshikoSatsuki',
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
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
                    'Mantén pulsado para ver',
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

// ------------------------------------------------------------
// Etiqueta del tipo (animada)
// ------------------------------------------------------------
class _EtiquetaTipoAnimada extends StatefulWidget {
  final List<MensajeIdioma> mensajes;
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
        setState(() => _indiceActual = _ControladorIdioma().indiceActual);
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
                fontSize: 16,
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

// ------------------------------------------------------------
// Título animado
// ------------------------------------------------------------
class _TituloAnimado extends StatefulWidget {
  final List<MensajeIdioma> mensajes;
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
        setState(() => _indiceActual = _ControladorIdioma().indiceActual);
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
      height: 20,
      width: widget.anchoCarta - 20,
      child: OverflowBox(
        maxHeight: 30,
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

// ------------------------------------------------------------
// Estrellas de puntuación
// ------------------------------------------------------------
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

// ------------------------------------------------------------
// Estrella fraccionaria
// ------------------------------------------------------------
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

// ------------------------------------------------------------
// Modelo para mensajes con estilo
// ------------------------------------------------------------
class MensajeIdioma {
  final String texto;
  final TextStyle? estilo;

  MensajeIdioma({required this.texto, this.estilo});
}