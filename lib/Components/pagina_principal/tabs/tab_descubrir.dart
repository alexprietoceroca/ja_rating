// tab_descubrir.dart
import 'package:flutter/material.dart';
import 'package:ja_rating/Paginas/pagina_producto.dart';
import 'package:ja_rating/Paginas/pagina_login.dart'; // Añadir import
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/Login/texto_normal.dart';
import 'package:ja_rating/Components/pagina_principal/productos_cartas.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TabDescubrir extends StatefulWidget {
  final List<Map<String, dynamic>> todosLosItems;
  final bool esWeb;

  const TabDescubrir({
    super.key,
    required this.todosLosItems,
    required this.esWeb,
  });

  @override
  State<TabDescubrir> createState() => _TabDescubrirState();
}

class _TabDescubrirState extends State<TabDescubrir>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  String busqueda = '';
  String filtro = 'Todo';
  final List<String> filtros = [
    'Todo',
    'Anime',
    'Manga',
    'Manhwa',
    'Manhua',
    'Donghua',
  ];

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PaginaLogin()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final filtrados = widget.todosLosItems.where((item) {
      final coincideFiltro = filtro == 'Todo' || item['tipo'] == filtro;
      final coincideBusqueda =
          item['titulo'].toLowerCase().contains(busqueda.toLowerCase()) ||
          item['tituloIngles'].toLowerCase().contains(busqueda.toLowerCase()) ||
          item['tituloOriginal'].toLowerCase().contains(busqueda.toLowerCase());
      return coincideFiltro && coincideBusqueda;
    }).toList();

    final double padding = widget.esWeb ? 40 : 20;
    const int columnas = 2;
    final double anchoCarta =
        (MediaQuery.of(context).size.width -
            (padding * 2) -
            (columnas - 1) * 14) /
        columnas;
    final double altoCarta =
        ProductosCarta.calcularAltura(anchoCarta, mostrarExtra: true) +
        20; // +20 para evitar overflow
    final double aspectRatio = anchoCarta / altoCarta;

    return Stack(
      children: [
        // Fondo animado con imagen de mapa antiguo
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final double scale = 1.0 + _animController.value * 0.03;
            final double dx = _animController.value * 15;
            final double dy = _animController.value * 8;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(dx, dy)
                ..scale(scale),
              child: Image.asset(
                'assets/imagenes/mapa_antiguo.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) =>
                    Container(color: Coloresapp.colorFondoMapa),
              ),
            );
          },
        ),
        // Capa oscura semitransparente
        Container(color: Colors.black.withOpacity(0.35)),

        SafeArea(
          child: Column(
            children: [
              // Cabecera con logo, título y logout
              Padding(
                padding: EdgeInsets.fromLTRB(padding, 20, padding, 0),
                child: Row(
                  children: [
                    // Logo a la izquierda
                    Image.asset(
                      'assets/imagenes/logo.png',
                      width: 40,
                      height: 40,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, color: Colors.white),
                    ),
                    const Spacer(), // Empuja el siguiente elemento al centro
                    // Título centrado
                    TextoNormal(
                      contingutText: 'Descubrir',
                      colorText: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    const Spacer(), // Empuja el icono a la derecha
                    // Icono de logout
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaginaLogin(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Barra de búsqueda
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Container(
                  decoration: BoxDecoration(
                    color: Coloresapp.colorBlanco,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => busqueda = v),
                    decoration: const InputDecoration(
                      hintText: 'Buscar en español, inglés u original...',
                      hintStyle: TextStyle(
                        color: Coloresapp.colorTextoFlojo,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Coloresapp.colorPrimario,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Filtros horizontales
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: padding),
                  itemCount: filtros.length,
                  itemBuilder: (context, i) {
                    final activo = filtro == filtros[i];
                    return GestureDetector(
                      onTap: () => setState(() => filtro = filtros[i]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: activo
                              ? Coloresapp.colorPrimario
                              : Coloresapp.colorBlanco,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          filtros[i],
                          style: TextStyle(
                            color: activo
                                ? Coloresapp.colorBlanco
                                : Coloresapp.colorTexto,
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
              // Grid de productos
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnas,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: filtrados.length,
                  itemBuilder: (context, i) {
                    return ProductosCarta(
                      titulo: filtrados[i]['titulo'],
                      tituloIngles: filtrados[i]['tituloIngles'],
                      tituloOriginal: filtrados[i]['tituloOriginal'],
                      genero: filtrados[i]['genero'],
                      tipo: filtrados[i]['tipo'],
                      puntuacion: filtrados[i]['puntuacion'].toDouble(),
                      urlImagen: filtrados[i]['img'],
                      descripcion: filtrados[i]['descripcion'],
                      mostrarExtra: true,
                      autor: filtrados[i]['autor'] ?? '',
                      anio: filtrados[i]['anio'] ?? 0,
                      estudio: filtrados[i]['estudio'] ?? '',
                      anchoCarta: anchoCarta,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PaginaProducto(producto: filtrados[i]),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
