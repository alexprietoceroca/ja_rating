// pagina_producto.dart
import 'package:flutter/material.dart';
import 'package:ja_rating/coloresApp.dart';
import 'package:ja_rating/Components/Login/texto_normal.dart';
import 'package:ja_rating/Components/Login/texto_titulo.dart'; // <-- NUEVO

class PaginaProducto extends StatelessWidget {
  final Map<String, dynamic> producto;

  const PaginaProducto({super.key, required this.producto});

  Color get colorTipo {
    switch (producto['tipo']) {
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

  @override
  Widget build(BuildContext context) {
    final bool esWeb = MediaQuery.of(context).size.width > 800;
    final double padding = esWeb ? 40 : 20;

    return Scaffold(
      backgroundColor: Coloresapp.colorFondo,
      body: CustomScrollView(
        slivers: [
          // ── CABECERA CON IMAGEN ──
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: colorTipo,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    producto['img'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: colorTipo),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          colorTipo.withOpacity(0.95),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: padding,
                    right: padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            producto['tipo'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'HoshikoSatsuki',
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          producto['titulo'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'HoshikoSatsuki',
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          producto['tituloIngles'] ?? '',
                          style: TextStyle(
                            fontFamily: 'HoshikoSatsuki',
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── CONTENIDO ──
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: esWeb
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _ColumnaIzquierda(producto: producto, colorTipo: colorTipo)),
                        const SizedBox(width: 32),
                        Expanded(flex: 2, child: _ColumnaDerecha(producto: producto, colorTipo: colorTipo)),
                      ],
                    )
                  : Column(
                      children: [
                        _ColumnaIzquierda(producto: producto, colorTipo: colorTipo),
                        const SizedBox(height: 24),
                        _ColumnaDerecha(producto: producto, colorTipo: colorTipo),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColumnaIzquierda extends StatelessWidget {
  final Map<String, dynamic> producto;
  final Color colorTipo;

  const _ColumnaIzquierda({required this.producto, required this.colorTipo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Puntuación grande ──
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Coloresapp.colorBlanco,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Coloresapp.colorSombraCard, blurRadius: 12),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.star_rounded, color: colorTipo, size: 40),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (producto['puntuacion'] as double).toStringAsFixed(1),
                    style: TextStyle(
                      fontFamily: 'HoshikoSatsuki',
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: colorTipo,
                    ),
                  ),
                  TextoNormal(
                    contingutText: 'de 5.0',
                    fontSize: 12,
                    colorText: Coloresapp.colorTextoFlojo,
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(5, (i) {
                  final double v = (producto['puntuacion'] as double) - (4 - i);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      children: [
                        TextoNormal(
                          contingutText: '${5 - i}',
                          fontSize: 10,
                          colorText: Coloresapp.colorTextoFlojo,
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.star_rounded,
                            size: 12,
                            color: colorTipo.withOpacity(0.4 + (i * 0.15))),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Sinopsis ──
        const TextoTitulo(
          contingutText: 'Sinopsis',
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Coloresapp.colorBlanco,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Coloresapp.colorSombraCard, blurRadius: 12),
            ],
          ),
          child: TextoNormal(
            contingutText: producto['descripcion'] ?? '',
            fontSize: 13,
            colorText: Coloresapp.colorTexto,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 20),

        // ── Géneros ──
        const TextoTitulo(
          contingutText: 'Géneros',
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ((producto['generos'] as List<String>?) ?? [producto['genero'] as String])
              .map((g) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: colorTipo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorTipo.withOpacity(0.3)),
                    ),
                    child: TextoNormal(
                      contingutText: g,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      colorText: colorTipo,
                    ),
                  ))
              .toList(),
        ),

        const SizedBox(height: 20),

        // ── Comentarios ──
        const TextoTitulo(
          contingutText: 'Comentarios',
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
        const SizedBox(height: 10),
        ..._comentariosFicticios(colorTipo),
      ],
    );
  }

  List<Widget> _comentariosFicticios(Color color) {
    final comentarios = [
      {'usuario': 'Akira_Fan', 'nota': 5.0, 'texto': 'Una obra maestra absoluta. Cada capítulo te deja con ganas de más.'},
      {'usuario': 'MangaLover92', 'nota': 4.5, 'texto': 'El arte es increíble y la historia engancha desde el primer momento.'},
      {'usuario': 'OtakuPro', 'nota': 4.0, 'texto': 'Muy buena historia aunque algunos arcos son algo lentos.'},
    ];

    return comentarios.map((c) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Coloresapp.colorBlanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Coloresapp.colorSombraCard, blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withOpacity(0.15),
                child: TextoTitulo(
                  contingutText: (c['usuario'] as String)[0].toUpperCase(),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  colorText: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextoTitulo(
                  contingutText: c['usuario'] as String,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < (c['nota'] as double).round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 12,
                  color: color,
                )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextoNormal(
            contingutText: c['texto'] as String,
            fontSize: 12,
            colorText: Coloresapp.colorTextoFlojo,
            height: 1.5,
          ),
        ],
      ),
    )).toList();
  }
}

class _ColumnaDerecha extends StatelessWidget {
  final Map<String, dynamic> producto;
  final Color colorTipo;

  const _ColumnaDerecha({required this.producto, required this.colorTipo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Coloresapp.colorBlanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Coloresapp.colorSombraCard, blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextoTitulo(
            contingutText: 'Información',
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
          const SizedBox(height: 16),
          _FilaDetalle(
            icono: Icons.person_outline_rounded,
            etiqueta: 'Autor',
            valor: producto['autor'] ?? 'Desconocido',
            color: colorTipo,
          ),
          _Divider(),
          _FilaDetalle(
            icono: Icons.business_rounded,
            etiqueta: _etiquetaEstudio(producto['tipo']),
            valor: producto['estudio'] ?? 'Desconocido',
            color: colorTipo,
          ),
          _Divider(),
          _FilaDetalle(
            icono: Icons.calendar_today_rounded,
            etiqueta: 'Año',
            valor: producto['anio']?.toString() ?? 'Desconocido',
            color: colorTipo,
          ),
          _Divider(),
          _FilaDetalle(
            icono: Icons.people_outline_rounded,
            etiqueta: 'Demografía',
            valor: producto['demografia'] ?? 'Shounen',
            color: colorTipo,
          ),
          _Divider(),
          _FilaDetalle(
            icono: Icons.format_list_numbered_rounded,
            etiqueta: _etiquetaEpisodios(producto['tipo']),
            valor: producto['episodios']?.toString() ?? '?',
            color: colorTipo,
          ),
          _Divider(),
          _FilaDetalle(
            icono: Icons.public_rounded,
            etiqueta: 'Título original',
            valor: producto['tituloOriginal'] ?? '',
            color: colorTipo,
          ),
        ],
      ),
    );
  }

  String _etiquetaEstudio(String? tipo) {
    switch (tipo) {
      case 'Anime':
      case 'Donghua':
        return 'Estudio';
      case 'Manga':
        return 'Editorial';
      default:
        return 'Publicado en';
    }
  }

  String _etiquetaEpisodios(String? tipo) {
    switch (tipo) {
      case 'Anime':
      case 'Donghua':
        return 'Episodios';
      default:
        return 'Capítulos';
    }
  }
}

class _FilaDetalle extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final Color color;

  const _FilaDetalle({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextoNormal(
                  contingutText: etiqueta,
                  fontSize: 10,
                  colorText: Coloresapp.colorTextoFlojo,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 2),
                TextoTitulo(
                  contingutText: valor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: Coloresapp.colorTextoFlojo.withOpacity(0.1),
    );
  }
}