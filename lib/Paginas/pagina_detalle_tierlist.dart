import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/Login/texto_normal.dart';
import 'package:ja_rating/Components/CustomProductImage.dart';

class PaginaDetalleTierlist extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> tierData;
  final String ownerName;
  final String ownerId;

  const PaginaDetalleTierlist({
    super.key,
    required this.documentId,
    required this.tierData,
    required this.ownerName,
    required this.ownerId,
  });

  @override
  State<PaginaDetalleTierlist> createState() => _PaginaDetalleTierlistState();
}

class _PaginaDetalleTierlistState extends State<PaginaDetalleTierlist> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _comentarioController = TextEditingController();
  bool _isLiking = false;
  late int _likes;
  late bool _userLiked;

  @override
  void initState() {
    super.initState();
    _likes = widget.tierData['likes'] ?? 0;
    _userLiked = (widget.tierData['likedBy'] as List? ?? []).contains(
      _currentUser?.uid,
    );
  }

  Future<void> _toggleLike() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para dar like')),
      );
      return;
    }
    if (_isLiking) return;
    setState(() => _isLiking = true);
    try {
      final docRef = _firestore
          .collection('tierlists_comunidad')
          .doc(widget.documentId);
      if (!_userLiked) {
        await docRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([_currentUser!.uid]),
        });
        setState(() {
          _likes++;
          _userLiked = true;
        });
      } else {
        await docRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([_currentUser!.uid]),
        });
        setState(() {
          _likes--;
          _userLiked = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al dar like: $e')));
    } finally {
      setState(() => _isLiking = false);
    }
  }

  Future<void> _enviarComentario() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para comentar')),
      );
      return;
    }
    final texto = _comentarioController.text.trim();
    if (texto.isEmpty) return;
    try {
      await _firestore
          .collection('tierlists_comunidad')
          .doc(widget.documentId)
          .collection('comments')
          .add({
            'userId': _currentUser!.uid,
            'userName': _currentUser!.displayName ?? 'Usuario',
            'texto': texto,
            'timestamp': FieldValue.serverTimestamp(),
          });
      // Incrementar contador de comentarios en el documento principal
      await _firestore
          .collection('tierlists_comunidad')
          .doc(widget.documentId)
          .update({'commentsCount': FieldValue.increment(1)});
      _comentarioController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al enviar comentario: $e')));
    }
  }

  Future<void> _eliminarTierList() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tier List'),
        content: const Text('¿Estás seguro? Esta acción no se puede deshacer.'),
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
      // Eliminar comentarios (subcolección)
      final commentsSnapshot = await _firestore
          .collection('tierlists_comunidad')
          .doc(widget.documentId)
          .collection('comments')
          .get();
      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }
      // Eliminar el documento principal
      await _firestore
          .collection('tierlists_comunidad')
          .doc(widget.documentId)
          .delete();

      //Decrementar el contador del usuario
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == widget.ownerId) {
        await _firestore.collection('usuarios').doc(currentUser.uid).update({
          'tierLists': FieldValue.increment(-1),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tier list eliminada')));
        Navigator.pop(context); // Regresar a la pantalla anterior
      }
    } catch (e) {
      print('Error al eliminar: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiersOrdenados = [
      'S',
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'Dropeado',
      'No visto',
    ];

    return Scaffold(
      backgroundColor: Coloresapp.colorFondo,
      appBar: AppBar(
        title: Text('Tier List de ${widget.ownerName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Botón de like (ya existente)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _userLiked ? Icons.favorite : Icons.favorite_border,
                    color: _userLiked ? Colors.red : Colors.white,
                  ),
                  onPressed: _toggleLike,
                  tooltip: 'Like',
                ),
                const SizedBox(width: 4),
                Text(
                  '$_likes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.comment, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${widget.tierData['commentsCount'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Botón de eliminar (solo para el propietario)
          if (_currentUser != null && _currentUser!.uid == widget.ownerId)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _eliminarTierList,
              tooltip: 'Eliminar tier list',
            ),
        ],
      ),
      body: Column(
        children: [
          // Contenido de la tier list (scrollable)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: tiersOrdenados.map((tier) {
                final items = List<Map<String, dynamic>>.from(
                  widget.tierData[tier] ?? [],
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _colorPorTier(tier),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tier,
                            style: const TextStyle(
                              fontFamily: 'HoshikoSatsuki',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${items.length} títulos',
                          style: const TextStyle(
                            fontFamily: 'HoshikoSatsuki',
                            fontSize: 14,
                            color: Coloresapp.colorTextoFlojo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: items.isEmpty
                          ? Center(
                              child: Text(
                                'No hay productos en este tier',
                                style: TextStyle(
                                  color: _colorPorTier(tier).withOpacity(0.6),
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: items.map((producto) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Column(
                                      children: [
                                        CustomProductImage(
                                          malId: producto['malId'] ?? 0,
                                          originalUrl: producto['img'] ?? '',
                                          width: 80,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                        const SizedBox(height: 4),
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            producto['titulo'] ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ),
          // Sección de comentarios (fija abajo)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lista de comentarios (limitada en altura)
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('tierlists_comunidad')
                        .doc(widget.documentId)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No hay comentarios. ¡Sé el primero!'),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final data = docs[i].data() as Map<String, dynamic>;
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                (data['userName'] ?? 'U')[0].toUpperCase(),
                              ),
                            ),
                            title: Text(data['userName'] ?? 'Anónimo'),
                            subtitle: Text(data['texto'] ?? ''),
                            trailing: Text(
                              _formatearFecha(data['timestamp'] as Timestamp?),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Campo para nuevo comentario
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _comentarioController,
                          decoration: const InputDecoration(
                            hintText: 'Escribe un comentario...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _enviarComentario,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _colorPorTier(String tier) {
    switch (tier) {
      case 'S':
        return const Color(0xFFD4AF37);
      case 'A':
        return Colors.blue.shade700;
      case 'B':
        return Colors.green.shade700;
      case 'C':
        return Colors.yellow.shade800;
      case 'D':
        return Colors.orange.shade800;
      case 'E':
        return Colors.red.shade800;
      case 'F':
        return Colors.grey.shade800;
      case 'Dropeado':
        return Colors.purple.shade800;
      case 'No visto':
        return Colors.cyan.shade800;
      default:
        return Coloresapp.colorPrimario;
    }
  }

  String _formatearFecha(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
