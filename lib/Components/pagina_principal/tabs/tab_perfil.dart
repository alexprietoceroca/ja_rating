// tab_perfil.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/Login/texto_normal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ja_rating/Paginas/pagina_login.dart';

class TabPerfil extends StatefulWidget {
  const TabPerfil({super.key});

  @override
  State<TabPerfil> createState() => _TabPerfilState();
}

class _TabPerfilState extends State<TabPerfil>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _posY;
  late Animation<double> _posX;
  late Animation<double> _rotacion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: false);

    // Caída de arriba (0) a abajo (1)
    _posY = Tween<double>(
      begin: -0.1,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // Movimiento lateral ondulante
    _posX = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    // Rotación continua
    _rotacion = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final double padding = anchoPantalla > 800 ? 40 : 20;

    return Stack(
      children: [
        // Fondo base
        Container(color: Coloresapp.colorFondo),
        // Pétalo animado
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              left: (_posX.value * MediaQuery.of(context).size.width) - 20,
              top: (_posY.value * MediaQuery.of(context).size.height) - 20,
              child: Transform.rotate(
                angle: _rotacion.value,
                child: CustomPaint(
                  painter: _PetalaPainter(),
                  size: const Size(40, 40),
                ),
              ),
            );
          },
        ),
        // Contenido original
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera (igual que antes)
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/imagenes/logo.png',
                        width: 40,
                        height: 40,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image,
                          color: Coloresapp.colorTexto,
                        ),
                      ),
                      const Spacer(),
                      TextoNormal(
                        contingutText: 'Mi Perfil',
                        colorText: Coloresapp.colorTexto,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Coloresapp.colorTexto,
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaginaLogin(),
                              ),
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
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Coloresapp.colorPrimario,
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Akira_Fan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Coloresapp.colorCasiNegro,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Miembro desde 2023',
                          style: TextStyle(
                            fontSize: 13,
                            color: Coloresapp.colorTextoFlojo,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _EstadisticaPerfil(valor: '47', etiqueta: 'Calificados'),
                    const SizedBox(width: 12),
                    _EstadisticaPerfil(valor: '23', etiqueta: 'Comentarios'),
                    const SizedBox(width: 12),
                    _EstadisticaPerfil(valor: '5', etiqueta: 'Tier Lists'),
                  ],
                ),
                const SizedBox(height: 24),
                _ItemMenuPerfil(
                  icono: Icons.star_rounded,
                  etiqueta: 'Mis calificaciones',
                  sub: '47 títulos calificados',
                ),
                _ItemMenuPerfil(
                  icono: Icons.chat_bubble_outline_rounded,
                  etiqueta: 'Mis comentarios',
                  sub: '23 comentarios',
                ),
                _ItemMenuPerfil(
                  icono: Icons.emoji_events_rounded,
                  etiqueta: 'Mis Tier Lists',
                  sub: '5 listas creadas',
                ),
                _ItemMenuPerfil(
                  icono: Icons.forum_rounded,
                  etiqueta: 'Foros visitados',
                  sub: '12 hilos activos',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Painter que dibuja un pétalo de sakura
class _PetalaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Coloresapp.colorRosaClaro.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path();
    // Forma de pétalo (lágrima)
    path.moveTo(size.width / 2, 0);
    path.cubicTo(
      size.width * 0.7,
      size.height * 0.3,
      size.width,
      size.height * 0.7,
      size.width / 2,
      size.height,
    );
    path.cubicTo(
      0,
      size.height * 0.7,
      size.width * 0.3,
      size.height * 0.3,
      size.width / 2,
      0,
    );
    path.close();

    canvas.drawPath(path, paint);

    // Detalle central (vena)
    final paintLine = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final centerPath = Path();
    centerPath.moveTo(size.width / 2, 0);
    centerPath.cubicTo(
      size.width / 2,
      size.height * 0.4,
      size.width / 2,
      size.height * 0.7,
      size.width / 2,
      size.height,
    );
    canvas.drawPath(centerPath, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------
// Widgets auxiliares (EstadisticaPerfil, ItemMenuPerfil)
// ---------------------------------------------------------------------
class _EstadisticaPerfil extends StatelessWidget {
  final String valor;
  final String etiqueta;
  const _EstadisticaPerfil({required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Coloresapp.colorBlanco,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12),
          ],
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Coloresapp.colorPrimario,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 11,
                color: Coloresapp.colorTextoFlojo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemMenuPerfil extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String sub;
  const _ItemMenuPerfil({
    required this.icono,
    required this.etiqueta,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Coloresapp.colorBlanco,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Icon(icono, color: Coloresapp.colorPrimario, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Coloresapp.colorCasiNegro,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Coloresapp.colorTextoFlojo,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Coloresapp.colorTextoFlojo,
          ),
        ],
      ),
    );
  }
}
