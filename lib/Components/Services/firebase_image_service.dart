import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseImageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Map<int, String> _cache = {};

  static Future<String?> getCustomImageUrl(int malId) async {
    if (_cache.containsKey(malId)) {
      return _cache[malId];
    }
    try {
      final doc = await _firestore.collection('productos_custom_images').doc(malId.toString()).get();
      if (doc.exists && doc.data() != null) {
        final url = doc.data()!['imagenUrl'] as String?;
        if (url != null && url.isNotEmpty) {
          _cache[malId] = url;
          return url;
        }
      }
      _cache[malId] = '';
      return null;
    } catch (e) {
      print('Error obteniendo imagen personalizada para malId $malId: $e');
      return null;
    }
  }
}