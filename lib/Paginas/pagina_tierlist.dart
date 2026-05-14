// pagina_tierlist.dart
import 'package:flutter/material.dart';
import 'package:ja_rating/Components/CustomProductImage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ja_rating/coloresApp.dart';
import 'package:ja_rating/Components/pagina_tierlist/tab_mi_tierlist.dart';
import 'package:ja_rating/Components/pagina_tierlist/tab_comunidad.dart';

class PaginaTierlist extends StatefulWidget {
  final List<Map<String, dynamic>> todosLosProductos;
  const PaginaTierlist({super.key, required this.todosLosProductos});

  @override
  State<PaginaTierlist> createState() => _PaginaTierlistState();
}

class _PaginaTierlistState extends State<PaginaTierlist>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cambios guardados')));
  }

  Future<void> _reiniciar() async {
    _inicializarProductos();
    await _prefs.remove('tierlist_data');
    // Forzar una reconstrucción completa de los draggables
    setState(() {});
    if (!mounted) return;
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
    return Scaffold(
      backgroundColor: Coloresapp.colorFondo,
      appBar: AppBar(
        title: const Text('Tier Lists'),
        backgroundColor: Coloresapp.colorPrimario,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mi Tier List'),
            Tab(text: 'Comunidad'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics:
            const NeverScrollableScrollPhysics(),
        children: [
          TabMiTierlist(todosLosProductos: widget.todosLosProductos),
          const TabComunidad(),
        ],
      ),
    );
  }
}
