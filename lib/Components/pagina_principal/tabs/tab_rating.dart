// tab_rating.dart
import 'package:flutter/material.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/Login/texto_normal.dart';
import 'package:ja_rating/Components/CustomProductImage.dart';
import 'package:ja_rating/Paginas/pagina_rating_detalle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TabRating extends StatefulWidget {
  final List<Map<String, dynamic>> todosLosProductos;

  const TabRating({super.key, required this.todosLosProductos});

  @override
  State<TabRating> createState() => _TabRatingState();
}

class _TabRatingState extends State<TabRating> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _animes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _filtrarAnimes();
  }

  void _filtrarAnimes() {
    // Solo mostrar los productos que son de tipo 'Anime'
    final animes = widget.todosLosProductos
        .where((item) => item['tipo'] == 'Anime')
        .toList();
    setState(() {
      _animes = animes;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final double padding = anchoPantalla > 800 ? 40 : 20;
    final int columnas = anchoPantalla > 800 ? 4 : 2;
    final double anchoCarta =
        (anchoPantalla - (padding * 2) - (columnas - 1) * 14) / columnas;
    final double altoCarta = anchoCarta * 1.4;

    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_animes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            TextoNormal(
              contingutText: 'No hay animes disponibles',
              fontSize: 16,
              colorText: Coloresapp.colorTextoFlojo,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnas,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: anchoCarta / altoCarta,
      ),
      itemCount: _animes.length,
      itemBuilder: (context, index) {
        final anime = _animes[index];
        return _CardRating(
          anime: anime,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaginaRatingDetalle(anime: anime),
              ),
            );
            if (result == true) {
              // Si se actualizó la puntuación, refrescamos (opcional)
              setState(() {});
            }
          },
        );
      },
    );
  }
}

class _CardRating extends StatelessWidget {
  final Map<String, dynamic> anime;
  final VoidCallback onTap;

  const _CardRating({required this.anime, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            CustomProductImage(
              malId: anime['malId'] ?? 0,
              originalUrl: anime['img'] ?? '',
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
            // Título y puntuación
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anime['titulo'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'HoshikoSatsuki',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Aquí podríamos mostrar la puntuación media, pero la cargaremos dentro
                  _PuntuacionMedia(animeId: anime['malId'] ?? 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PuntuacionMedia extends StatelessWidget {
  final int animeId;

  const _PuntuacionMedia({required this.animeId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ratings')
          .where('animeId', isEqualTo: animeId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text(
            'Sin valoraciones',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          );
        }
        double total = 0;
        for (var doc in docs) {
          total += (doc.data() as Map<String, dynamic>)['puntuacion'] ?? 0;
        }
        final media = total / docs.length;
        return Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final double valor = media - i;
                if (valor >= 1) {
                  return const Icon(Icons.star_rounded, size: 12, color: Coloresapp.colorPrimario);
                } else if (valor > 0) {
                  return const Icon(Icons.star_half_rounded, size: 12, color: Coloresapp.colorPrimario);
                } else {
                  return const Icon(Icons.star_outline_rounded, size: 12, color: Colors.grey);
                }
              }),
            ),
            const SizedBox(width: 4),
            Text(
              media.toStringAsFixed(1),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text(
              '(${docs.length})',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}