import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:ja_rating/coloresApp.dart';
import 'package:ja_rating/Components/CustomProductImage.dart';

class TabMiTierlist extends StatefulWidget {
  final List<Map<String, dynamic>> todosLosProductos;
  const TabMiTierlist({super.key, required this.todosLosProductos});

  @override
  State<TabMiTierlist> createState() => _TabMiTierlistState();
}

class _TabMiTierlistState extends State<TabMiTierlist> {
  late SharedPreferences _prefs;
  Map<String, List<Map<String, dynamic>>> _miTierList = {};
  final ScrollController _scrollController = ScrollController();
  bool _autoScrollUp = false;
  bool _autoScrollDown = false;
  final List<String> _tiers = [
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

  @override
  void initState() {
    super.initState();
    _cargarMiTierListLocal();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarMiTierListLocal() async {
    _prefs = await SharedPreferences.getInstance();
    final String? datosGuardados = _prefs.getString('tierlist_data');
    if (datosGuardados != null) {
      final Map<String, dynamic> decoded = json.decode(datosGuardados);
      setState(() {
        _miTierList = {};
        for (var tier in _tiers) {
          final List<dynamic> lista = decoded[tier] ?? [];
          _miTierList[tier] = lista.cast<Map<String, dynamic>>();
        }
      });
    } else {
      _inicializarMiTierList();
    }
  }

  void _inicializarMiTierList() {
    setState(() {
      _miTierList = {for (var tier in _tiers) tier: []};
      for (var producto in widget.todosLosProductos) {
        _miTierList['No visto']!.add(producto);
      }
    });
    _guardarMiTierListLocal();
  }

  Future<void> _guardarMiTierListLocal() async {
    final Map<String, dynamic> toSave = {};
    for (var entry in _miTierList.entries) {
      toSave[entry.key] = entry.value;
    }
    await _prefs.setString('tierlist_data', json.encode(toSave));
  }

  void _reiniciarMiTierList() {
    _inicializarMiTierList();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tier list reiniciada')));
  }

  Future<void> _publicarMiTierList() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para publicar')),
      );
      return;
    }
    try {
      final Map<String, dynamic> tierData = {};
      for (var entry in _miTierList.entries) {
        tierData[entry.key] = entry.value;
      }
      await FirebaseFirestore.instance.collection('tierlists_comunidad').add({
        'ownerId': currentUser.uid,
        'ownerName': currentUser.displayName ?? 'Anonimo',
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
        'commentsCount': 0,
        ...tierData,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tier list publicada en la comunidad')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al publicar: $e')));
    }
  }

  // Mover producto a otro tier (sin reordenar dentro del mismo)
  void _moverProductoATier(
    Map<String, dynamic> producto,
    String tierOrigen,
    String tierDestino,
  ) {
    if (tierOrigen == tierDestino) return;
    setState(() {
      _miTierList[tierOrigen]!.removeWhere(
        (p) => p['titulo'] == producto['titulo'],
      );
      _miTierList[tierDestino]!.add(producto);
    });
    _guardarMiTierListLocal();
  }

  // Reordenar dentro del mismo tier
  void _reordenarProducto(String tier, int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    setState(() {
      final lista = _miTierList[tier]!;
      final item = lista.removeAt(oldIndex);
      lista.insert(newIndex, item);
    });
    _guardarMiTierListLocal();
  }

  // ===================== AUTO SCROLL VERTICAL =====================
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
    return Listener(
      onPointerMove: (event) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(event.position);
        final double screenHeight = MediaQuery.of(context).size.height;
        if (localPosition.dy < screenHeight * 0.15)
          _iniciarAutoScrollUp();
        else
          _detenerAutoScrollUp();
        if (localPosition.dy > screenHeight * 0.85)
          _iniciarAutoScrollDown();
        else
          _detenerAutoScrollDown();
      },
      onPointerUp: (_) {
        _detenerAutoScrollUp();
        _detenerAutoScrollDown();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _tiers.map((tier) {
                  final items = _miTierList[tier] ?? [];
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
                            '${items.length} títulos',
                            style: const TextStyle(
                              fontFamily: 'HoshikoSatsuki',
                              fontSize: 14,
                              color: Coloresapp.colorTextoFlojo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Área de drop (DragTarget exterior) para mover a otro tier (solo si se suelta en el fondo)
                      DragTarget<Map<String, dynamic>>(
                        onAcceptWithDetails: (details) {
                          final data = details.data;
                          final producto =
                              data['producto'] as Map<String, dynamic>;
                          final tierOrigen = data['tierOrigen'] as String;
                          if (tierOrigen != tier) {
                            _moverProductoATier(producto, tierOrigen, tier);
                          }
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(
                              0,
                              8,
                              0,
                              16,
                            ), // espacio suficiente para la barra nativa
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
                            child: items.isEmpty
                                ? Center(
                                    child: Text(
                                      'Arrastra aquí',
                                      style: TextStyle(
                                        color: _colorPorTier(
                                          tier,
                                        ).withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: items.asMap().entries.map((
                                        entry,
                                      ) {
                                        final index = entry.key;
                                        final producto = entry.value;
                                        // Cada producto es un DragTarget para reordenar dentro del mismo tier
                                        return _DraggableProductoConReorder(
                                          key: ValueKey(producto['titulo']),
                                          producto: producto,
                                          tierActual: tier,
                                          indiceActual: index,
                                          onReorder: (oldIndex, newIndex) {
                                            _reordenarProducto(
                                              tier,
                                              oldIndex,
                                              newIndex,
                                            );
                                          },
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
}

// Widget que combina Draggable y DragTarget para reordenar dentro del mismo tier
class _DraggableProductoConReorder extends StatelessWidget {
  final Map<String, dynamic> producto;
  final String tierActual;
  final int indiceActual;
  final Function(int oldIndex, int newIndex) onReorder;

  const _DraggableProductoConReorder({
    super.key,
    required this.producto,
    required this.tierActual,
    required this.indiceActual,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Map<String, dynamic>>(
      onAccept: (data) {
        final productoData = data;
        final tierOrigen = productoData['tierOrigen'] as String;
        final indexOrigen = productoData['indexOrigen'] as int;
        if (tierOrigen == tierActual) {
          // Reordenar dentro del mismo tier
          onReorder(indexOrigen, indiceActual);
        } else {
          // Mover a otro tier (esto lo maneja el DragTarget exterior, pero aquí también podemos notificarlo)
          // Para evitar duplicados, delegamos en el DragTarget exterior. No hacemos nada aquí.
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Draggable<Map<String, dynamic>>(
          data: {
            'producto': producto,
            'tierOrigen': tierActual,
            'indexOrigen': indiceActual,
          },
          feedback: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: _ProductoImage(producto: producto, width: 80),
          ),
          childWhenDragging: Opacity(
            opacity: 0.4,
            child: _ProductoImage(producto: producto, width: 80),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomProductImage(
                malId: producto['malId'] ?? 0,
                originalUrl: producto['img'] ?? '',
                width: 80,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
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
