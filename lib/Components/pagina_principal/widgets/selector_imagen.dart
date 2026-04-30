import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ja_rating/Services/imagen_service.dart';

class SelectorImagen {
  final ImagenService _imagenService = ImagenService();
  
  // Mostrar selector de origen (cámara o galería)
  Future<File?> mostrarSelectorImagen(BuildContext context) async {
    return await showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Galería'),
              onTap: () async {
                final imagen = await _imagenService.seleccionarImagenGaleria();
                if (context.mounted) {
                  Navigator.pop(context, imagen);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Cámara'),
              onTap: () async {
                final imagen = await _imagenService.tomarFotoCamara();
                if (context.mounted) {
                  Navigator.pop(context, imagen);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}