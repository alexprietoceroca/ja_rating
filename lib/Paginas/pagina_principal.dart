import 'package:flutter/material.dart';
import 'package:ja_rating/coloresApp.dart';
import 'package:ja_rating/components/Login/texto_normal.dart';
import 'package:ja_rating/components/productos_cartas.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  int _indiceSeleccionado = 0;

  final List<Map<String, dynamic>> tendencias = [
    {'titulo': 'Dandadan', 'tipo': 'Anime', 'puntuacion': 9.1, 'genero': 'Sobrenatural', 'img': 'https://cdn.myanimelist.net/images/anime/1906/145217.jpg'},
    {'titulo': 'Solo Leveling', 'tipo': 'Manhwa', 'puntuacion': 9.4, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/manga/3/222295.jpg'},
    {'titulo': 'Vinland Saga', 'tipo': 'Manga', 'puntuacion': 9.0, 'genero': 'Histórico', 'img': 'https://cdn.myanimelist.net/images/manga/2/188925.jpg'},
    {'titulo': 'Frieren', 'tipo': 'Anime', 'puntuacion': 9.3, 'genero': 'Fantasía', 'img': 'https://cdn.myanimelist.net/images/anime/1015/138006.jpg'},
    {'titulo': 'Tower of God', 'tipo': 'Manhwa', 'puntuacion': 8.9, 'genero': 'Aventura', 'img': 'https://cdn.myanimelist.net/images/manga/2/164417.jpg'},
  ];

  final List<Map<String, dynamic>> populares = [
    {'titulo': 'Attack on Titan', 'tipo': 'Anime', 'puntuacion': 9.0, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/anime/1948/120625.jpg'},
    {'titulo': 'One Piece', 'tipo': 'Anime', 'puntuacion': 9.1, 'genero': 'Aventura', 'img': 'https://cdn.myanimelist.net/images/anime/6/73245.jpg'},
    {'titulo': 'Berserk', 'tipo': 'Manga', 'puntuacion': 9.4, 'genero': 'Dark Fantasy', 'img': 'https://cdn.myanimelist.net/images/manga/1/157897.jpg'},
    {'titulo': 'Demon Slayer', 'tipo': 'Anime', 'puntuacion': 8.7, 'genero': 'Acción', 'img': 'https://cdn.myanimelist.net/images/anime/1286/99889.jpg'},
    {'titulo': 'Jujutsu Kaisen', 'tipo': 'Anime', 'puntuacion': 8.6, 'genero': 'Sobrenatural', 'img': 'https://cdn.myanimelist.net/images/anime/1171/109222.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloresapp.colorFondo,
      body: IndexedStack(
        index: _indiceSeleccionado,
        children: [
          _ContenidoInicio(tendencias: tendencias, populares: populares),
          _ContenidoDescubrir(todosLosItems: [...tendencias, ...populares]),
          const _ContenidoPerfil(),
          const _ContenidoMas(),
        ],
      ),
      bottomNavigationBar: _NavegacionInferior(
        indiceSeleccionado: _indiceSeleccionado,
        alSeleccionar: (i) => setState(() => _indiceSeleccionado = i),
      ),
    );
  }
}

class _ContenidoInicio extends StatelessWidget {
  final List<Map<String, dynamic>> tendencias;
  final List<Map<String, dynamic>> populares;
  const _ContenidoInicio({required this.tendencias, required this.populares});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Coloresapp.colorPrimario, Coloresapp.colorRojoOscuro],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenido de vuelta',
                              style: TextStyle(
                                color: Coloresapp.colorBlanco.withOpacity(0.75),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'JA-Rating',
                              style: TextStyle(
                                color: Coloresapp.colorBlanco,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Coloresapp.colorBlanco.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Coloresapp.colorBlanco),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _CajaEstadistica(valor: '2.4K', etiqueta: 'Títulos'),
                        const SizedBox(width: 10),
                        _CajaEstadistica(valor: '18K', etiqueta: 'Usuarios'),
                        const SizedBox(width: 10),
                        _CajaEstadistica(valor: '94K', etiqueta: 'Ratings'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _EncabezadoSeccion(
              titulo: 'En Tendencia',
              etiqueta: 'HOT',
              icono: Icons.local_fire_department_rounded,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 290,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              itemCount: tendencias.length,
              itemBuilder: (_, i) => ProductosCarta(
                titulo: tendencias[i]['titulo'],
                genero: tendencias[i]['genero'],
                tipo: tendencias[i]['tipo'],
                puntuacion: tendencias[i]['puntuacion'].toDouble(),
                urlImagen: tendencias[i]['img'],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _EncabezadoSeccion(
              titulo: 'Populares esta semana',
              subtitulo: 'Los favoritos de la comunidad',
              icono: Icons.trending_up_rounded,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 290,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              itemCount: populares.length,
              itemBuilder: (_, i) => ProductosCarta(
                titulo: populares[i]['titulo'],
                genero: populares[i]['genero'],
                tipo: populares[i]['tipo'],
                puntuacion: populares[i]['puntuacion'].toDouble(),
                urlImagen: populares[i]['img'],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _CajaEstadistica extends StatelessWidget {
  final String valor;
  final String etiqueta;
  const _CajaEstadistica({required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Coloresapp.colorBlanco.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(valor, style: const TextStyle(color: Coloresapp.colorBlanco, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(etiqueta, style: TextStyle(color: Coloresapp.colorBlanco.withOpacity(0.7), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _EncabezadoSeccion extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final String? etiqueta;
  final IconData icono;
  const _EncabezadoSeccion({required this.titulo, this.subtitulo, this.etiqueta, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: Coloresapp.colorPrimario, size: 22),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111111)),
        ),
        if (etiqueta != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Coloresapp.colorPrimario,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              etiqueta!,
              style: const TextStyle(color: Coloresapp.colorBlanco, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
        ],
        if (subtitulo != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(subtitulo!, style: const TextStyle(fontSize: 12, color: Coloresapp.colorTextoFlojo)),
          ),
        ],
      ],
    );
  }
}

class _ContenidoDescubrir extends StatefulWidget {
  final List<Map<String, dynamic>> todosLosItems;
  const _ContenidoDescubrir({required this.todosLosItems});

  @override
  State<_ContenidoDescubrir> createState() => _ContenidoDescubrirState();
}

class _ContenidoDescubrirState extends State<_ContenidoDescubrir> {
  String _busqueda = '';
  String _filtro = 'Todo';
  final List<String> filtros = ['Todo', 'Anime', 'Manga', 'Manhwa', 'Manhua', 'Donghua'];

  @override
  Widget build(BuildContext context) {
    final filtrados = widget.todosLosItems.where((item) {
      final coincideFiltro = _filtro == 'Todo' || item['tipo'] == _filtro;
      final coincideBusqueda = item['titulo'].toLowerCase().contains(_busqueda.toLowerCase());
      return coincideFiltro && coincideBusqueda;
    }).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: TextoNormal(contingutText: 'Descubrir'),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Coloresapp.colorBlanco,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Coloresapp.colorBlanco.withOpacity(0.06), blurRadius: 12),
                ],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _busqueda = v),
                decoration: const InputDecoration(
                  hintText: 'Buscar anime, manga, manhwa...',
                  hintStyle: TextStyle(color: Coloresapp.colorTextoFlojo, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: Coloresapp.colorPrimario),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              itemCount: filtros.length,
              itemBuilder: (_, i) {
                final activo = _filtro == filtros[i];
                return GestureDetector(
                  onTap: () => setState(() => _filtro = filtros[i]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: activo ? Coloresapp.colorPrimario : Coloresapp.colorBlanco,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8),
                      ],
                    ),
                    child: Text(
                      filtros[i],
                      style: TextStyle(
                        color: activo ? Coloresapp.colorBlanco : Coloresapp.colorTexto,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.65,
              ),
              itemCount: filtrados.length,
              itemBuilder: (_, i) => ProductosCarta(
                titulo: filtrados[i]['titulo'],
                genero: filtrados[i]['genero'],
                tipo: filtrados[i]['tipo'],
                puntuacion: filtrados[i]['puntuacion'].toDouble(),
                urlImagen: filtrados[i]['img'],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContenidoPerfil extends StatelessWidget {
  const _ContenidoPerfil();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextoNormal(contingutText: 'Mi Perfil'),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Coloresapp.colorPrimario,
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Akira_Fan',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF111111)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Miembro desde 2023',
                      style: TextStyle(fontSize: 13, color: Coloresapp.colorTextoFlojo),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _EstadisticaPerfil(valor: '47', etiqueta: 'Calificados'),
                const SizedBox(width: 12),
                _EstadisticaPerfil(valor: '23', etiqueta: 'Comentarios'),
                const SizedBox(width: 12),
                _EstadisticaPerfil(valor: '5', etiqueta: 'Tier Lists'),
              ],
            ),
            const SizedBox(height: 24),
            _ItemMenuPerfil(icono: Icons.star_rounded, etiqueta: 'Mis calificaciones', sub: '47 títulos calificados'),
            _ItemMenuPerfil(icono: Icons.chat_bubble_outline_rounded, etiqueta: 'Mis comentarios', sub: '23 comentarios'),
            _ItemMenuPerfil(icono: Icons.emoji_events_rounded, etiqueta: 'Mis Tier Lists', sub: '5 listas creadas'),
            _ItemMenuPerfil(icono: Icons.forum_rounded, etiqueta: 'Foros visitados', sub: '12 hilos activos'),
          ],
        ),
      ),
    );
  }
}

class _EstadisticaPerfil extends StatelessWidget {
  final String valor;
  final String etiqueta;
  const _EstadisticaPerfil({required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Coloresapp.colorBlanco,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12),
          ],
        ),
        child: Column(
          children: [
            Text(valor, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Coloresapp.colorPrimario)),
            const SizedBox(height: 4),
            Text(etiqueta, style: const TextStyle(fontSize: 11, color: Coloresapp.colorTextoFlojo)),
          ],
        ),
      ),
    );
  }
}

class _ItemMenuPerfil extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String sub;
  const _ItemMenuPerfil({required this.icono, required this.etiqueta, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Coloresapp.colorBlanco,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Icon(icono, color: Coloresapp.colorPrimario, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF111111))),
                const SizedBox(height: 3),
                Text(sub, style: const TextStyle(fontSize: 12, color: Coloresapp.colorTextoFlojo)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Coloresapp.colorTextoFlojo),
        ],
      ),
    );
  }
}

class _ContenidoMas extends StatelessWidget {
  const _ContenidoMas();

  @override
  Widget build(BuildContext context) {
    final foros = [
      {'titulo': '¿Cuál es el mejor arco de One Piece?', 'respuestas': 42, 'destacado': true},
      {'titulo': 'Teorías sobre Jujutsu Kaisen final', 'respuestas': 87, 'destacado': true},
      {'titulo': 'Top manhwas para empezar en 2025', 'respuestas': 23, 'destacado': false},
      {'titulo': 'Dandadan vs Chainsaw Man', 'respuestas': 61, 'destacado': false},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextoNormal(contingutText: 'Más'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _CartaFuncionalidad(
                    icono: Icons.emoji_events_rounded,
                    etiqueta: 'Tier Lists',
                    descripcion: 'Crea y comparte tus rankings',
                    color: Coloresapp.colorNaranja,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _CartaFuncionalidad(
                    icono: Icons.forum_rounded,
                    etiqueta: 'Foros',
                    descripcion: 'Discute con la comunidad',
                    color: Coloresapp.colorMorado,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Foros populares',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111111)),
            ),
            const SizedBox(height: 12),
            ...foros.map(
              (f) => _ItemForo(
                titulo: f['titulo'] as String,
                respuestas: f['respuestas'] as int,
                destacado: f['destacado'] as bool,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartaFuncionalidad extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String descripcion;
  final Color color;
  const _CartaFuncionalidad({required this.icono, required this.etiqueta, required this.descripcion, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Coloresapp.colorBlanco,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 16),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, color: color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF111111))),
          const SizedBox(height: 4),
          Text(descripcion, style: const TextStyle(fontSize: 12, color: Coloresapp.colorTextoFlojo, height: 1.4)),
        ],
      ),
    );
  }
}

class _ItemForo extends StatelessWidget {
  final String titulo;
  final int respuestas;
  final bool destacado;
  const _ItemForo({required this.titulo, required this.respuestas, required this.destacado});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Coloresapp.colorBlanco,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (destacado)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Coloresapp.colorPrimario.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department_rounded, size: 12, color: Coloresapp.colorPrimario),
                        const SizedBox(width: 3),
                        const Text(
                          'HOT',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Coloresapp.colorPrimario, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF111111), height: 1.3)),
                const SizedBox(height: 4),
                Text('$respuestas respuestas', style: const TextStyle(fontSize: 11, color: Coloresapp.colorTextoFlojo)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Coloresapp.colorTextoFlojo),
        ],
      ),
    );
  }
}

class _NavegacionInferior extends StatelessWidget {
  final int indiceSeleccionado;
  final Function(int) alSeleccionar;
  const _NavegacionInferior({required this.indiceSeleccionado, required this.alSeleccionar});

  @override
  Widget build(BuildContext context) {
    final elementos = [
      {'icono': Icons.home_rounded, 'etiqueta': 'Inicio'},
      {'icono': Icons.explore_rounded, 'etiqueta': 'Descubrir'},
      {'icono': Icons.person_rounded, 'etiqueta': 'Perfil'},
      {'icono': Icons.more_horiz_rounded, 'etiqueta': 'Más'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Coloresapp.colorBlanco,
        boxShadow: [
          BoxShadow(color: Coloresapp.colorSombraNav, blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(elementos.length, (i) {
              final activo = indiceSeleccionado == i;
              return GestureDetector(
                onTap: () => alSeleccionar(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: activo ? Coloresapp.colorPrimario.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        elementos[i]['icono'] as IconData,
                        color: activo ? Coloresapp.colorPrimario : Coloresapp.colorTextoFlojo,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        elementos[i]['etiqueta'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: activo ? FontWeight.w800 : FontWeight.w500,
                          color: activo ? Coloresapp.colorPrimario : Coloresapp.colorTextoFlojo,
                        ),
                      ),
                      if (activo)
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Coloresapp.colorPrimario,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}