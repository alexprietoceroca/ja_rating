// tab_mas.dart
import 'package:flutter/material.dart';
import 'package:ja_rating/coloresApp.dart';
import 'package:ja_rating/Components/Login/texto_normal.dart';
import 'package:ja_rating/Paginas/pagina_tierlist.dart'; // <-- AÑADIDO

class TabMas extends StatelessWidget {
  final List<Map<String, dynamic>> todosLosProductos; // <-- NUEVO PARÁMETRO

  const TabMas({super.key, required this.todosLosProductos});

  @override
  Widget build(BuildContext context) {
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final double padding = anchoPantalla > 800 ? 40 : 20;

    final List<Map<String, dynamic>> foros = [
      {'titulo': '¿Cuál es el mejor arco de One Piece?', 'respuestas': 42, 'destacado': true},
      {'titulo': 'Teorías sobre Jujutsu Kaisen final', 'respuestas': 87, 'destacado': true},
      {'titulo': 'Top manhwas para empezar en 2025', 'respuestas': 23, 'destacado': false},
      {'titulo': 'Dandadan vs Chainsaw Man', 'respuestas': 61, 'destacado': false},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextoNormal(contingutText: 'Más'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaginaTierlist(todosLosProductos: todosLosProductos),
                        ),
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111111)),
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
    );
  }
}

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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF111111))),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
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
                        Text('HOT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Coloresapp.colorPrimario, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF111111), height: 1.3)),
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