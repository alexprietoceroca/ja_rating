// lib/Paginas/pagina_foro.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/Login/texto_normal.dart';

class PaginaForo extends StatefulWidget {
  const PaginaForo({super.key});

  @override
  State<PaginaForo> createState() => _PaginaForoState();
}

class _PaginaForoState extends State<PaginaForo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _forosPopulares = [];
  List<Map<String, dynamic>> _forosRecientes = [];
  List<Map<String, dynamic>> _forosCategoria = [];
  bool _cargando = true;
  String _categoriaSeleccionada = 'Todo';

  final List<String> _categorias = [
    'Todo',
    'Anime',
    'Manga',
    'Manhwa',
    'Donghua',
    'Noticias',
    'Debates',
    'Recomendaciones',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarForos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarForos() async {
    setState(() => _cargando = true);
    try {
      final forosSnapshot = await _firestore
          .collection('foros')
          .orderBy('fecha', descending: true)
          .limit(50)
          .get();

      _forosRecientes = forosSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
          'fecha': (doc.data()['fecha'] as Timestamp).toDate(),
        };
      }).toList();

      _forosPopulares = List.from(_forosRecientes);
      _forosPopulares.sort((a, b) {
        int scoreA = (a['respuestas'] as int) + ((a['vistas'] as int) ~/ 100);
        int scoreB = (b['respuestas'] as int) + ((b['vistas'] as int) ~/ 100);
        return scoreB.compareTo(scoreA);
      });
      if (_forosPopulares.length > 10)
        _forosPopulares = _forosPopulares.sublist(0, 10);
      _forosCategoria = List.from(_forosRecientes);
    } catch (e) {
      print('Error al cargar foros: $e');
      _forosRecientes = [];
      _forosPopulares = [];
      _forosCategoria = [];
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _filtrarPorCategoria() {
    setState(() {
      if (_categoriaSeleccionada == 'Todo') {
        _forosCategoria = List.from(_forosRecientes);
      } else {
        _forosCategoria = _forosRecientes
            .where((foro) => foro['categoria'] == _categoriaSeleccionada)
            .toList();
      }
    });
  }

  void _nuevoForo() {
    showDialog(
      context: context,
      builder: (context) =>
          _DialogNuevoForo(onCreate: (foro) async => await _guardarForo(foro)),
    );
  }

  Future<void> _guardarForo(Map<String, dynamic> foro) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para crear un foro'),
        ),
      );
      return;
    }
    try {
      final nuevoForo = {
        'titulo': foro['titulo'],
        'categoria': foro['categoria'],
        'tipo': foro['tipo'],
        'contenido': foro['contenido'],
        'autor': user.displayName ?? user.email?.split('@')[0] ?? 'Usuario',
        'autorId': user.uid,
        'respuestas': 0,
        'vistas': 0,
        'fecha': DateTime.now(),
        'destacado': false,
      };
      await _firestore.collection('foros').add(nuevoForo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foro creado exitosamente')),
        );
        _cargarForos();
      }
    } catch (e) {
      print('Error al guardar foro: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _mostrarBuscador() {
    showDialog(
      context: context,
      builder: (context) => _DialogBuscadorForos(
        foros: _forosRecientes,
        onTap: (foro) => _abrirForo(foro),
      ),
    );
  }

  void _abrirForo(Map<String, dynamic> foro) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaginaDetalleForo(foro: foro)),
    ).then((_) => _cargarForos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Coloresapp.colorFondo,
      appBar: AppBar(
        backgroundColor: Coloresapp.colorPrimario,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Foros',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _mostrarBuscador,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Populares'),
            Tab(text: 'Recientes'),
            Tab(text: 'Categorías'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nuevoForo,
        backgroundColor: Coloresapp.colorPrimario,
        child: const Icon(Icons.add_comment_rounded, color: Colors.white),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _ListaForos(foros: _forosPopulares, onTap: _abrirForo),
                _ListaForos(foros: _forosRecientes, onTap: _abrirForo),
                Column(
                  children: [
                    Container(
                      height: 50,
                      margin: const EdgeInsets.all(16),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categorias.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categorias[index];
                          return FilterChip(
                            label: Text(cat),
                            selected: _categoriaSeleccionada == cat,
                            selectedColor: Coloresapp.colorPrimario.withOpacity(
                              0.2,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _categoriaSeleccionada = cat;
                                _filtrarPorCategoria();
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _ListaForos(
                        foros: _forosCategoria,
                        onTap: _abrirForo,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

// -------------------------------
// LISTA DE FOROS
// -------------------------------
class _ListaForos extends StatelessWidget {
  final List<Map<String, dynamic>> foros;
  final Function(Map<String, dynamic>) onTap;
  const _ListaForos({required this.foros, required this.onTap});
  @override
  Widget build(BuildContext context) {
    if (foros.isEmpty)
      return const Center(
        child: Text('No hay foros disponibles. ¡Crea el primero!'),
      );
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: foros.length,
      itemBuilder: (context, index) =>
          _CardForo(foro: foros[index], onTap: () => onTap(foros[index])),
    );
  }
}

class _CardForo extends StatelessWidget {
  final Map<String, dynamic> foro;
  final VoidCallback onTap;
  const _CardForo({required this.foro, required this.onTap});

  Color _getColorCategoria(String categoria) {
    switch (categoria) {
      case 'Anime':
        return Coloresapp.colorPrimario;
      case 'Manga':
        return Coloresapp.colorContorno;
      case 'Manhwa':
        return Coloresapp.colorMorado;
      case 'Donghua':
        return Coloresapp.colorNaranja;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconoTipo(String tipo) {
    switch (tipo) {
      case 'Noticias':
        return Icons.newspaper_rounded;
      case 'Debates':
        return Icons.psychology_rounded;
      case 'Recomendaciones':
        return Icons.recommend_rounded;
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fecha = foro['fecha'] as DateTime;
    final diff = DateTime.now().difference(fecha);
    String fechaString;
    if (diff.inDays > 0)
      fechaString = 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
    else if (diff.inHours > 0)
      fechaString = 'Hace ${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
    else
      fechaString =
          'Hace ${diff.inMinutes} minuto${diff.inMinutes > 1 ? 's' : ''}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _getColorCategoria(
                      foro['categoria'],
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIconoTipo(foro['tipo']),
                        size: 12,
                        color: _getColorCategoria(foro['categoria']),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        foro['categoria'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getColorCategoria(foro['categoria']),
                        ),
                      ),
                    ],
                  ),
                ),
                if (foro['destacado'] == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Coloresapp.colorPrimario.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_rounded,
                          size: 10,
                          color: Coloresapp.colorPrimario,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'Hot',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Coloresapp.colorPrimario,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              foro['titulo'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Coloresapp.colorCasiNegro,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              foro['contenido'].length > 120
                  ? '${foro['contenido'].substring(0, 120)}...'
                  : foro['contenido'],
              style: TextStyle(
                fontSize: 12,
                color: Coloresapp.colorTextoFlojo,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Coloresapp.colorPrimario.withOpacity(0.1),
                  child: Icon(
                    Icons.person_rounded,
                    size: 14,
                    color: Coloresapp.colorPrimario,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  foro['autor'],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Coloresapp.colorPrimario,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  fechaString,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.comment_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${foro['respuestas']}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.remove_red_eye_rounded,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${foro['vistas']}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------
// DIÁLOGO NUEVO FORO
// -------------------------------
class _DialogNuevoForo extends StatefulWidget {
  final Function(Map<String, dynamic>) onCreate;
  const _DialogNuevoForo({required this.onCreate});
  @override
  State<_DialogNuevoForo> createState() => _DialogNuevoForoState();
}

class _DialogNuevoForoState extends State<_DialogNuevoForo> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _contenidoCtrl = TextEditingController();
  String _categoria = 'Anime';
  String _tipo = 'Debates';
  final _categorias = ['Anime', 'Manga', 'Manhwa', 'Donghua'];
  final _tipos = ['Debates', 'Noticias', 'Recomendaciones'];

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _contenidoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear nuevo foro'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: _categorias
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _categoria = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: _tipos
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _tipo = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contenidoCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Ingresa el contenido' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onCreate({
                'titulo': _tituloCtrl.text,
                'categoria': _categoria,
                'tipo': _tipo,
                'contenido': _contenidoCtrl.text,
              });
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Coloresapp.colorPrimario,
          ),
          child: const Text('Crear'),
        ),
      ],
    );
  }
}

// -------------------------------
// BUSCADOR DE FOROS
// -------------------------------
class _DialogBuscadorForos extends StatefulWidget {
  final List<Map<String, dynamic>> foros;
  final Function(Map<String, dynamic>) onTap;
  const _DialogBuscadorForos({required this.foros, required this.onTap});
  @override
  State<_DialogBuscadorForos> createState() => _DialogBuscadorForosState();
}

class _DialogBuscadorForosState extends State<_DialogBuscadorForos> {
  String _busqueda = '';

  List<Map<String, dynamic>> get _filtrados {
    if (_busqueda.isEmpty) return [];
    return widget.foros
        .where(
          (f) =>
              f['titulo'].toLowerCase().contains(_busqueda.toLowerCase()) ||
              f['contenido'].toLowerCase().contains(_busqueda.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Buscar foros'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Escribe tu búsqueda...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _busqueda = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _busqueda.isEmpty
                  ? const Center(child: Text('Escribe algo para buscar'))
                  : _filtrados.isEmpty
                  ? const Center(child: Text('No se encontraron resultados'))
                  : ListView.builder(
                      itemCount: _filtrados.length,
                      itemBuilder: (_, i) => ListTile(
                        title: Text(
                          _filtrados[i]['titulo'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _filtrados[i]['contenido'].length > 50
                              ? '${_filtrados[i]['contenido'].substring(0, 50)}...'
                              : _filtrados[i]['contenido'],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          widget.onTap(_filtrados[i]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

// -------------------------------
// DETALLE DEL FORO (CON FAVORITOS)
// -------------------------------
class PaginaDetalleForo extends StatefulWidget {
  final Map<String, dynamic> foro;
  const PaginaDetalleForo({super.key, required this.foro});
  @override
  State<PaginaDetalleForo> createState() => _PaginaDetalleForoState();
}

class _PaginaDetalleForoState extends State<PaginaDetalleForo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _comentarioCtrl = TextEditingController();
  List<Map<String, dynamic>> _comentarios = [];
  bool _cargando = true;
  bool _esFavorito = false;
  bool _cargandoFav = true;

  @override
  void initState() {
    super.initState();
    _incrementarVistas();
    _cargarComentarios();
    _comprobarFavorito();
  }

  Future<void> _incrementarVistas() async {
    try {
      if (widget.foro.containsKey('id')) {
        final docRef = _firestore.collection('foros').doc(widget.foro['id']);
        await docRef.update({'vistas': FieldValue.increment(1)});
        await _registrarVisitaForo(widget.foro['id']);
      }
    } catch (e) {
      print('Error al incrementar vistas: $e');
    }
  }

  Future<void> _registrarVisitaForo(String foroId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore.collection('visitas_foros').add({
        'userId': user.uid,
        'foroId': foroId,
        'fecha': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al registrar visita: $e');
    }
  }

  Future<void> _cargarComentarios() async {
    try {
      final snap = await _firestore
          .collection('foros')
          .doc(widget.foro['id'])
          .collection('comentarios')
          .orderBy('fecha', descending: false)
          .get();
      setState(() {
        _comentarios = snap.docs
            .map(
              (d) => {
                'id': d.id,
                ...d.data(),
                'fecha': (d.data()['fecha'] as Timestamp).toDate(),
              },
            )
            .toList();
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  Future<void> _comprobarFavorito() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _cargandoFav = false);
      return;
    }
    final doc = await _firestore
        .collection('favoritos_foros')
        .doc('${user.uid}_${widget.foro['id']}')
        .get();
    setState(() {
      _esFavorito = doc.exists;
      _cargandoFav = false;
    });
  }

  Future<void> _toggleFavorito() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para guardar favoritos')),
      );
      return;
    }
    final docId = '${user.uid}_${widget.foro['id']}';
    final ref = _firestore.collection('favoritos_foros').doc(docId);
    if (_esFavorito) {
      await ref.delete();
      setState(() => _esFavorito = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foro eliminado de favoritos')),
      );
    } else {
      await ref.set({
        'userId': user.uid,
        'foroId': widget.foro['id'],
        'fecha': DateTime.now(),
      });
      setState(() => _esFavorito = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Foro añadido a favoritos')));
    }
  }

  Future<void> _agregarComentario() async {
    if (_comentarioCtrl.text.trim().isEmpty) return;
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para comentar')),
      );
      return;
    }
    try {
      await _firestore
          .collection('foros')
          .doc(widget.foro['id'])
          .collection('comentarios')
          .add({
            'autor': user.displayName ?? user.email?.split('@')[0] ?? 'Usuario',
            'autorId': user.uid,
            'contenido': _comentarioCtrl.text.trim(),
            'fecha': DateTime.now(),
          });
      await _firestore.collection('foros').doc(widget.foro['id']).update({
        'respuestas': FieldValue.increment(1),
      });
      _comentarioCtrl.clear();
      await _cargarComentarios();
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Comentario agregado')));
    } catch (e) {
      print('Error al agregar comentario: $e');
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fecha = widget.foro['fecha'] as DateTime;
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: Coloresapp.colorFondo,
      appBar: AppBar(
        backgroundColor: Coloresapp.colorPrimario,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.foro['titulo'],
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          if (!_cargandoFav)
            IconButton(
              icon: Icon(
                _esFavorito ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              onPressed: _toggleFavorito,
              tooltip: 'Favorito',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Coloresapp.colorPrimario
                                  .withOpacity(0.1),
                              child: Icon(
                                Icons.person_rounded,
                                size: 16,
                                color: Coloresapp.colorPrimario,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.foro['autor'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    formatter.format(fecha),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Coloresapp.colorPrimario.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.foro['categoria'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Coloresapp.colorPrimario,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.foro['titulo'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.foro['contenido'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Coloresapp.colorTexto,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.comment_rounded,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text('${widget.foro['respuestas']} respuestas'),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.remove_red_eye_rounded,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text('${widget.foro['vistas']} vistas'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Comentarios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_cargando)
                    const Center(child: CircularProgressIndicator())
                  else if (_comentarios.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text('No hay comentarios aún. ¡Sé el primero!'),
                        ],
                      ),
                    )
                  else
                    ..._comentarios.map((c) => _ComentarioCard(comentario: c)),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _comentarioCtrl,
                    decoration: InputDecoration(
                      hintText: 'Escribe un comentario...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Coloresapp.colorPrimario,
                  child: IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _agregarComentario,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComentarioCard extends StatelessWidget {
  final Map<String, dynamic> comentario;
  const _ComentarioCard({required this.comentario});

  @override
  Widget build(BuildContext context) {
    final fecha = comentario['fecha'] as DateTime;
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Coloresapp.colorPrimario.withOpacity(0.1),
                child: Icon(
                  Icons.person_rounded,
                  size: 14,
                  color: Coloresapp.colorPrimario,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                comentario['autor'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                formatter.format(fecha),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comentario['contenido'],
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
