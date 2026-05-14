// pagina_rating_detalle.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/Login/texto_normal.dart';
import 'package:ja_rating/Components/CustomProductImage.dart';

class PaginaRatingDetalle extends StatefulWidget {
  final Map<String, dynamic> anime;

  const PaginaRatingDetalle({super.key, required this.anime});

  @override
  State<PaginaRatingDetalle> createState() => _PaginaRatingDetalleState();
}

class _PaginaRatingDetalleState extends State<PaginaRatingDetalle> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _puntuacion = 0;
  final TextEditingController _comentarioController = TextEditingController();
  bool _cargando = true;
  String? _ratingId;
  DocumentReference? _ratingRef;

  @override
  void initState() {
    super.initState();
    _cargarRatingUsuario();
  }

  Future<void> _cargarRatingUsuario() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _cargando = false);
      return;
    }

    final query = await _firestore
        .collection('ratings')
        .where('animeId', isEqualTo: widget.anime['malId'])
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      _ratingId = doc.id;
      _ratingRef = doc.reference;
      setState(() {
        _puntuacion = (doc.data()['puntuacion'] ?? 0).toDouble();
        _comentarioController.text = doc.data()['comentario'] ?? '';
        _cargando = false;
      });
    } else {
      setState(() => _cargando = false);
    }
  }

  Future<void> _guardarRating() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para valorar')),
      );
      return;
    }

    if (_puntuacion == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una puntuación')),
      );
      return;
    }

    setState(() => _cargando = true);
    try {
      final data = {
        'animeId': widget.anime['malId'],
        'animeTitulo': widget.anime['titulo'],
        'animeImagen': widget.anime['img'],
        'userId': user.uid,
        'userName': user.displayName ?? user.email?.split('@')[0] ?? 'Usuario',
        'puntuacion': _puntuacion,
        'comentario': _comentarioController.text.trim(),
        'fecha': DateTime.now(),
      };

      if (_ratingRef == null) {
        await _firestore.collection('ratings').add(data);
      } else {
        await _ratingRef!.update(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Valoración guardada')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error guardando rating: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _eliminarRating() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar valoración'),
        content: const Text('¿Estás seguro de que quieres eliminar tu valoración?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _cargando = true);
    try {
      if (_ratingRef != null) {
        await _ratingRef!.delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Valoración eliminada')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('Error eliminando rating: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esWeb = MediaQuery.of(context).size.width > 800;
    final double padding = esWeb ? 40 : 20;

    return Scaffold(
      backgroundColor: Coloresapp.colorFondo,
      appBar: AppBar(
        title: Text(widget.anime['titulo'] ?? 'Detalle'),
        backgroundColor: Coloresapp.colorPrimario,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen del anime
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomProductImage(
                        malId: widget.anime['malId'] ?? 0,
                        originalUrl: widget.anime['img'] ?? '',
                        width: esWeb ? 300 : 200,
                        height: esWeb ? 400 : 280,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título y tipo
                  Text(
                    widget.anime['titulo'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'HoshikoSatsuki',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextoNormal(
                    contingutText: widget.anime['tipo'] ?? 'Anime',
                    fontSize: 14,
                    colorText: Coloresapp.colorPrimario,
                  ),
                  const SizedBox(height: 20),

                  // Sistema de estrellas
                  const Text(
                    'Tu puntuación',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      final int estrella = i + 1;
                      return IconButton(
                        onPressed: () => setState(() => _puntuacion = estrella as double),
                        icon: Icon(
                          estrella <= _puntuacion ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 40,
                          color: Coloresapp.colorPrimario,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Campo de comentario
                  const Text(
                    'Comentario (opcional)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _comentarioController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu opinión sobre este anime...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _guardarRating,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Guardar valoración'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Coloresapp.colorVerde,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      if (_ratingRef != null) ...[
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: _eliminarRating,
                          icon: const Icon(Icons.delete_rounded),
                          label: const Text('Eliminar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Lista de valoraciones de la comunidad
                  const Text(
                    'Valoraciones de la comunidad',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _ListaComentarios(animeId: widget.anime['malId'] ?? 0),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }
}

class _ListaComentarios extends StatelessWidget {
  final int animeId;

  const _ListaComentarios({required this.animeId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ratings')
          .where('animeId', isEqualTo: animeId)
          .orderBy('fecha', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No hay valoraciones aún. ¡Sé el primero!'),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final fecha = (data['fecha'] as Timestamp).toDate();
            return _ComentarioCard(
              usuario: data['userName'] ?? 'Anónimo',
              puntuacion: (data['puntuacion'] ?? 0).toDouble(),
              comentario: data['comentario'] ?? '',
              fecha: fecha,
            );
          },
        );
      },
    );
  }
}

class _ComentarioCard extends StatelessWidget {
  final String usuario;
  final double puntuacion;
  final String comentario;
  final DateTime fecha;

  const _ComentarioCard({
    required this.usuario,
    required this.puntuacion,
    required this.comentario,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Coloresapp.colorPrimario.withOpacity(0.1),
                child: Text(
                  usuario.isNotEmpty ? usuario[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontFamily: 'HoshikoSatsuki',
                    fontWeight: FontWeight.bold,
                    color: Coloresapp.colorPrimario,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${fecha.day}/${fecha.month}/${fecha.year}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < puntuacion ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 12,
                    color: Coloresapp.colorPrimario,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comentario,
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}