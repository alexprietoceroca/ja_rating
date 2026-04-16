// image_service.dart
import 'package:flutter/foundation.dart';

class ImageService {
  // Mapa de IDs de MAL a URLs de imágenes personalizadas
  // Puedes expandir este mapa con tus propias imágenes
  static const Map<int, String> imagenesPersonalizadas = {
    // Ejemplos:
    // 1535: 'https://tu-servidor.com/imagenes/death_note.jpg',
    // 16498: 'https://tu-servidor.com/imagenes/shingeki_no_kyojin.jpg',
    // Añade aquí tus imágenes
  };
  
  // URL por defecto si no hay imagen personalizada
  static const String imagenPorDefecto = 'https://via.placeholder.com/225x319?text=Sin+Imagen';
  
  static String getImagenUrl(int malId, String urlOriginal) {
    if (imagenesPersonalizadas.containsKey(malId)) {
      final imagenPersonalizada = imagenesPersonalizadas[malId];
      if (imagenPersonalizada != null && imagenPersonalizada.isNotEmpty) {
        print('Usando imagen personalizada para ID $malId');
        return imagenPersonalizada;
      }
    }
    print('Usando imagen original para ID $malId');
    return urlOriginal;
  }
}