// lib/Components/pagina_perfil/foros_visitados_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Paginas/pagina_foro.dart';

class ForosVisitadosPage extends StatelessWidget {
  const ForosVisitadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Foros Visitados')),
        body: const Center(child: Text('Debes iniciar sesión')),
      );
    }

    return Scaffold(
      backgroundColor: Coloresapp.colorFondo,
      appBar: AppBar(
        title: const Text('Foros Visitados'),
        backgroundColor: Coloresapp.colorPrimario,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('visitas_foros')
            .where('userId', isEqualTo: user.uid)
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No has visitado ningún foro aún'));
          }

          final visitas = snapshot.data!.docs;
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _cargarForosVisitas(visitas),
            builder: (context, forosSnapshot) {
              if (forosSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final foros = forosSnapshot.data ?? [];
              if (foros.isEmpty) {
                return const Center(child: Text('No se encontraron foros'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: foros.length,
                itemBuilder: (context, i) {
                  final foro = foros[i];
                  final fechaVisita = foro['fechaVisita'] != null
                      ? DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(foro['fechaVisita'])
                      : '';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(foro['titulo'] ?? 'Sin título'),
                      subtitle: Text('Visitado: $fechaVisita'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaginaDetalleForo(foro: foro),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _cargarForosVisitas(
    List<QueryDocumentSnapshot> visitas,
  ) async {
    List<Map<String, dynamic>> forosList = [];
    final firestore = FirebaseFirestore.instance;

    for (var visita in visitas) {
      final data = visita.data() as Map<String, dynamic>;
      final foroId = data['foroId'];
      if (foroId == null) continue;

      final foroDoc = await firestore.collection('foros').doc(foroId).get();
      if (foroDoc.exists) {
        final foroData = foroDoc.data()!;
        foroData['id'] = foroDoc.id;
        foroData['fechaVisita'] = (data['fecha'] as Timestamp?)?.toDate();
        forosList.add(foroData);
      }
    }
    return forosList;
  }
}
