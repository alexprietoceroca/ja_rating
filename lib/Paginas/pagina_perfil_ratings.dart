// pagina_perfil_ratings.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/CustomProductImage.dart';
import 'package:ja_rating/Components/Login/texto_normal.dart';
import 'package:ja_rating/Paginas/pagina_foro.dart';

class PaginaPerfilRatings extends StatefulWidget {
  final int initialTab;
  const PaginaPerfilRatings({super.key, this.initialTab = 0});

  @override
  State<PaginaPerfilRatings> createState() => _PaginaPerfilRatingsState();
}

class _PaginaPerfilRatingsState extends State<PaginaPerfilRatings>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<String> _tabs = ['Calificaciones', 'Comentarios', 'Tier Lists', 'Favoritos'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, _tabs.length - 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: Text('Debes iniciar sesión')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RatingsList(userId: user.uid),
          _ComentariosList(userId: user.uid),
          _TierListsList(userId: user.uid),
          _FavoritosList(userId: user.uid),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Mi actividad'),
      backgroundColor: Coloresapp.colorPrimario,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}

// ----------------------------- CALIFICACIONES -----------------------------
class _RatingsList extends StatelessWidget {
  final String userId;
  const _RatingsList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('ratings')
          .where('userId', isEqualTo: userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No has calificado ningún anime'));
        }
        final docs = snapshot.data!.docs;
        docs.sort((a, b) {
          final aDate = (a.data() as Map<String, dynamic>)['fecha'] as Timestamp;
          final bDate = (b.data() as Map<String, dynamic>)['fecha'] as Timestamp;
          return bDate.compareTo(aDate);
        });
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final rating = {
              'animeId': data['animeId'],
              'animeTitulo': data['animeTitulo'] ?? 'Sin título',
              'animeImagen': data['animeImagen'] ?? '',
              'puntuacion': (data['puntuacion'] ?? 0).toDouble(),
              'comentario': data['comentario'] ?? '',
              'fecha': (data['fecha'] as Timestamp).toDate(),
            };
            return _CardRatingPerfil(rating: rating);
          },
        );
      },
    );
  }
}

class _CardRatingPerfil extends StatelessWidget {
  final Map<String, dynamic> rating;
  const _CardRatingPerfil({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomProductImage(
              malId: rating['animeId'] ?? 0,
              originalUrl: rating['animeImagen'] ?? '',
              width: 80,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rating['animeTitulo'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(5, (i) {
                    final estrella = i + 1;
                    if (estrella <= rating['puntuacion']) {
                      return const Icon(Icons.star_rounded, size: 16, color: Coloresapp.colorPrimario);
                    } else if (estrella - 0.5 <= rating['puntuacion']) {
                      return const Icon(Icons.star_half_rounded, size: 16, color: Coloresapp.colorPrimario);
                    } else {
                      return const Icon(Icons.star_outline_rounded, size: 16, color: Colors.grey);
                    }
                  }),
                ),
                const SizedBox(height: 6),
                if (rating['comentario'].isNotEmpty)
                  Text(rating['comentario'], style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2),
                const SizedBox(height: 4),
                Text(_formatearFecha(rating['fecha']), style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inDays > 0) return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
    if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes} minuto${diff.inMinutes > 1 ? 's' : ''}';
    return 'Justo ahora';
  }
}

// ----------------------------- COMENTARIOS -----------------------------
class _ComentariosList extends StatelessWidget {
  final String userId;
  const _ComentariosList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collectionGroup('comentarios')
          .where('autorId', isEqualTo: userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          // Mostrar mensaje amigable si hay error (por ejemplo, falta índice)
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                const Text('Error al cargar los comentarios'),
                const SizedBox(height: 8),
                Text(snapshot.error.toString(), textAlign: TextAlign.center),
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No has hecho ningún comentario'));
        }
        final docs = snapshot.data!.docs;
        // Ordenar en cliente para no necesitar índice
        docs.sort((a, b) {
          final aDate = (a.data() as Map<String, dynamic>)['fecha'] as Timestamp;
          final bDate = (b.data() as Map<String, dynamic>)['fecha'] as Timestamp;
          return bDate.compareTo(aDate);
        });
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            // Obtener el ID del foro desde la referencia del documento
            final foroRef = docs[i].reference.parent.parent;
            if (foroRef == null) return const SizedBox.shrink();
            final foroId = foroRef.id;
            return _CardComentario(
              foroId: foroId,
              comentario: data['contenido'] ?? '',
              fecha: (data['fecha'] as Timestamp).toDate(),
              autor: data['autor'] ?? 'Usuario',
            );
          },
        );
      },
    );
  }
}

class _CardComentario extends StatelessWidget {
  final String foroId;
  final String comentario;
  final DateTime fecha;
  final String autor;
  const _CardComentario({required this.foroId, required this.comentario, required this.fecha, required this.autor});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('foros').doc(foroId).get(),
      builder: (context, snapshot) {
        String tituloForo = 'Cargando...';
        if (snapshot.hasData && snapshot.data!.exists) {
          tituloForo = (snapshot.data!.data() as Map<String, dynamic>)['titulo'] ?? 'Foro desconocido';
        }
        return GestureDetector(
          onTap: () async {
            final doc = await FirebaseFirestore.instance.collection('foros').doc(foroId).get();
            if (doc.exists) {
              final foro = {
                'id': doc.id,
                ...doc.data()!,
                'fecha': (doc.data()!['fecha'] as Timestamp).toDate(),
              };
              if (context.mounted) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => PaginaDetalleForo(foro: foro)));
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tituloForo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(comentario, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(autor, style: const TextStyle(fontSize: 10)),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(_formatearFecha(fecha), style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatearFecha(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inDays > 0) return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
    return 'Hace ${diff.inMinutes} min';
  }
}

// ----------------------------- TIER LISTS -----------------------------
class _TierListsList extends StatelessWidget {
  final String userId;
  const _TierListsList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('tierlists_comunidad')
          .where('ownerId', isEqualTo: userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No has creado ninguna Tier List'));
        }
        final docs = snapshot.data!.docs;
        docs.sort((a, b) {
          final aDate = (a.data() as Map<String, dynamic>)['fecha'] as Timestamp? ?? Timestamp.now();
          final bDate = (b.data() as Map<String, dynamic>)['fecha'] as Timestamp? ?? Timestamp.now();
          return bDate.compareTo(aDate);
        });
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final titulo = data['titulo'] ?? 'Sin título';
            final fecha = data['fecha'] != null ? (data['fecha'] as Timestamp).toDate() : DateTime.now();
            final likes = data['likes'] ?? 0;
            return _CardTierList(titulo: titulo, fecha: fecha, likes: likes);
          },
        );
      },
    );
  }
}

class _CardTierList extends StatelessWidget {
  final String titulo;
  final DateTime fecha;
  final int likes;
  const _CardTierList({required this.titulo, required this.fecha, required this.likes});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente: detalle de Tier List')));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Coloresapp.colorPrimario),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$likes likes', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(_formatearFecha(fecha), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inDays > 0) return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
    return 'Hace ${diff.inMinutes} min';
  }
}

// ----------------------------- FAVORITOS -----------------------------
class _FavoritosList extends StatelessWidget {
  final String userId;
  const _FavoritosList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('favoritos_foros')
          .where('userId', isEqualTo: userId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No tienes foros favoritos'));
        }
        final docs = snapshot.data!.docs;
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.wait(docs.map((doc) async {
            final foroId = doc['foroId'] as String;
            final foroDoc = await FirebaseFirestore.instance.collection('foros').doc(foroId).get();
            if (foroDoc.exists) {
              return {
                'id': foroId,
                ...foroDoc.data()!,
                'fecha': (foroDoc.data()!['fecha'] as Timestamp).toDate(),
              };
            }
            return null;
          }).where((f) => f != null).cast<Future<Map<String, dynamic>>>()),
          builder: (context, forosSnapshot) {
            if (forosSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final foros = forosSnapshot.data ?? [];
            if (foros.isEmpty) {
              return const Center(child: Text('No se encontraron foros favoritos'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: foros.length,
              itemBuilder: (_, i) => _CardForoFavorito(foro: foros[i]),
            );
          },
        );
      },
    );
  }
}

class _CardForoFavorito extends StatelessWidget {
  final Map<String, dynamic> foro;
  const _CardForoFavorito({required this.foro});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PaginaDetalleForo(foro: foro)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            const Icon(Icons.forum, color: Coloresapp.colorPrimario),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(foro['titulo'] ?? 'Sin título', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(foro['categoria'] ?? 'General', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('${foro['respuestas']} respuestas · ${foro['vistas']} vistas', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}