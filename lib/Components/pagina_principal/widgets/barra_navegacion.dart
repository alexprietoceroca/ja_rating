import 'package:flutter/material.dart';
import 'package:ja_rating/coloresApp.dart';

class BarraNavegacion extends StatelessWidget {
  final int indiceSeleccionado;
  final Function(int) alSeleccionar;

  const BarraNavegacion({
    super.key,
    required this.indiceSeleccionado,
    required this.alSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> elementos = [
      {'icono': Icons.home_rounded, 'etiqueta': 'Inicio'},
      {'icono': Icons.explore_rounded, 'etiqueta': 'Descubrir'},
      {'icono': Icons.person_rounded, 'etiqueta': 'Perfil'},
      {'icono': Icons.more_horiz_rounded, 'etiqueta': 'Más'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Coloresapp.colorBlanco,
        boxShadow: [
          BoxShadow(color: Coloresapp.colorSombraNav, blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(elementos.length, (i) {
              final bool activo = indiceSeleccionado == i;
              return GestureDetector(
                onTap: () => alSeleccionar(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: activo ? Coloresapp.colorPrimario.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        elementos[i]['icono'] as IconData,
                        color: activo ? Coloresapp.colorPrimario : Coloresapp.colorTextoFlojo,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        elementos[i]['etiqueta'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: activo ? FontWeight.w800 : FontWeight.w500,
                          color: activo ? Coloresapp.colorPrimario : Coloresapp.colorTextoFlojo,
                        ),
                      ),
                      if (activo)
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Coloresapp.colorPrimario,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}