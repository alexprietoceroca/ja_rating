import 'package:flutter/material.dart';
import 'package:ja_rating/coloresApp.dart';

class CabeceraHero extends StatelessWidget {
  final bool esWeb;
  final bool transparente;

  const CabeceraHero({
    super.key,
    required this.esWeb,
    this.transparente = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: transparente
            ? null
            : LinearGradient(
                colors: [Coloresapp.colorPrimario, Coloresapp.colorRojoOscuro],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: transparente ? Colors.transparent : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(esWeb ? 40 : 20, 20, esWeb ? 40 : 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido de vuelta',
                        style: TextStyle(
                          fontFamily: 'HoshikoSatsuki',
                          color: Coloresapp.colorBlanco.withOpacity(0.9),
                          fontSize: esWeb ? 15 : 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'JA-Rating',
                        style: TextStyle(
                          fontFamily: 'HoshikoSatsuki',
                          color: Coloresapp.colorTexto,
                          fontSize: esWeb ? 34 : 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Coloresapp.colorBlanco.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Coloresapp.colorBlanco,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _CajaEstadistica(valor: '2.4K', etiqueta: 'Títulos'),
                  const SizedBox(width: 10),
                  _CajaEstadistica(valor: '18K', etiqueta: 'Usuarios'),
                  const SizedBox(width: 10),
                  _CajaEstadistica(valor: '94K', etiqueta: 'Ratings'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CajaEstadistica extends StatelessWidget {
  final String valor;
  final String etiqueta;

  const _CajaEstadistica({required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Coloresapp.colorBlanco.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: const TextStyle(
                fontFamily: 'HoshikoSatsuki',
                color: Coloresapp.colorTexto,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: TextStyle(
                fontFamily: 'HoshikoSatsuki',
                color: Coloresapp.colorBlanco.withOpacity(0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}