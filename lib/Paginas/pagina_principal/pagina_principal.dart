import 'package:flutter/material.dart';
import 'package:ja_rating/Paginas/pagina_principal/tabs/tab_descubrir.dart';
import 'package:ja_rating/Paginas/pagina_principal/tabs/tab_inicio.dart';
import 'package:ja_rating/Paginas/pagina_principal/tabs/tab_mas.dart';
import 'package:ja_rating/Paginas/pagina_principal/tabs/tab_perfil.dart';
import 'package:ja_rating/Paginas/pagina_principal/widgets/barra_navegacion.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  int indiceSeleccionado = 0;

  final List<Map<String, dynamic>> tendencias = [
    {'titulo': 'Dandadan', 'tipo': 'Anime', 'puntuacion': 4.6, 'genero': 'Sobrenatural', 'img': 'https://cdn.myanimelist.net/images/anime/1906/145217.jpg'},
    {'titulo': 'Solo Leveling', 'tipo': 'Manhwa', 'puntuacion': 4.7, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/manga/3/222295.jpg'},
    {'titulo': 'Vinland Saga', 'tipo': 'Manga', 'puntuacion': 4.5, 'genero': 'Histórico', 'img': 'https://cdn.myanimelist.net/images/manga/2/188925.jpg'},
    {'titulo': 'Frieren', 'tipo': 'Anime', 'puntuacion': 4.7, 'genero': 'Fantasía', 'img': 'https://cdn.myanimelist.net/images/anime/1015/138006.jpg'},
    {'titulo': 'Tower of God', 'tipo': 'Manhwa', 'puntuacion': 4.4, 'genero': 'Aventura', 'img': 'https://cdn.myanimelist.net/images/manga/2/164417.jpg'},
    {'titulo': 'Omniscient Reader', 'tipo': 'Manhwa', 'puntuacion': 4.6, 'genero': 'Fantasía', 'img': 'https://cdn.myanimelist.net/images/manga/2/246128.jpg'},
    {'titulo': 'Chainsaw Man', 'tipo': 'Anime', 'puntuacion': 4.5, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/anime/1806/126216.jpg'},
    {'titulo': 'Vagabond', 'tipo': 'Manga', 'puntuacion': 4.9, 'genero': 'Histórico', 'img': 'https://cdn.myanimelist.net/images/manga/1/259070.jpg'},
    {'titulo': 'Noblesse', 'tipo': 'Manhwa', 'puntuacion': 4.2, 'genero': 'Sobrenatural', 'img': 'https://myanimelist.net/images/manga/2/266261.jpg'},
    {'titulo': 'The God of High School', 'tipo': 'Manhwa', 'puntuacion': 4.3, 'genero': 'Artes marciales', 'img': 'https://cdn.myanimelist.net/images/anime/1483/107881.jpg'},
  ];

  final List<Map<String, dynamic>> populares = [
    {'titulo': 'Attack on Titan', 'tipo': 'Anime', 'puntuacion': 4.5, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/anime/1948/120625.jpg'},
    {'titulo': 'One Piece', 'tipo': 'Anime', 'puntuacion': 4.6, 'genero': 'Aventura', 'img': 'https://cdn.myanimelist.net/images/anime/6/73245.jpg'},
    {'titulo': 'Berserk', 'tipo': 'Manga', 'puntuacion': 4.7, 'genero': 'Dark Fantasy', 'img': 'https://cdn.myanimelist.net/images/manga/1/157897.jpg'},
    {'titulo': 'Demon Slayer', 'tipo': 'Anime', 'puntuacion': 4.4, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/anime/1286/99889.jpg'},
    {'titulo': 'Jujutsu Kaisen', 'tipo': 'Anime', 'puntuacion': 4.3, 'genero': 'Sobrenatural', 'img': 'https://cdn.myanimelist.net/images/anime/1171/109222.jpg'},
    {'titulo': 'Fullmetal Alchemist', 'tipo': 'Anime', 'puntuacion': 4.9, 'genero': 'Aventura', 'img': 'https://cdn.myanimelist.net/images/anime/1223/96541.jpg'},
    {'titulo': 'Hunter x Hunter', 'tipo': 'Anime', 'puntuacion': 4.8, 'genero': 'Aventura', 'img': 'https://cdn.myanimelist.net/images/anime/1337/99013.jpg'},
    {'titulo': 'Slam Dunk', 'tipo': 'Manga', 'puntuacion': 4.8, 'genero': 'Deporte', 'img': 'https://cdn.myanimelist.net/images/manga/3/264166.jpg'},
    {'titulo': 'Naruto', 'tipo': 'Anime', 'puntuacion': 4.3, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/anime/13/17405.jpg'},
    {'titulo': 'Dragon Ball Z', 'tipo': 'Anime', 'puntuacion': 4.4, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/anime/1607/117271.jpg'},
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