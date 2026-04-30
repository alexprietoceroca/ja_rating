import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ja_rating/Services/imagen_service.dart';

class ImagenService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Subir imagen de perfil
  Future<String?> subirImagenPerfil(String uid, File imagen) async {
    try {
      final ref = _storage.ref().child('perfiles/$uid/foto_perfil.jpg');
      await ref.putFile(imagen);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error al subir imagen: $e');
      return null;
    }
  }
  
  // Eliminar imagen de perfil
  Future<bool> eliminarImagenPerfil(String uid) async {
    try {
      final ref = _storage.ref().child('perfiles/$uid/foto_perfil.jpg');
      await ref.delete();
      return true;
    } catch (e) {
      print('Error al eliminar imagen: $e');
      return false;
    }
  }
  
  // Seleccionar imagen de la galería
  Future<File?> seleccionarImagenGaleria() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
  
  // Tomar foto con cámara
  Future<File?> tomarFotoCamara() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1024,
    );
    
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }
}