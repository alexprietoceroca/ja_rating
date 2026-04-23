import 'package:flutter/material.dart';
import 'package:ja_rating/Components/Models/producto_model.dart';
import 'package:ja_rating/Components/Services/jikan_service.dart';
import 'package:ja_rating/Components/pagina_principal/widgets/barra_navegacion.dart';
import 'package:ja_rating/Components/pagina_principal/tabs/tab_inicio.dart';
import 'package:ja_rating/Components/pagina_principal/tabs/tab_descubrir.dart';
import 'package:ja_rating/Components/pagina_principal/tabs/tab_perfil.dart';
import 'package:ja_rating/Components/pagina_principal/tabs/tab_mas.dart';
import 'package:ja_rating/coloresApp.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  int indiceSeleccionado = 0;
  
  List<ProductoModel> tendencias = [];
  List<ProductoModel> populares = [];
  List<ProductoModel> todosProductos = [];
  
  bool isLoading = true;
  String? errorMessage;
  
  final JikanService _jikanService = JikanService();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      print('Iniciando carga de datos...');
      
      final results = await Future.wait([
        _jikanService.getTopAnime(limit: 10),
        _jikanService.getTopManga(limit: 10),
        _jikanService.getTodosProductos(),
      ]).timeout(const Duration(seconds: 30));
      
      setState(() {
        tendencias = results[0];
        populares = results[1];
        todosProductos = results[2];
        isLoading = false;
      });
      
      print('Datos cargados: ${tendencias.length} animes, ${populares.length} mangas, ${todosProductos.length} total');
    } catch (e) {
      print('Error: $e');
      setState(() {
        errorMessage = 'Error al cargar datos: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final bool esWeb = anchoPantalla > 800;

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Cargando datos...',
                style: TextStyle(color: Coloresapp.colorTextoFlojo),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BarraNavegacion(
          indiceSeleccionado: indiceSeleccionado,
          alSeleccionar: (i) => setState(() => indiceSeleccionado = i),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _cargarDatos,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BarraNavegacion(
          indiceSeleccionado: indiceSeleccionado,
          alSeleccionar: (i) => setState(() => indiceSeleccionado = i),
        ),
      );
    }

    final List<Widget> paginas = [
      TabInicio(
        tendencias: tendencias.map((p) => p.toMap()).toList(),
        populares: populares.map((p) => p.toMap()).toList(),
        esWeb: esWeb,
      ),
      TabDescubrir(
        todosLosItems: todosProductos.map((p) => p.toMap()).toList(),
        esWeb: esWeb,
      ),
      const TabPerfil(),
      TabMas(todosLosProductos: todosProductos.map((p) => p.toMap()).toList()),
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