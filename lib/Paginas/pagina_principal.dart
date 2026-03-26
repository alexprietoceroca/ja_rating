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
    {
      'titulo': 'Dandadan',
      'tituloIngles': 'Dandadan',
      'tituloOriginal': 'ダンダダン',
      'tipo': 'Anime',
      'puntuacion': 4.6,
      'genero': 'Sobrenatural',
      'autor': 'Yukinobu Tatsu',
      'anio': 2021,
      'estudio': 'Science SARU',
      'descripcion':
          'Una chica que cree en los fantasmas y un chico que cree en los extraterrestres descubren que ambos tienen razón, desencadenando una historia llena de acción y humor.',
      'img': 'https://cdn.myanimelist.net/images/anime/1906/145217.jpg',
    },
    {
      'titulo': 'Solo Leveling',
      'tituloIngles': 'Solo Leveling',
      'tituloOriginal': '나 혼자만 레벨업',
      'tipo': 'Manhwa',
      'puntuacion': 4.7,
      'genero': 'Acción',
      'autor': 'Chugong',
      'anio': 2018,
      'estudio': 'D&C Media',
      'descripcion':
          'Sung Jinwoo, el cazador más débil del mundo, obtiene un poder misterioso que le permite subir de nivel sin límite en un mundo lleno de mazmorras y monstruos.',
      'img': 'https://cdn.myanimelist.net/images/manga/3/222295.jpg',
    },
    {
      'titulo': 'Vinland Saga',
      'tituloIngles': 'Vinland Saga',
      'tituloOriginal': 'ヴィンランド・サガ',
      'tipo': 'Manga',
      'puntuacion': 4.5,
      'genero': 'Histórico',
      'autor': 'Makoto Yukimura',
      'anio': 2005,
      'estudio': 'Kodansha',
      'descripcion':
          'La historia de Thorfinn, un joven vikingo que busca venganza por la muerte de su padre en la Europa medieval, explorando temas de guerra, paz y redención.',
      'img': 'https://cdn.myanimelist.net/images/manga/2/188925.jpg',
    },
    {
      'titulo': 'Frieren',
      'tituloIngles': 'Frieren: Beyond Journey\'s End',
      'tituloOriginal': '葬送のフリーレン',
      'tipo': 'Anime',
      'puntuacion': 4.7,
      'genero': 'Fantasía',
      'autor': 'Kanehito Yamada',
      'anio': 2020,
      'estudio': 'Madhouse',
      'descripcion':
          'Una elfa maga reflexiona sobre el paso del tiempo y los vínculos humanos mientras emprende un nuevo viaje tras la muerte de sus compañeros de aventura.',
      'img': 'https://cdn.myanimelist.net/images/anime/1015/138006.jpg',
    },
    {
      'titulo': 'Dios del Highschool',
      'tituloIngles': 'The God of High School',
      'tituloOriginal': '갓 오브 하이스쿨',
      'tipo': 'Manhwa',
      'puntuacion': 4.3,
      'genero': 'Artes marciales',
      'autor': 'Yongje Park',
      'anio': 2011,
      'estudio': 'Crunchyroll (anime) / LINE Webtoon',
      'descripcion':
          'Un torneo de artes marciales entre estudiantes de instituto esconde un conflicto mucho mayor que involucra poderes divinos y antiguos dioses.',
      'img': 'https://cdn.myanimelist.net/images/anime/1483/107881.jpg',
    },
    {
      'titulo': 'Torre de Dios',
      'tituloIngles': 'Tower of God',
      'tituloOriginal': '신의 탑',
      'tipo': 'Manhwa',
      'puntuacion': 4.4,
      'genero': 'Aventura',
      'autor': 'SIU',
      'anio': 2010,
      'estudio': 'Telecom Animation Film',
      'descripcion':
          'Bam entra a una misteriosa torre para encontrar a su única amiga Rachel, enfrentando pruebas mortales en cada piso con poderes y aliados inesperados.',
      'img': 'https://cdn.myanimelist.net/images/manga/2/164417.jpg',
    },
    {
      'titulo': 'El Lector Omnisciente',
      'tituloIngles': 'Omniscient Reader',
      'tituloOriginal': '전지적 독자 시점',
      'tipo': 'Manhwa',
      'puntuacion': 4.6,
      'genero': 'Fantasía',
      'autor': 'Sing Shong',
      'anio': 2018,
      'estudio': 'REDICE Studio',
      'descripcion':
          'El único lector de una novela de apocalipsis ve cómo la ficción se convierte en realidad y usa su conocimiento del argumento para sobrevivir.',
      'img': 'https://cdn.myanimelist.net/images/manga/2/246128.jpg',
    },
    {
      'titulo': 'Motosierra Man',
      'tituloIngles': 'Chainsaw Man',
      'tituloOriginal': 'チェンソーマン',
      'tipo': 'Anime',
      'puntuacion': 4.5,
      'genero': 'Acción',
      'autor': 'Tatsuki Fujimoto',
      'anio': 2018,
      'estudio': 'MAPPA',
      'descripcion':
          'Denji, un joven cazador de demonios fusionado con su perro demonio Pochita, trabaja para una agencia gubernamental cazando demonios a cambio de una vida normal.',
      'img': 'https://cdn.myanimelist.net/images/anime/1806/126216.jpg',
    },
    {
      'titulo': 'Vagabundo',
      'tituloIngles': 'Vagabond',
      'tituloOriginal': 'バガボンド',
      'tipo': 'Manga',
      'puntuacion': 4.9,
      'genero': 'Histórico',
      'autor': 'Takehiko Inoue',
      'anio': 1998,
      'estudio': 'Kodansha',
      'descripcion':
          'La vida ficticia de Miyamoto Musashi, el legendario espadachín japonés, en su búsqueda de ser invencible bajo el cielo a través del camino de la espada.',
      'img': 'https://cdn.myanimelist.net/images/manga/1/259070.jpg',
    },
    {
      'titulo': 'Nobleza',
      'tituloIngles': 'Noblesse',
      'tituloOriginal': '노블레스',
      'tipo': 'Manhwa',
      'puntuacion': 4.2,
      'genero': 'Sobrenatural',
      'autor': 'Son Jeho',
      'anio': 2007,
      'estudio': 'Production I.G',
      'descripcion':
          'Cadis Etrama Di Raizel, un noble vampiro que lleva 820 años dormido, despierta en el mundo moderno y debe adaptarse mientras protege a los humanos.',
      'img': 'https://cdn.myanimelist.net/images/manga/2/266261.jpg',
    },
  ];

  final List<Map<String, dynamic>> populares = [
    {
      'titulo': 'Ataque a los Titanes',
      'tituloIngles': 'Attack on Titan',
      'tituloOriginal': '進撃の巨人',
      'tipo': 'Anime',
      'puntuacion': 4.5,
      'genero': 'Acción',
      'autor': 'Hajime Isayama',
      'anio': 2009,
      'estudio': 'Wit Studio / MAPPA',
      'descripcion':
          'La humanidad vive encerrada en ciudades rodeadas de enormes muros para protegerse de los Titanes, gigantes que devoran humanos sin razón aparente.',
      'img': 'https://cdn.myanimelist.net/images/anime/1948/120625.jpg',
    },
    {
      'titulo': 'Una Pieza',
      'tituloIngles': 'One Piece',
      'tituloOriginal': 'ワンピース',
      'tipo': 'Anime',
      'puntuacion': 4.6,
      'genero': 'Aventura',
      'autor': 'Eiichiro Oda',
      'anio': 1997,
      'estudio': 'Toei Animation',
      'descripcion':
          'Monkey D. Luffy y su tripulación navegan los mares en busca del legendario tesoro One Piece para que Luffy se convierta en el Rey de los Piratas.',
      'img': 'https://cdn.myanimelist.net/images/anime/6/73245.jpg',
    },
    {
      'titulo': 'Berserk',
      'tituloIngles': 'Berserk',
      'tituloOriginal': 'ベルセルク',
      'tipo': 'Manga',
      'puntuacion': 4.7,
      'genero': 'Dark Fantasy',
      'autor': 'Kentaro Miura',
      'anio': 1989,
      'estudio': 'Hakusensha',
      'descripcion':
          'Guts, un mercenario solitario con una espada colosal, lucha contra demonios y su oscuro destino en un mundo medieval brutal lleno de magia y traición.',
      'img': 'https://cdn.myanimelist.net/images/manga/1/157897.jpg',
    },
    {
      'titulo': 'Guardianes de la Noche',
      'tituloIngles': 'Demon Slayer',
      'tituloOriginal': '鬼滅の刃',
      'tipo': 'Anime',
      'puntuacion': 4.4,
      'genero': 'Acción',
      'autor': 'Koyoharu Gotouge',
      'anio': 2016,
      'estudio': 'ufotable',
      'descripcion':
          'Tanjiro Kamado se convierte en cazador de demonios para salvar a su hermana Nezuko, transformada en demonio, y vengar a su familia masacrada.',
      'img': 'https://cdn.myanimelist.net/images/anime/1286/99889.jpg',
    },
    {
      'titulo': 'Jujutsu Kaisen',
      'tituloIngles': 'Jujutsu Kaisen',
      'tituloOriginal': '呪術廻戦',
      'tipo': 'Anime',
      'puntuacion': 4.3,
      'genero': 'Sobrenatural',
      'autor': 'Gege Akutami',
      'anio': 2018,
      'estudio': 'MAPPA',
      'descripcion':
          'Yuji Itadori ingresa al mundo de los hechiceros tras tragarse un dedo maldito, convirtiéndose en el recipiente del demonio más poderoso de la historia.',
      'img': 'https://cdn.myanimelist.net/images/anime/1171/109222.jpg',
    },
    {
      'titulo': 'Alquimista de Acero',
      'tituloIngles': 'Fullmetal Alchemist',
      'tituloOriginal': '鋼の錬金術師',
      'tipo': 'Anime',
      'puntuacion': 4.9,
      'genero': 'Aventura',
      'autor': 'Hiromu Arakawa',
      'anio': 2001,
      'estudio': 'Bones',
      'descripcion':
          'Los hermanos Elric buscan la Piedra Filosofal para recuperar sus cuerpos perdidos tras un fallido intento de alquimia para revivir a su madre.',
      'img': 'https://cdn.myanimelist.net/images/anime/1223/96541.jpg',
    },
    {
      'titulo': 'Hunter x Hunter',
      'tituloIngles': 'Hunter x Hunter',
      'tituloOriginal': 'ハンター×ハンター',
      'tipo': 'Anime',
      'puntuacion': 4.8,
      'genero': 'Aventura',
      'autor': 'Yoshihiro Togashi',
      'anio': 1998,
      'estudio': 'Madhouse',
      'descripcion':
          'Gon Freecss sueña con ser un Hunter como su padre desaparecido, embarcándose en un viaje lleno de peligros, amistades y poderes extraordinarios.',
      'img': 'https://cdn.myanimelist.net/images/anime/1337/99013.jpg',
    },
    {
      'titulo': 'Slam Dunk',
      'tituloIngles': 'Slam Dunk',
      'tituloOriginal': 'スラムダンク',
      'tipo': 'Manga',
      'puntuacion': 4.8,
      'genero': 'Deporte',
      'autor': 'Takehiko Inoue',
      'anio': 1990,
      'estudio': 'Shueisha',
      'descripcion':
          'Hanamichi Sakuragi, un chico problemático sin experiencia en baloncesto, se une al equipo de su instituto para conquistar a una chica y acaba enamorándose del deporte.',
      'img': 'https://cdn.myanimelist.net/images/manga/3/264166.jpg',
    },
    {
      'titulo': 'Naruto',
      'tituloIngles': 'Naruto',
      'tituloOriginal': 'ナルト',
      'tipo': 'Anime',
      'puntuacion': 4.3,
      'genero': 'Acción',
      'autor': 'Masashi Kishimoto',
      'anio': 1999,
      'estudio': 'Pierrot',
      'descripcion':
          'Naruto Uzumaki, un joven ninja con un demonio sellado en su interior, sueña con convertirse en Hokage para ganarse el respeto de su aldea.',
      'img': 'https://cdn.myanimelist.net/images/anime/13/17405.jpg',
    },
    {
      'titulo': 'Dragon Ball Z',
      'tituloIngles': 'Dragon Ball Z',
      'tituloOriginal': 'ドラゴンボールZ',
      'tipo': 'Anime',
      'puntuacion': 4.4,
      'genero': 'Acción',
      'autor': 'Akira Toriyama',
      'anio': 1989,
      'estudio': 'Toei Animation',
      'descripcion':
          'Goku y sus amigos defienden la Tierra de amenazas cada vez más poderosas mientras descubren el origen extraterrestre de los Saiyajines.',
      'img': 'https://cdn.myanimelist.net/images/anime/1607/117271.jpg',
    },
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
