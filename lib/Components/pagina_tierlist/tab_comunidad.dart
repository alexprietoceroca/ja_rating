// lib/Components/pagina_tierlist/tab_comunidad.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ja_rating/coloresApp.dart';
import 'package:ja_rating/Paginas/pagina_detalle_tierlist.dart';

class TabComunidad extends StatefulWidget {
  const TabComunidad({super.key});

  @override
  State<TabComunidad> createState() => _TabComunidadState();
}

class _TabComunidadState extends State<TabComunidad> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isLiking = false;

  String _ordenPor = 'likes';
  bool _ordenAscendente = false;

  Stream<QuerySnapshot> _getComunidadStream() {
    Query query = _firestore.collection('tierlists_comunidad');
    if (_ordenPor == 'likes') {
      query = query.orderBy('likes', descending: !_ordenAscendente);
    } else if (_ordenPor == 'fecha') {
      query = query.orderBy('timestamp', descending: !_ordenAscendente);
    } else if (_ordenPor == 'comentarios') {
      query = query.orderBy('commentsCount', descending: !_ordenAscendente);
    }
    return query.snapshots();
  }

  Future<void> _darLike(
    String docId,
    int currentLikes,
    List<dynamic> likedBy,
  ) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesion para dar like')),
      );
      return;
    }
    final uid = _currentUser!.uid;
    if (_isLiking) return;
    setState(() => _isLiking = true);
    try {
      final docRef = _firestore.collection('tierlists_comunidad').doc(docId);
      if (likedBy.contains(uid)) {
        await docRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([uid]),
        });
      } else {
        await docRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print('Error like: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLiking = false);
    }
  }

  Future<void> _eliminarPublicacion(String docId, String ownerId) async {
    if (_currentUser == null || _currentUser!.uid != ownerId) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar publicacion'),
        content: const Text('¿Estas seguro? Esta accion no se puede deshacer.'),
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
    try {
      final comments = await _firestore
          .collection('tierlists_comunidad')
          .doc(docId)
          .collection('comments')
          .get();
      for (var doc in comments.docs) await doc.reference.delete();
      await _firestore.collection('tierlists_comunidad').doc(docId).delete();

      // Decrementar contador de tierLists del usuario
      if (_currentUser != null) {
        await _firestore.collection('usuarios').doc(_currentUser!.uid).update({
          'tierLists': FieldValue.increment(-1),
        });
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Publicacion eliminada')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _abrirDetalle(String docId, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaginaDetalleTierlist(
          documentId: docId,
          tierData: data,
          ownerName: data['ownerName'] ?? 'Anonimo',
          ownerId: data['ownerId'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOrdenarBoton('Likes', 'likes'),
              const SizedBox(width: 8),
              _buildOrdenarBoton('Fecha', 'fecha'),
              const SizedBox(width: 8),
              _buildOrdenarBoton('Comentarios', 'comentarios'),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getComunidadStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(
                  child: Text('No hay publicaciones aun. ¡Se el primero!'),
                );
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final docId = docs[i].id;
                  final likes = data['likes'] ?? 0;
                  final likedBy = data['likedBy'] as List? ?? [];
                  final comentariosCount = data['commentsCount'] ?? 0;
                  final ownerName = data['ownerName'] ?? 'Anonimo';
                  final ownerId = data['ownerId'] ?? '';
                  final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                  final fechaStr = timestamp != null
                      ? '${timestamp.day}/${timestamp.month}/${timestamp.year}'
                      : '';
                  final isOwner = _currentUser?.uid == ownerId;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.article),
                      title: Text('Tier list de $ownerName'),
                      subtitle: Text(
                        'Likes: $likes   Comentarios: $comentariosCount   Fecha: $fechaStr',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              likedBy.contains(_currentUser?.uid)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: likedBy.contains(_currentUser?.uid)
                                  ? Colors.red
                                  : null,
                            ),
                            onPressed: () => _darLike(docId, likes, likedBy),
                          ),
                          if (isOwner)
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  _eliminarPublicacion(docId, ownerId),
                            ),
                        ],
                      ),
                      onTap: () => _abrirDetalle(docId, data),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrdenarBoton(String texto, String campo) {
    return FilterChip(
      label: Text(texto),
      selected: _ordenPor == campo,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            if (_ordenPor == campo) {
              _ordenAscendente = !_ordenAscendente;
            } else {
              _ordenPor = campo;
              _ordenAscendente = false;
            }
          }
        });
      },
    );
  }
}
