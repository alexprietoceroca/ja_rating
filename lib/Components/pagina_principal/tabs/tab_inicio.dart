import 'package:flutter/material.dart';
import 'package:ja_rating/Components/pagina_principal/widgets/cabecera_hero.dart';
import 'package:ja_rating/Components/pagina_principal/widgets/seccion_con_scroll.dart';

class TabInicio extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CabeceraHero(esWeb: esWeb),
          const SizedBox(height: 24),
          SeccionConScroll(
            titulo: 'En Tendencia',
            etiqueta: 'HOT',
            icono: Icons.local_fire_department_rounded,
            items: tendencias,
            esWeb: esWeb,
          ),
          const SizedBox(height: 28),
          SeccionConScroll(
            titulo: 'Populares esta semana',
            subtitulo: 'Los favoritos de la comunidad',
            icono: Icons.trending_up_rounded,
            items: populares,
            esWeb: esWeb,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}