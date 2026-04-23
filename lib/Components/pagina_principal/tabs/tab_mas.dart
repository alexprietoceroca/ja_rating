// tab_mas.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/Login/texto_normal.dart';
import 'package:ja_rating/Paginas/pagina_tierlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ja_rating/Paginas/pagina_login.dart';

class TabMas extends StatefulWidget {
  final List<Map<String, dynamic>> todosLosProductos;
  const TabMas({super.key, required this.todosLosProductos});

  @override
  State<TabMas> createState() => _TabMasState();
}

class _TabMasState extends State<TabMas> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController _dragController;

  @override
  void initState() {
    super.initState();
    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final double padding = anchoPantalla > 800 ? 40 : 20;

    final List<Map<String, dynamic>> foros = [
      {'titulo': '¿Cuál es el mejor arco de One Piece?', 'respuestas': 42, 'destacado': true},
      {'titulo': 'Teorías sobre Jujutsu Kaisen final', 'respuestas': 87, 'destacado': true},
      {'titulo': 'Top manhwas para empezar en 2025', 'respuestas': 23, 'destacado': false},
      {'titulo': 'Dandadan vs Chainsaw Man', 'respuestas': 61, 'destacado': false},
    ];

    return Stack(
      children: [
        // Fondo blanco
        Container(color: Colors.white),
        // Dragón animado (en blanco y negro)
        AnimatedBuilder(
          animation: _dragController,
          builder: (context, child) {
            return CustomPaint(
              painter: _DragonBlancoNegroPainter(_dragController.value),
              size: Size.infinite,
            );
          },
        ),
        // Contenido principal
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera con logo, título y logout (colores oscuros para contraste)
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/imagenes/logo.png',
                        width: 40,
                        height: 40,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Coloresapp.colorTexto),
                      ),
                      const Spacer(),
                      TextoNormal(
                        contingutText: 'Más',
                        colorText: Coloresapp.colorTexto,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Coloresapp.colorTexto),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const PaginaLogin()),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PaginaTierlist(todosLosProductos: widget.todosLosProductos)),
                          );
                        },
                        child: _CartaFuncionalidad(
                          icono: Icons.emoji_events_rounded,
                          etiqueta: 'Tier Lists',
                          descripcion: 'Crea y comparte tus rankings',
                          color: Coloresapp.colorNaranja,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _CartaFuncionalidad(
                        icono: Icons.forum_rounded,
                        etiqueta: 'Foros',
                        descripcion: 'Discute con la comunidad',
                        color: Coloresapp.colorMorado,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Foros populares',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Coloresapp.colorCasiNegro),
                ),
                const SizedBox(height: 12),
                ...foros.map(
                  (f) => _ItemForo(
                    titulo: f['titulo'] as String,
                    respuestas: f['respuestas'] as int,
                    destacado: f['destacado'] as bool,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DragonBlancoNegroPainter extends CustomPainter {
  final double t; // tiempo de animación (0 a 1)
  _DragonBlancoNegroPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar dragón más arriba (por ejemplo, centrado verticalmente en el tercio superior)
    final centerY = size.height * 0.25; // más arriba
    final cuerpoY = centerY;
    final amplitud = 25.0;
    final longitudOnda = size.width * 0.8;
    final inicioX = size.width * 0.1 - t * 200; // se desplaza hacia la derecha

    final paintNegro = Paint()
      ..color = Coloresapp.colorCasiNegro
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Cuerpo ondulado del dragón
    final pathCuerpo = Path();
    for (double x = inicioX; x <= inicioX + longitudOnda; x += 10) {
      final y = cuerpoY + sin(x * 0.03 + t * 2 * pi) * amplitud;
      if (x == inicioX) {
        pathCuerpo.moveTo(x, y);
      } else {
        pathCuerpo.lineTo(x, y);
      }
    }
    canvas.drawPath(pathCuerpo, paintNegro);

    // Cabeza del dragón (en el extremo derecho del cuerpo)
    final cabezaX = inicioX + longitudOnda;
    final cabezaY = cuerpoY + sin(cabezaX * 0.03 + t * 2 * pi) * amplitud;
    final paintRelleno = Paint()..color = Coloresapp.colorCasiNegro;
    canvas.drawCircle(Offset(cabezaX, cabezaY), 12, paintRelleno);

    // Ojo (blanco)
    final paintOjo = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cabezaX + 4, cabezaY - 4), 3, paintOjo);
    // Pupila (negra)
    canvas.drawCircle(Offset(cabezaX + 5, cabezaY - 5), 1.5, paintNegro);

    // Cuernos
    final pathCuerno = Path();
    pathCuerno.moveTo(cabezaX - 2, cabezaY - 12);
    pathCuerno.lineTo(cabezaX - 8, cabezaY - 22);
    pathCuerno.lineTo(cabezaX + 2, cabezaY - 16);
    canvas.drawPath(pathCuerno, paintRelleno);

    // Bigotes
    final pathBigote = Path();
    pathBigote.moveTo(cabezaX - 5, cabezaY + 5);
    pathBigote.quadraticBezierTo(cabezaX - 15, cabezaY + 15, cabezaX - 25, cabezaY + 10);
    canvas.drawPath(pathBigote, paintNegro);

    // Escamas (pequeños círculos a lo largo del cuerpo)
    final paintEscama = Paint()..color = Coloresapp.colorGris600;
    for (double x = inicioX + 20; x <= inicioX + longitudOnda - 20; x += 30) {
      final yEsc = cuerpoY + sin(x * 0.03 + t * 2 * pi) * amplitud - 8;
      canvas.drawCircle(Offset(x, yEsc), 3, paintEscama);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ---------------------------------------------------------------------
// Los widgets _CartaFuncionalidad y _ItemForo son los mismos que antes
// (usando Coloresapp.colorBlanco, etc.)
// ---------------------------------------------------------------------
class _CartaFuncionalidad extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String descripcion;
  final Color color;
  const _CartaFuncionalidad({required this.icono, required this.etiqueta, required this.descripcion, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Coloresapp.colorBlanco,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
            child: Icon(icono, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Coloresapp.colorCasiNegro)),
          const SizedBox(height: 4),
          Text(descripcion, style: const TextStyle(fontSize: 12, color: Coloresapp.colorTextoFlojo, height: 1.4)),
        ],
      ),
    );
  }
}

class _ItemForo extends StatelessWidget {
  final String titulo;
  final int respuestas;
  final bool destacado;
  const _ItemForo({required this.titulo, required this.respuestas, required this.destacado});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Coloresapp.colorBlanco,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (destacado)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Coloresapp.colorPrimario.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.local_fire_department_rounded, size: 12, color: Coloresapp.colorPrimario),
                        SizedBox(width: 3),
                        Text('HOT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Coloresapp.colorPrimario)),
                      ],
                    ),
                  ),
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Coloresapp.colorCasiNegro, height: 1.3)),
                const SizedBox(height: 4),
                Text('$respuestas respuestas', style: const TextStyle(fontSize: 11, color: Coloresapp.colorTextoFlojo)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Coloresapp.colorTextoFlojo),
        ],
      ),
    );
  }
}