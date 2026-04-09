// pagina_tierlist.dart
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _inicializarProductos();
  }

  void _inicializarProductos() {
    _productosPorTier = {
      for (var tier in tiers) tier: [],
    };

    for (var producto in widget.todosLosProductos) {
      final punt = producto['puntuacion'] as double;
      String tier;
      if (punt >= 4.7) tier = 'S';
      else if (punt >= 4.4) tier = 'A';
      else if (punt >= 4.0) tier = 'B';
      else if (punt >= 3.5) tier = 'C';
      else if (punt >= 3.0) tier = 'D';
      else if (punt >= 2.5) tier = 'E';
      else tier = 'F';
      _productosPorTier[tier]!.add(producto);
    }
  }

  void _moverProducto(Map<String, dynamic> producto, String tierOrigen, String tierDestino) {
    setState(() {
      _productosPorTier[tierOrigen]!.removeWhere((p) => p['titulo'] == producto['titulo']);
      _productosPorTier[tierDestino]!.add(producto);
    });
  }

  Color _colorPorTier(String tier) {
    switch (tier) {
      case 'S': return const Color(0xFFD4AF37);
      case 'A': return Colors.blue.shade700;
      case 'B': return Colors.green.shade700;
      case 'C': return Colors.yellow.shade800;
      case 'D': return Colors.orange.shade800;
      case 'E': return Colors.red.shade800;
      case 'F': return Colors.grey.shade800;
      case 'Dropeado': return Colors.purple.shade800;
      case 'No visto': return Colors.cyan.shade800;
      default: return Coloresapp.colorPrimario;
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
      ),
      body: CustomScrollView(
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
                      // Cabecera del tier
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      // Área de destino (DragTarget)
                      DragTarget<Map<String, dynamic>>(
                        onAcceptWithDetails: (details) {
                          final producto = details.data;
                          final tierOrigen = _encontrarTierDeProducto(producto);
                          if (tierOrigen != null && tierOrigen != tier) {
                            _moverProducto(producto, tierOrigen, tier);
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            constraints: BoxConstraints(minHeight: alturaFila), // CORRECCIÓN
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
                                        color: _colorPorTier(tier).withOpacity(0.6),
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

// Widget que representa un producto arrastrable
class _DraggableProducto extends StatelessWidget {
  final Map<String, dynamic> producto;
  final String tierActual;

  const _DraggableProducto({
    required this.producto,
    required this.tierActual,
  });

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

// Widget que muestra la imagen del producto
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
        child: Image.network(
          producto['img'] ?? '',
          width: width,
          height: width * 1.25,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: width,
            height: width * 1.25,
            color: Coloresapp.colorPrimario,
            child: const Icon(Icons.image_not_supported_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }
}