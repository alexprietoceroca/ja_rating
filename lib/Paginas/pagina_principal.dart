import 'package:flutter/material.dart';
import 'package:ja_rating/Components/pagina_principal/widgets/barra_navegacion.dart';
import 'package:ja_rating/Components/pagina_principal/tabs/tab_inicio.dart';
import 'package:ja_rating/Components/pagina_principal/tabs/tab_descubrir.dart';
import 'package:ja_rating/Components/pagina_principal/tabs/tab_perfil.dart';
import 'package:ja_rating/Components/pagina_principal/tabs/tab_mas.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  int indiceSeleccionado = 0;

  final List<Map<String, dynamic>> tendencias = [
    {'titulo': 'Dandadan', 'tituloIngles': 'Dandadan', 'tituloOriginal': 'ダンダダン', 'tipo': 'Anime', 'puntuacion': 4.6, 'genero': 'Sobrenatural', 'img': 'https://cdn.myanimelist.net/images/anime/1906/145217.jpg'},
    {'titulo': 'Solo Leveling', 'tituloIngles': 'Solo Leveling', 'tituloOriginal': '나 혼자만 레벨업', 'tipo': 'Manhwa', 'puntuacion': 4.7, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/manga/3/222295.jpg'},
    {'titulo': 'Vinland Saga', 'tituloIngles': 'Vinland Saga', 'tituloOriginal': 'ヴィンランド・サガ', 'tipo': 'Manga', 'puntuacion': 4.5, 'genero': 'Histórico', 'img': 'https://cdn.myanimelist.net/images/manga/2/188925.jpg'},
    {'titulo': 'Frieren', 'tituloIngles': 'Frieren: Beyond Journey\'s End', 'tituloOriginal': '葬送のフリーレン', 'tipo': 'Anime', 'puntuacion': 4.7, 'genero': 'Fantasía', 'img': 'https://cdn.myanimelist.net/images/anime/1015/138006.jpg'},
    {'titulo': 'Dios del Highschool', 'tituloIngles': 'The God of High School', 'tituloOriginal': '갓 오브 하이스쿨', 'tipo': 'Manhwa', 'puntuacion': 4.3, 'genero': 'Artes marciales', 'img': 'https://cdn.myanimelist.net/images/anime/1483/107881.jpg'},
    {'titulo': 'Torre de Dios', 'tituloIngles': 'Tower of God', 'tituloOriginal': '신의 탑', 'tipo': 'Manhwa', 'puntuacion': 4.4, 'genero': 'Aventura', 'img': 'https://cdn.myanimelist.net/images/manga/2/164417.jpg'},
    {'titulo': 'El Lector Omnisciente', 'tituloIngles': 'Omniscient Reader', 'tituloOriginal': '전지적 독자 시점', 'tipo': 'Manhwa', 'puntuacion': 4.6, 'genero': 'Fantasía', 'img': 'https://cdn.myanimelist.net/images/manga/2/246128.jpg'},
    {'titulo': 'Motosierra Man', 'tituloIngles': 'Chainsaw Man', 'tituloOriginal': 'チェンソーマン', 'tipo': 'Anime', 'puntuacion': 4.5, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/anime/1806/126216.jpg'},
    {'titulo': 'Vagabundo', 'tituloIngles': 'Vagabond', 'tituloOriginal': 'バガボンド', 'tipo': 'Manga', 'puntuacion': 4.9, 'genero': 'Histórico', 'img': 'https://cdn.myanimelist.net/images/manga/1/259070.jpg'},
    {'titulo': 'Nobleza', 'tituloIngles': 'Noblesse', 'tituloOriginal': '노블레스', 'tipo': 'Manhwa', 'puntuacion': 4.2, 'genero': 'Sobrenatural', 'img': 'https://cdn.myanimelist.net/images/manga/2/266261.jpg'},
  ];

  final List<Map<String, dynamic>> populares = [
    {'titulo': 'Ataque a los Titanes', 'tituloIngles': 'Attack on Titan', 'tituloOriginal': '進撃の巨人', 'tipo': 'Anime', 'puntuacion': 4.5, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/anime/1948/120625.jpg'},
    {'titulo': 'Una Pieza', 'tituloIngles': 'One Piece', 'tituloOriginal': 'ワンピース', 'tipo': 'Anime', 'puntuacion': 4.6, 'genero': 'Aventura', 'img': 'https://cdn.myanimelist.net/images/anime/6/73245.jpg'},
    {'titulo': 'Berserk', 'tituloIngles': 'Berserk', 'tituloOriginal': 'ベルセルク', 'tipo': 'Manga', 'puntuacion': 4.7, 'genero': 'Dark Fantasy', 'img': 'https://cdn.myanimelist.net/images/manga/1/157897.jpg'},
    {'titulo': 'Guardianes de la Noche', 'tituloIngles': 'Demon Slayer', 'tituloOriginal': '鬼滅の刃', 'tipo': 'Anime', 'puntuacion': 4.4, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/anime/1286/99889.jpg'},
    {'titulo': 'Jujutsu Kaisen', 'tituloIngles': 'Jujutsu Kaisen', 'tituloOriginal': '呪術廻戦', 'tipo': 'Anime', 'puntuacion': 4.3, 'genero': 'Sobrenatural', 'img': 'https://cdn.myanimelist.net/images/anime/1171/109222.jpg'},
    {'titulo': 'Alquimista de Acero', 'tituloIngles': 'Fullmetal Alchemist', 'tituloOriginal': '鋼の錬金術師', 'tipo': 'Anime', 'puntuacion': 4.9, 'genero': 'Aventura', 'img': 'https://cdn.myanimelist.net/images/anime/1223/96541.jpg'},
    {'titulo': 'Hunter x Hunter', 'tituloIngles': 'Hunter x Hunter', 'tituloOriginal': 'ハンター×ハンター', 'tipo': 'Anime', 'puntuacion': 4.8, 'genero': 'Aventura', 'img': 'https://cdn.myanimelist.net/images/anime/1337/99013.jpg'},
    {'titulo': 'Slam Dunk', 'tituloIngles': 'Slam Dunk', 'tituloOriginal': 'スラムダンク', 'tipo': 'Manga', 'puntuacion': 4.8, 'genero': 'Deporte', 'img': 'https://cdn.myanimelist.net/images/manga/3/264166.jpg'},
    {'titulo': 'Naruto', 'tituloIngles': 'Naruto', 'tituloOriginal': 'ナルト', 'tipo': 'Anime', 'puntuacion': 4.3, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/anime/13/17405.jpg'},
    {'titulo': 'Dragon Ball Z', 'tituloIngles': 'Dragon Ball Z', 'tituloOriginal': 'ドラゴンボールZ', 'tipo': 'Anime', 'puntuacion': 4.4, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/anime/1607/117271.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final bool esWeb = anchoPantalla > 800;

    final List<Widget> paginas = [
      TabInicio(tendencias: tendencias, populares: populares, esWeb: esWeb),
      TabDescubrir(todosLosItems: [...tendencias, ...populares], esWeb: esWeb),
      const TabPerfil(),
      const TabMas(),
    ];

    return Scaffold(
      body: paginas[indiceSeleccionado],
      bottomNavigationBar: BarraNavegacion(
        indiceSeleccionado: indiceSeleccionado,
        alSeleccionar: (i) => setState(() => indiceSeleccionado = i),
      ),
    );
  }
}