import 'dart:typed_data';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDBService {
  static late Db _db;
  static late DbCollection _usuariosCollection;
  static late DbCollection _valoracionesCollection;
  static late DbCollection _imagenesCollection; // 👈 NUEVO

  static const String _connectionString =
      'mongodb+srv://alexprieto_db_user:Ceroca123.@cluster0.m0qt2k1.mongodb.net/jarating';

  static Future<void> init() async {
    try {
      print('🔄 Conectando a MongoDB Atlas...');

      _db = await Db.create(_connectionString);
      await _db.open();

      print('✅ Conectado a MongoDB Atlas exitosamente');

      // Colecciones
      _usuariosCollection = _db.collection('usuarios');
      _valoracionesCollection = _db.collection('valoraciones');
      _imagenesCollection = _db.collection('Image'); // 👈 NUEVO

      print('📁 Colecciones: usuarios, valoraciones, Image');
    } catch (e) {
      print('❌ Error conectando a MongoDB: $e');
      rethrow;
    }
  }

  static Future<void> close() async {
    await _db.close();
    print('🔌 Conexión a MongoDB cerrada');
  }

  // =========================
  // 👤 USUARIOS
  // =========================

  static Future<void> guardarUsuario(Map<String, dynamic> usuario) async {
    await _usuariosCollection.insertOne(usuario);
  }

  static Future<Map<String, dynamic>?> obtenerUsuario(String uid) async {
    return await _usuariosCollection.findOne(where.eq('uid', uid));
  }

  static Future<void> actualizarUsuario(
      String uid, Map<String, dynamic> datos) async {
    await _usuariosCollection.updateOne(
      where.eq('uid', uid),
      modify
        ..set('nombreUsuario', datos['nombreUsuario'])
        ..set('nombreCompleto', datos['nombreCompleto'])
        ..set('email', datos['email'])
        ..set('fotoPerfil', datos['fotoPerfil'])
        ..set('biografia', datos['biografia'] ?? ''),
    );
  }

  // =========================
  // ⭐ VALORACIONES
  // =========================

  static Future<void> guardarValoracion(
      Map<String, dynamic> valoracion) async {
    await _valoracionesCollection.insertOne(valoracion);
  }

  static Future<List<Map<String, dynamic>>>
      obtenerValoracionesPorUsuario(String uid) async {
    return await _valoracionesCollection
        .find(where.eq('usuarioId', uid))
        .toList();
  }

  // =========================
  // 🖼️ IMÁGENES (NUEVO)
  // =========================

  /// Guardar imagen como bitmap (bytes)
  static Future<void> guardarImagen({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    try {
      await _imagenesCollection.insertOne({
        "userId": userId,
        "image": imageBytes,
        "createdAt": DateTime.now().toIso8601String(),
      });

      print('✅ Imagen guardada en MongoDB');
    } catch (e) {
      print('❌ Error guardando imagen: $e');
      rethrow;
    }
  }

  /// Obtener última imagen de un usuario
  static Future<Uint8List?> obtenerImagenUsuario(String userId) async {
    try {
      final doc = await _imagenesCollection.findOne(
        where.eq('userId', userId).sortBy('createdAt', descending: true),
      );

      if (doc != null && doc['image'] != null) {
        return doc['image'].byteList;
      }

      return null;
    } catch (e) {
      print('❌ Error obteniendo imagen: $e');
      return null;
    }
  }

  // =========================
  // 🔌 ESTADO CONEXIÓN
  // =========================

  static Future<bool> isConnected() async {
    try {
      return _db.isConnected;
    } catch (e) {
      return false;
    }
  }
}