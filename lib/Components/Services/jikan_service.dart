// jikan_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/producto_model.dart';

class JikanService {
  static const String baseUrl = 'https://api.jikan.moe/v4';
  static const Duration rateLimit = Duration(seconds: 1);
  static DateTime _lastRequest = DateTime.now().subtract(rateLimit);
  static const Duration timeout = Duration(seconds: 15);

  Future<void> _esperarRateLimit() async {
    final ahora = DateTime.now();
    final tiempoDesdeUltima = ahora.difference(_lastRequest);
    if (tiempoDesdeUltima < rateLimit) {
      await Future.delayed(rateLimit - tiempoDesdeUltima);
    }
    _lastRequest = DateTime.now();
  }

  Future<http.Response> _getWithTimeout(String url) async {
    return http.get(Uri.parse(url)).timeout(timeout);
  }

  Future<List<ProductoModel>> getTopAnime({int page = 1, int limit = 10}) async {
    try {
      await _esperarRateLimit();
      print('Cargando Top Anime...');
      final response = await _getWithTimeout('$baseUrl/top/anime?page=$page&limit=$limit');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['data'];
        print('Top Anime cargados: ${results.length} resultados');
        return results.map((json) => ProductoModel.fromAnimeJson({'data': json})).toList();
      } else {
        print('Error Top Anime: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Excepcion Top Anime: $e');
      return [];
    }
  }

  Future<List<ProductoModel>> getTopManga({int page = 1, int limit = 10}) async {
    try {
      await _esperarRateLimit();
      print('Cargando Top Manga...');
      final response = await _getWithTimeout('$baseUrl/top/manga?page=$page&limit=$limit');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['data'];
        print('Top Manga cargados: ${results.length} resultados');
        return results.map((json) => ProductoModel.fromMangaJson({'data': json})).toList();
      } else {
        print('Error Top Manga: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Excepcion Top Manga: $e');
      return [];
    }
  }

  Future<List<ProductoModel>> getTodosProductos() async {
    try {
      print('Cargando todos los productos...');
      final anime = await getTopAnime(limit: 10);
      await Future.delayed(const Duration(milliseconds: 500));
      final manga = await getTopManga(limit: 10);
      final todos = [...anime, ...manga];
      print('Total productos: ${todos.length}');
      return todos;
    } catch (e) {
      print('Error cargando productos: $e');
      return [];
    }
  }
}