// pagina_tierlist.dart
import 'package:flutter/material.dart';
import 'package:ja_rating/Components/CustomProductImage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ja_rating/coloresApp.dart';

class PaginaTierlist extends StatefulWidget {
  final List<Map<String, dynamic>> todosLosProductos;

  const PaginaTierlist({super.key, required this.todosLosProductos});

  @override
  State<PaginaTierlist> createState() => _PaginaTierlistState();
}

class _PaginaTierlistState extends State<PaginaTierlist> {
  static const List<String> tiers = [
    'S',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'Dropeado',
    'No visto',
  ];

  late Map<String, List<Map<String, dynamic>>> _productosPorTier;
  final ScrollController _scrollController = ScrollController();
  bool _autoScrollUp = false;
  bool _autoScrollDown = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _cargarDatosGuardados();
  }

  Future<void> _cargarDatosGuardados() async {
    _prefs = await SharedPreferences.getInstance();
    final String? datosGuardados = _prefs.getString('tierlist_data');
    if (datosGuardados != null) {
      final Map<String, dynamic> decoded = json.decode(datosGuardados);
      _productosPorTier = {};
      for (var tier in tiers) {
        final List<dynamic> lista = decoded[tier] ?? [];
        _productosPorTier[tier] = lista.cast<Map<String, dynamic>>();
      }
    } else {
      _inicializarProductos();
    }
    setState(() {});
  }

  void _inicializarProductos() {
    _productosPorTier = {for (var tier in tiers) tier: []};
    for (var producto in widget.todosLosProductos) {
      _productosPorTier['No visto']!.add(producto);
    }
  }

  Future<void> _guardarDatos() async {
    final Map<String, dynamic> toSave = {};
    for (var entry in _productosPorTier.entries) {
      toSave[entry.key] = entry.value;
    }
    await _prefs.setString('tierlist_data', json.encode(toSave));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cambios guardados')));
  }

  Future<void> _reiniciar() async {
    _inicializarProductos();
    await _prefs.remove('tierlist_data');
    // Forzar una reconstrucción completa de los draggables
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tier list reiniciada')));
  }

  void _moverProducto(
    Map<String, dynamic> producto,
    String tierOrigen,
    String tierDestino,
  ) {
    setState(() {
      _productosPorTier[tierOrigen]!.removeWhere(
        (p) => p['titulo'] == producto['titulo'],
      );
      _productosPorTier[tierDestino]!.add(producto);
    });
  }

  Color _colorPorTier(String tier) {
    switch (tier) {
      case 'S':
        return const Color(0xFFD4AF37);
      case 'A':
        return Colors.blue.shade700;
      case 'B':
        return Colors.green.shade700;
      case 'C':
        return Colors.yellow.shade800;
      case 'D':
        return Colors.orange.shade800;
      case 'E':
        return Colors.red.shade800;
      case 'F':
        return Colors.grey.shade800;
      case 'Dropeado':
        return Colors.purple.shade800;
      case 'No visto':
        return Colors.cyan.shade800;
      default:
        return Coloresapp.colorPrimario;
    }
  }

  void _iniciarAutoScrollUp() {
    if (!_autoScrollUp) {
      _autoScrollUp = true;
      _autoScroll();
    }
  }

  void _iniciarAutoScrollDown() {
    if (!_autoScrollDown) {
      _autoScrollDown = true;
      _autoScroll();
    }
  }

  void _detenerAutoScrollUp() => _autoScrollUp = false;
  void _detenerAutoScrollDown() => _autoScrollDown = false;

  void _autoScroll() {
    if (_autoScrollUp && _scrollController.offset > 0) {
      _scrollController.animateTo(
        _scrollController.offset - 20,
        duration: const Duration(milliseconds: 30),
        curve: Curves.linear,
      );
      Future.delayed(const Duration(milliseconds: 30), _autoScroll);
    } else if (_autoScrollDown &&
        _scrollController.offset < _scrollController.position.maxScrollExtent) {
      _scrollController.animateTo(
        _scrollController.offset + 20,
        duration: const Duration(milliseconds: 30),
        curve: Curves.linear,
      );
      Future.delayed(const Duration(milliseconds: 30), _autoScroll);
    } else {
      _autoScrollUp = false;
      _autoScrollDown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esWeb = MediaQuery.of(context).size.width > 800;
    final double padding = esWeb ? 40 : 20;
    final double alturaFila = 120;

    return Scaffold(
      backgroundColor: Coloresapp.colorFondo,
      appBar: AppBar(
        title: const Text('Tier Lists (Arrastra para reorganizar)'),
        backgroundColor: Coloresapp.colorPrimario,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _guardarDatos,
            tooltip: 'Guardar cambios',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reiniciar,
            tooltip: 'Reiniciar tier list',
          ),
        ],
      ),
      body: Listener(
        onPointerMove: (event) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final localPosition = box.globalToLocal(event.position);
          final double screenHeight = MediaQuery.of(context).size.height;
          final double topThreshold = screenHeight * 0.15;
          final double bottomThreshold = screenHeight * 0.85;

          if (localPosition.dy < topThreshold) {
            _iniciarAutoScrollUp();
          } else {
            _detenerAutoScrollUp();
          }

          if (localPosition.dy > bottomThreshold) {
            _iniciarAutoScrollDown();
          } else {
            _detenerAutoScrollDown();
          }
        },
        onPointerUp: (_) {
          _detenerAutoScrollUp();
          _detenerAutoScrollDown();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(padding),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  tiers.map((tier) {
                    final productos = _productosPorTier[tier] ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _colorPorTier(tier),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tier,
                                style: const TextStyle(
                                  fontFamily: 'HoshikoSatsuki',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${productos.length} títulos',
                              style: const TextStyle(
                                fontFamily: 'HoshikoSatsuki',
                                fontSize: 14,
                                color: Coloresapp.colorTextoFlojo,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DragTarget<Map<String, dynamic>>(
                          onAcceptWithDetails: (details) {
                            final producto = details.data;
                            final tierOrigen = _encontrarTierDeProducto(
                              producto,
                            );
                            if (tierOrigen != null && tierOrigen != tier) {
                              _moverProducto(producto, tierOrigen, tier);
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              constraints: BoxConstraints(
                                minHeight: alturaFila,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _colorPorTier(tier).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: candidateData.isNotEmpty
                                      ? _colorPorTier(tier)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: productos.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Arrastra aquí',
                                        style: TextStyle(
                                          fontFamily: 'HoshikoSatsuki',
                                          color: _colorPorTier(
                                            tier,
                                          ).withOpacity(0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: productos.map((producto) {
                                          return _DraggableProducto(
                                            producto: producto,
                                            tierActual: tier,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                            );
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _encontrarTierDeProducto(Map<String, dynamic> producto) {
    for (var entry in _productosPorTier.entries) {
      if (entry.value.any((p) => p['titulo'] == producto['titulo'])) {
        return entry.key;
      }
    }
    return null;
  }
}

// Widget arrastrable (clave única por producto para evitar conflictos)
class _DraggableProducto extends StatelessWidget {
  final Map<String, dynamic> producto;
  final String tierActual;

  const _DraggableProducto({required this.producto, required this.tierActual});

  @override
  Widget build(BuildContext context) {
    return Draggable<Map<String, dynamic>>(
      data: producto,
      feedback: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8),
        child: _ProductoImage(producto: producto, width: 80),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _ProductoImage(producto: producto, width: 80),
      ),
      child: _ProductoImage(producto: producto, width: 80),
    );
  }
}

class _ProductoImage extends StatelessWidget {
  final Map<String, dynamic> producto;
  final double width;
  const _ProductoImage({required this.producto, required this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomProductImage(
          malId: producto['malId'] ?? 0,
          originalUrl: producto['img'] ?? '',
          width: width,
          height: width * 1.25,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
