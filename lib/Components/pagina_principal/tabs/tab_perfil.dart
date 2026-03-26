import 'package:flutter/material.dart';
import 'package:ja_rating/coloresApp.dart';
import 'package:ja_rating/components/Login/texto_normal.dart';

class TabPerfil extends StatelessWidget {
  const TabPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final double padding = anchoPantalla > 800 ? 40 : 20;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextoNormal(contingutText: 'Mi Perfil'),
            const SizedBox(height: 20),
            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Coloresapp.colorPrimario,
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Akira_Fan',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111111)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Miembro desde 2023',
                      style: TextStyle(fontSize: 13, color: Coloresapp.colorTextoFlojo),
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
            _ItemMenuPerfil(icono: Icons.star_rounded, etiqueta: 'Mis calificaciones', sub: '47 títulos calificados'),
            _ItemMenuPerfil(icono: Icons.chat_bubble_outline_rounded, etiqueta: 'Mis comentarios', sub: '23 comentarios'),
            _ItemMenuPerfil(icono: Icons.emoji_events_rounded, etiqueta: 'Mis Tier Lists', sub: '5 listas creadas'),
            _ItemMenuPerfil(icono: Icons.forum_rounded, etiqueta: 'Foros visitados', sub: '12 hilos activos'),
          ],
        ),
      ),
    );
  }
}

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
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Coloresapp.colorPrimario),
            ),
            const SizedBox(height: 4),
            Text(etiqueta, style: const TextStyle(fontSize: 11, color: Coloresapp.colorTextoFlojo)),
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

  const _ItemMenuPerfil({required this.icono, required this.etiqueta, required this.sub});

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
                Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF111111))),
                const SizedBox(height: 3),
                Text(sub, style: const TextStyle(fontSize: 12, color: Coloresapp.colorTextoFlojo)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Coloresapp.colorTextoFlojo),
        ],
      ),
    );
  }
}