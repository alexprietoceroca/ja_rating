import 'package:flutter/material.dart';
import 'package:ja_rating/coloresApp.dart';

class ProductosCarta extends StatelessWidget {
  final String titulo;
  final String genero;
  final String tipo;
  final double puntuacion;
  final String urlImagen;

  const ProductosCarta({
    super.key,
    required this.titulo,
    required this.genero,
    required this.tipo,
    required this.puntuacion,
    required this.urlImagen,
  });

  Color get colorTipo {
    switch (tipo) {
      case 'Anime': return Coloresapp.colorPrimario;
      case 'Manga': return Coloresapp.colorContorno;
      case 'Manhwa': return Coloresapp.colorMorado;
      case 'Manhua': return Coloresapp.colorVerde;
      case 'Donghua': return Coloresapp.colorNaranja;
      default: return Coloresapp.colorPrimario;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  urlImagen,
                  height: 200,
                  width: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    width: 160,
                    color: Coloresapp.colorPrimario,
                    child: const Icon(Icons.image_not_supported_rounded, color: Colors.white, size: 40),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorTipo,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tipo.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111111),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  genero,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Coloresapp.colorTextoFlojo,
                  ),
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

class _EstrellasPuntuacion extends StatelessWidget {
  final double puntuacion;
  const _EstrellasPuntuacion({required this.puntuacion});

  @override
  Widget build(BuildContext context) {
    final int estrellas = (puntuacion / 2).round();
    return Row(
      children: [
        ...List.generate(
          5,
          (i) => Icon(
            i < estrellas ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 14,
            color: i < estrellas ? Coloresapp.colorPrimario : Colors.grey.shade300,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          puntuacion.toString(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Coloresapp.colorTexto,
          ),
        ),
      ],
    );
  }
}