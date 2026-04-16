import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  print('🔄 Probando conexión a MongoDB...');
  
  final db = await Db.create('mongodb+srv://alexprieto_db_user:Ceroca123.@cluster0.m0qt2k1.mongodb.net/JA%2DRATING');
  
  try {
    await db.open();
    print('✅ CONEXIÓN EXITOSA!');
    print('🎉 MongoDB está funcionando correctamente');
  } catch (e) {
    print('❌ Error de conexión: $e');
  } finally {
    await db.close();
  }
}