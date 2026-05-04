// producto_model.dart
import '../Services/image_service.dart';

class ProductoModel {
  final int malId;
  final String titulo;
  final String tituloIngles;
  final String tituloOriginal;
  final String tipo;
  final double puntuacion;
  final String imagenUrl;
  final String sinopsis;
  final String genero;
  final List<String> generos;
  final String? autor;
  final int? anio;
  final String? estudio;
  final int? episodios;
  final String? demografia;
  final String? estado;

  ProductoModel({
    required this.malId,
    required this.titulo,
    required this.tituloIngles,
    required this.tituloOriginal,
    required this.tipo,
    required this.puntuacion,
    required this.imagenUrl,
    required this.sinopsis,
    required this.genero,
    required this.generos,
    this.autor,
    this.anio,
    this.estudio,
    this.episodios,
    this.demografia,
    this.estado,
  });

  Map<String, dynamic> toMap() {
    return {
      'malId': malId,
      'titulo': titulo,
      'tituloIngles': tituloIngles,
      'tituloOriginal': tituloOriginal,
      'tipo': tipo,
      'puntuacion': puntuacion,
      'img': imagenUrl,
      'descripcion': sinopsis,
      'genero': genero,
      'generos': generos,
      'autor': autor ?? 'Desconocido',
      'anio': anio ?? 0,
      'estudio': estudio ?? 'Desconocido',
      'episodios': episodios ?? 0,
      'demografia': demografia ?? 'Shounen',
      'estado': estado ?? 'En emision',
    };
  }

  factory ProductoModel.fromAnimeJson(Map<String, dynamic> json) {
    final data = json['data'];
    final malId = data['mal_id'] ?? 0;
    final urlOriginal = data['images']?['jpg']?['image_url'] ?? '';
    final imagenUrl = ImageService.getImagenUrl(malId, urlOriginal);

    int? anioExtraido;
    if (data['year'] != null) {
      anioExtraido = data['year'];
    } else if (data['aired'] != null && data['aired']['from'] != null) {
      final fechaString = data['aired']['from'].toString();
      if (fechaString.length >= 4) {
        anioExtraido = int.tryParse(fechaString.substring(0, 4));
      }
    }

    return ProductoModel(
      malId: malId,
      titulo: data['title'] ?? 'Sin titulo',
      tituloIngles: data['title_english'] ?? data['title'] ?? 'Sin titulo',
      tituloOriginal: data['title_japanese'] ?? '',
      tipo: _determinarTipo(data['type'], data['title'] ?? '', malId),
      puntuacion: ((data['score'] ?? 0.0).toDouble() / 2),
      imagenUrl: imagenUrl,
      sinopsis: data['synopsis'] ?? 'Sin sinopsis disponible',
      genero: data['genres'] != null && data['genres'].isNotEmpty
          ? data['genres'][0]['name']
          : 'Sin genero',
      generos: data['genres'] != null
          ? (data['genres'] as List).map((g) => g['name'] as String).toList()
          : [],
      autor: data['authors'] != null && data['authors'].isNotEmpty
          ? data['authors'][0]['name']
          : null,
      anio: anioExtraido,
      estudio: data['studios'] != null && data['studios'].isNotEmpty
          ? data['studios'][0]['name']
          : null,
      episodios: data['episodes'],
      demografia:
          data['demographics'] != null && data['demographics'].isNotEmpty
          ? data['demographics'][0]['name']
          : null,
      estado: data['status'],
    );
  }

  factory ProductoModel.fromMangaJson(Map<String, dynamic> json) {
    final data = json['data'];
    final malId = data['mal_id'] ?? 0;
    final urlOriginal = data['images']?['jpg']?['image_url'] ?? '';
    final imagenUrl = ImageService.getImagenUrl(malId, urlOriginal);
    final tipoOriginal = data['type'] ?? 'Manga';
    final tituloCompleto = data['title'] ?? '';

    int? anioExtraido;
    if (data['published'] != null && data['published']['from'] != null) {
      final fechaString = data['published']['from'].toString();
      if (fechaString.length >= 4) {
        anioExtraido = int.tryParse(fechaString.substring(0, 4));
      }
    }

    return ProductoModel(
      malId: malId,
      titulo: tituloCompleto,
      tituloIngles: data['title_english'] ?? data['title'] ?? 'Sin titulo',
      tituloOriginal: data['title_japanese'] ?? '',
      tipo: _mapearTipoManga(tipoOriginal, tituloCompleto, malId),
      puntuacion: ((data['score'] ?? 0.0).toDouble() / 2),
      imagenUrl: imagenUrl,
      sinopsis: data['synopsis'] ?? 'Sin sinopsis disponible',
      genero: data['genres'] != null && data['genres'].isNotEmpty
          ? data['genres'][0]['name']
          : 'Sin genero',
      generos: data['genres'] != null
          ? (data['genres'] as List).map((g) => g['name'] as String).toList()
          : [],
      autor: data['authors'] != null && data['authors'].isNotEmpty
          ? data['authors'][0]['name']
          : null,
      anio: anioExtraido,
      estudio: data['authors'] != null && data['authors'].isNotEmpty
          ? data['authors'][0]['name']
          : null,
      episodios: data['chapters'],
      demografia:
          data['demographics'] != null && data['demographics'].isNotEmpty
          ? data['demographics'][0]['name']
          : null,
      estado: data['status'],
    );
  }

  static String _determinarTipo(String? type, String titulo, int malId) {
    if (malId == 15125) return 'Donghua'; // para evitar el falso anime
    if (_esMangaEnLugarDeAnime(titulo)) return 'Manga';
    switch (type) {
      case 'TV':
        return 'Anime';
      case 'Movie':
        return 'Anime';
      case 'OVA':
        return 'Anime';
      case 'Special':
        return 'Anime';
      case 'ONA':
        return 'Donghua';
      default:
        return 'Anime';
    }
  }

  static String _mapearTipoManga(String type, String titulo, int malId) {
    if (malId == 1706) return 'Manga';
    final List<String> mangasConfirmados = [
      'Steel Ball Run',
      'JoJo no Kimyou na Bouken',
      'JoJo\'s Bizarre Adventure',
      'One Piece',
      'Naruto',
      'Berserk',
      'Vagabond',
      'Vinland Saga',
      'Attack on Titan',
      'Fullmetal Alchemist',
      'Hunter x Hunter',
      'Slam Dunk',
      'Dragon Ball',
      'Death Note',
      'Monster',
      '20th Century Boys',
      'Pluto',
      'Goodnight Punpun',
      'Kingdom',
      'Haikyuu',
      'Jujutsu Kaisen',
      'Demon Slayer',
      'Kimetsu no Yaiba',
      'My Hero Academia',
      'Chainsaw Man',
      'Dandadan',
      'Spy x Family',
      'Frieren',
      'Tokyo Ghoul',
      'Parasyte',
      'Homunculus',
      'Gantz',
      'Blame',
      'Akira',
      'Ghost in the Shell',
    ];
    for (String manga in mangasConfirmados) {
      if (titulo.contains(manga)) return 'Manga';
    }
    switch (type) {
      case 'Manhwa':
        return 'Manhwa';
      case 'Manhua':
        return 'Manhua';
      case 'Manga':
        return 'Manga';
      case 'Novel':
        return 'Novela';
      case 'Light Novel':
        return 'Novela Ligera';
      default:
        return 'Manga';
    }
  }

  static bool _esMangaEnLugarDeAnime(String titulo) {
    final List<String> mangasSinAnime = [
      'Steel Ball Run',
      'Vagabond',
      '20th Century Boys',
      'Pluto',
      'Goodnight Punpun',
      'Kingdom',
      'Blame',
      'Homunculus',
      'Gantz',
    ];
    for (String manga in mangasSinAnime) {
      if (titulo.contains(manga)) return true;
    }
    return false;
  }
}
