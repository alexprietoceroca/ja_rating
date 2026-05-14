// lib/Components/pagina_perfil/mis_tierlists_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Paginas/pagina_detalle_tierlist.dart';

class MisTierlistsPage extends StatelessWidget {
  const MisTierlistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mis Tier Lists')),
        body: const Center(child: Text('Debes iniciar sesión')),
      );
    }

    return Scaffold(
      backgroundColor: Coloresapp.colorFondo,
      appBar: AppBar(
        title: const Text('Mis Tier Lists'),
        backgroundColor: Coloresapp.colorPrimario,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tierlists_comunidad')
            .where('ownerId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            // Si el error es por falta de índice, mostrar mensaje
            final errorMsg = snapshot.error.toString();
            if (errorMsg.contains('index') ||
                errorMsg.contains('requires an index')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.build, size: 48, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'Falta un índice en Firestore.\nConsulta la consola para crearlo.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Puedes abrir el enlace de creación de índice
                        // (el enlace aparece en el error de la consola de depuración)
                      },
                      child: const Text('Crear índice'),
                    ),
                  ],
                ),
              );
            }
            return Center(child: Text('Error: $errorMsg'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No has publicado ninguna tier list'),
            );
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final docId = docs[i].id;
              final likes = data['likes'] ?? 0;
              final comentarios = data['commentsCount'] ?? 0;
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              final fecha = timestamp != null
                  ? '${timestamp.day}/${timestamp.month}/${timestamp.year}'
                  : '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(
                    Icons.emoji_events,
                    color: Coloresapp.colorPrimario,
                  ),
                  title: Text('Tier List de ${data['ownerName'] ?? 'Anónimo'}'),
                  subtitle: Text(
                    'Likes: $likes  ·  Comentarios: $comentarios  ·  $fecha',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaginaDetalleTierlist(
                          documentId: docId,
                          tierData: data,
                          ownerName: data['ownerName'] ?? 'Anónimo',
                          ownerId: data['ownerId'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
