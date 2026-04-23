import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ja_rating/coloresApp.dart';
import 'package:ja_rating/components/Login/texto_normal.dart';
import 'package:ja_rating/services/mongodb_service.dart';

import 'package:ja_rating/Components/pagina_principal/tabs/EstadisticaPerfil.dart';
import 'package:ja_rating/Components/pagina_principal/tabs/ItemMenuPerfil.dart';

class TabPerfil extends StatefulWidget {
  const TabPerfil({super.key});

  @override
  State<TabPerfil> createState() => _TabPerfilState();
}

class _TabPerfilState extends State<TabPerfil> {
  File? _imagenSeleccionada;
  String nombreUsuario = "Cargando...";

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();

    setState(() {
      nombreUsuario = doc.data()?['nombre'] ?? "Usuario";
    });
  }

  // 📸 SELECCIONAR IMAGEN
  Future<void> seleccionarImagen() async {
    final picker = ImagePicker();
    final XFile? imagen =
        await picker.pickImage(source: ImageSource.gallery);

    if (imagen == null) return;

    final file = File(imagen.path);

    setState(() {
      _imagenSeleccionada = file;
    });

    Uint8List bytes = await file.readAsBytes();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await MongoDBService.guardarImagen(
      userId: uid,
      imageBytes: bytes,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Imagen guardada")),
    );
  }

  // ✏️ CAMBIAR NOMBRE
  Future<void> cambiarNombre() async {
    TextEditingController controller = TextEditingController();

    final nuevoNombre = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cambiar nombre"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Nuevo nombre",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, controller.text),
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );

    if (nuevoNombre != null && nuevoNombre.isNotEmpty) {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .update({"nombre": nuevoNombre});

      setState(() {
        nombreUsuario = nuevoNombre;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final double padding = anchoPantalla > 800 ? 40 : 20;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextoNormal(contingutText: 'Mi Perfil'),
            const SizedBox(height: 20),

            Row(
              children: [
                GestureDetector(
                  onTap: seleccionarImagen,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Coloresapp.colorPrimario,
                    backgroundImage: _imagenSeleccionada != null
                        ? FileImage(_imagenSeleccionada!)
                        : null,
                    child: _imagenSeleccionada == null
                        ? const Icon(Icons.person_rounded,
                            color: Colors.white, size: 36)
                        : null,
                  ),
                ),

                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: cambiarNombre,
                      child: Text(
                        nombreUsuario,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Miembro desde 2023',
                      style: TextStyle(
                        fontSize: 13,
                        color: Coloresapp.colorTextoFlojo,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: const [
                EstadisticaPerfil(valor: '47', etiqueta: 'Calificados'),
                SizedBox(width: 12),
                EstadisticaPerfil(valor: '23', etiqueta: 'Comentarios'),
                SizedBox(width: 12),
                EstadisticaPerfil(valor: '5', etiqueta: 'Tier Lists'),
              ],
            ),

            const SizedBox(height: 24),

            const ItemMenuPerfil(
                icono: Icons.star_rounded,
                etiqueta: 'Mis calificaciones',
                sub: '47 títulos calificados'),
            const ItemMenuPerfil(
                icono: Icons.chat_bubble_outline_rounded,
                etiqueta: 'Mis comentarios',
                sub: '23 comentarios'),
            const ItemMenuPerfil(
                icono: Icons.emoji_events_rounded,
                etiqueta: 'Mis Tier Lists',
                sub: '5 listas creadas'),
            const ItemMenuPerfil(
                icono: Icons.forum_rounded,
                etiqueta: 'Foros visitados',
                sub: '12 hilos activos'),
          ],
        ),
      ),
    );
  }
}
