// pagina_tierlist.dart
import 'package:flutter/material.dart';
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
