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

class _TabRatingState extends State<TabRating> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _animes = [];
  List<Map<String, dynamic>> _mangas = [];
  List<Map<String, dynamic>> _manhwas = [];
  List<Map<String, dynamic>> _donghuas = [];
  List<Map<String, dynamic>> _novelas = []; // NUEVA LISTA PARA NOVELAS
  bool _cargando = true;

  final List<String> _tipos = ['Anime', 'Manga', 'Manhwa', 'Donghua', 'Novela']; // AÑADIDA 'Novela'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tipos.length, vsync: this);
    _clasificarProductos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _clasificarProductos() {
    final animes = <Map<String, dynamic>>[];
    final mangas = <Map<String, dynamic>>[];
    final manhwas = <Map<String, dynamic>>[];
    final donghuas = <Map<String, dynamic>>[];
    final novelas = <Map<String, dynamic>>[];

    for (var item in widget.todosLosProductos) {
      final tipo = item['tipo'] as String? ?? '';
      if (tipo == 'Anime') {
        animes.add(item);
      } else if (tipo == 'Manga') {
        mangas.add(item);
      } else if (tipo == 'Manhwa') {
        manhwas.add(item);
      } else if (tipo == 'Donghua') {
        donghuas.add(item);
      } else if (tipo == 'Novela' || tipo == 'Light Novel' || tipo == 'Novel') {
        // Acepta variantes de novela
        novelas.add(item);
      }
    }

    setState(() {
      _animes = animes;
      _mangas = mangas;
      _manhwas = manhwas;
      _donghuas = donghuas;
      _novelas = novelas;
      _cargando = false;
    });
  }

  List<Map<String, dynamic>> _getProductosPorTipo(int index) {
    switch (index) {
      case 0: return _animes;
      case 1: return _mangas;
      case 2: return _manhwas;
      case 3: return _donghuas;
      case 4: return _novelas;
      default: return [];
    }
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
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: _tipos.asMap().entries.map((entry) {
          final productos = _getProductosPorTipo(entry.key);
          if (productos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  TextoNormal(
                    contingutText: 'No hay ${_tipos[entry.key]} disponibles',
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
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final item = productos[index];
              return _CardRating(
                anime: item, // El nombre del parámetro sigue siendo "anime" aunque sea novela
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaginaRatingDetalle(anime: item),
                    ),
                  );
                  if (result == true) {
                    setState(() {});
                  }
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'JA_Rating',
        style: TextStyle(
          fontFamily: 'HoshikoSatsuki',
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Coloresapp.colorPrimario,
      centerTitle: true,
      elevation: 0,
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: _tipos.map((tipo) => Tab(text: tipo)).toList(),
      ),
    );
  }
}

// ========== WIDGETS AUXILIARES (sin cambios, pero los renombro para generalidad) ==========
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
            CustomProductImage(
              malId: anime['malId'] ?? 0,
              originalUrl: anime['img'] ?? '',
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
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