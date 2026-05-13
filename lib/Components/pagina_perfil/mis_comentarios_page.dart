// lib/Components/pagina_perfil/mis_comentarios_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:ja_rating/coloresapp.dart';

class MisComentariosPage extends StatefulWidget {
  const MisComentariosPage({super.key});

  @override
  State<MisComentariosPage> createState() => _MisComentariosPageState();
}

class _MisComentariosPageState extends State<MisComentariosPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _comentarios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarComentarios();
  }

  Future<void> _cargarComentarios() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _cargando = false;
      });
      return;
    }

    try {
      // 1. Comentarios en tier lists (colección 'comments' dentro de cada tierlist)
      final tierListsSnapshot = await _firestore
          .collectionGroup('comments')
          .where('userId', isEqualTo: user.uid)
          .get();

      List<Map<String, dynamic>> comentariosTemp = [];

      for (var doc in tierListsSnapshot.docs) {
        final data = doc.data();
        final parentRef = doc.reference.parent.parent;
        DocumentSnapshot? parentDoc;
        if (parentRef != null) {
          parentDoc = await parentRef.get();
        }

        String tituloTierList = 'Tier List';
        if (parentDoc != null && parentDoc.exists) {
          final parentData = parentDoc.data() as Map<String, dynamic>?;
          final ownerName = parentData?['ownerName'] ?? 'Anónimo';
          tituloTierList = 'Tier List de $ownerName';
        }

        comentariosTemp.add({
          'tipo': 'Tier List',
          'tituloReferencia': tituloTierList,
          'texto': data['texto'] ?? '',
          'fecha': (data['timestamp'] as Timestamp?)?.toDate(),
          'idReferencia': parentRef?.id,
        });
      }

      // 2. Comentarios en foros (subcolección 'comentarios' dentro de cada foro)
      final forosSnapshot = await _firestore
          .collectionGroup('comentarios')
          .where('autorId', isEqualTo: user.uid)
          .get();

      for (var doc in forosSnapshot.docs) {
        final data = doc.data();
        final parentRef = doc.reference.parent.parent;
        DocumentSnapshot? parentDoc;
        if (parentRef != null) {
          parentDoc = await parentRef.get();
        }

        String tituloForo = 'Foro';
        if (parentDoc != null && parentDoc.exists) {
          final parentData = parentDoc.data() as Map<String, dynamic>?;
          tituloForo = parentData?['titulo'] ?? 'Foro';
        }

        comentariosTemp.add({
          'tipo': 'Foro',
          'tituloReferencia': tituloForo,
          'texto': data['contenido'] ?? '',
          'fecha': (data['fecha'] as Timestamp?)?.toDate(),
          'idReferencia': parentRef?.id,
        });
      }

      // Ordenar por fecha descendente
      comentariosTemp.sort((a, b) {
        final fechaA = a['fecha'] ?? DateTime(1970);
        final fechaB = b['fecha'] ?? DateTime(1970);
        return fechaB.compareTo(fechaA);
      });

      setState(() {
        _comentarios = comentariosTemp;
        _cargando = false;
      });
    } catch (e) {
      print('Error al cargar comentarios: $e');
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis Comentarios')),
        body: const Center(child: Text('Debes iniciar sesión')),
      );
    }

    return Scaffold(
      backgroundColor: Coloresapp.colorFondo,
      appBar: AppBar(
        title: const Text('Mis Comentarios'),
        backgroundColor: Coloresapp.colorPrimario,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _comentarios.isEmpty
          ? const Center(child: Text('No has hecho ningún comentario'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _comentarios.length,
              itemBuilder: (context, i) {
                final c = _comentarios[i];
                final fecha = c['fecha'] != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(c['fecha'])
                    : '';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Coloresapp.colorPrimario.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                c['tipo'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Coloresapp.colorPrimario,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                c['tituloReferencia'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              fecha,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(c['texto'], style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
