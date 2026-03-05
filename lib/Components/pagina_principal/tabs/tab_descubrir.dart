import 'package:flutter/material.dart';
import 'package:ja_rating/coloresApp.dart';
import 'package:ja_rating/Components/Login/texto_normal.dart';
import 'package:ja_rating/Components/pagina_principal/productos_cartas.dart';

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

class _TabDescubrirState extends State<TabDescubrir> {
  String busqueda = '';
  String filtro = 'Todo';
  final List<String> filtros = ['Todo', 'Anime', 'Manga', 'Manhwa', 'Manhua', 'Donghua'];

  @override
  Widget build(BuildContext context) {
    final filtrados = widget.todosLosItems.where((item) {
      final coincideFiltro = filtro == 'Todo' || item['tipo'] == filtro;
      final coincideBusqueda =
          item['titulo'].toLowerCase().contains(busqueda.toLowerCase()) ||
          item['tituloIngles'].toLowerCase().contains(busqueda.toLowerCase()) ||
          item['tituloOriginal'].toLowerCase().contains(busqueda.toLowerCase());
      return coincideFiltro && coincideBusqueda;
    }).toList();

    final int columnas = widget.esWeb ? 4 : 2;
    final double padding = widget.esWeb ? 40 : 20;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(padding, 20, padding, 0),
            child: TextoNormal(contingutText: 'Descubrir'),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Container(
              decoration: BoxDecoration(
                color: Coloresapp.colorBlanco,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12),
                ],
              ),
              child: TextField(
                onChanged: (v) => setState(() => busqueda = v),
                decoration: const InputDecoration(
                  hintText: 'Buscar en español, inglés u original...',
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
              padding: EdgeInsets.only(left: padding),
              itemCount: filtros.length,
              itemBuilder: (context, i) {
                final activo = filtro == filtros[i];
                return GestureDetector(
                  onTap: () => setState(() => filtro = filtros[i]),
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
              padding: EdgeInsets.symmetric(horizontal: padding),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnas,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.6,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}