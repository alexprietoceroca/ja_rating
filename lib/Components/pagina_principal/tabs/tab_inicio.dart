import 'package:flutter/material.dart';
import 'package:ja_rating/coloresApp.dart';
import 'package:ja_rating/Components/pagina_principal/widgets/cabecera_hero.dart';
import 'package:ja_rating/Components/pagina_principal/widgets/seccion_con_scroll.dart';

class TabInicio extends StatefulWidget {
  final List<Map<String, dynamic>> tendencias;
  final List<Map<String, dynamic>> populares;
  final bool esWeb;

  const TabInicio({
    super.key,
    required this.tendencias,
    required this.populares,
    required this.esWeb,
  });

  @override
  State<TabInicio> createState() => _TabInicioState();
}

class _TabInicioState extends State<TabInicio> {
  final GlobalKey _cabeceraKey = GlobalKey();
  double _alturaCabecera = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? box =
          _cabeceraKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        setState(() => _alturaCabecera = box.size.height);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size pantalla = MediaQuery.of(context).size;

    // Brush cubre de esquina superior derecha a esquina inferior izquierda
    // Necesita ser más largo que la diagonal de la pantalla
    final double diagonal = pantalla.width * 1.5;
    final double altobrush = diagonal * 0.18;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── FONDO FIJO — gradiente diagonal ──
          Positioned.fill(
            child: CustomPaint(
              painter: _PintorGradienteDiagonal(alto: pantalla.height),
            ),
          ),

          // ── TRAMA FIJA — puntos, degradado arriba→abajo ──
          Positioned.fill(
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.transparent],
                    stops: [0.0, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Opacity(
                  opacity: 0.18,
                  child: Image.asset(
                    'assets/imagenes/puntos_comic.png',
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
          ),

          // ── BRUSH FIJO — de esquina superior derecha a esquina inferior izquierda ──
          Positioned(
            top: widget.esWeb
                ? -pantalla.height * -0.15
                : pantalla.height * 0.25,
            bottom: widget.esWeb
                ? -pantalla.height * -0.15
                : pantalla.height * 0.25,
            left: widget.esWeb ? pantalla.width * -0.15 : -pantalla.width * 0.4,
            right: widget.esWeb
                ? pantalla.width * -0.15
                : -pantalla.width * 0.4,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -0.7854,
                child: Image.asset(
                  'assets/imagenes/brush.png',
                  fit: widget.esWeb ? BoxFit.fitHeight : BoxFit.fitWidth,
                ),
              ),
            ),
          ),

          // ── CONTENIDO CON SCROLL ──
          SafeArea(
            child: ListView(
              children: [
                CabeceraHero(key: _cabeceraKey, esWeb: widget.esWeb),
                const SizedBox(height: 28),
                SeccionConScroll(
                  titulo: 'Tendencias',
                  icono: Icons.trending_up_rounded,
                  etiqueta: 'HOT',
                  items: widget.tendencias,
                  esWeb: widget.esWeb,
                ),
                const SizedBox(height: 32),
                SeccionConScroll(
                  titulo: 'Populares esta semana',
                  subtitulo: 'Los favoritos de la comunidad',
                  icono: Icons.favorite_rounded,
                  items: widget.populares,
                  esWeb: widget.esWeb,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PintorGradienteDiagonal extends CustomPainter {
  final double alto;

  _PintorGradienteDiagonal({required this.alto});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pintorA = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.center,
        colors: [Color(0xFFE9D5FF), Color(0xFFFED7AA)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Paint pintorB = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.center,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFED7AA), Color(0xFFBAE6FD)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pintorA);

    final Path pathB = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(pathB, pintorB);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
