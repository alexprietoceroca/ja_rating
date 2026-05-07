// pagina_foro.dart - SIN foros predeterminados
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../coloresapp.dart';
import '../Components/Login/texto_normal.dart';
import '../Components/Login/texto_titulo.dart';

class PaginaForo extends StatefulWidget {
  const PaginaForo({super.key});

  @override
  State<PaginaForo> createState() => _PaginaForoState();
}

class _PaginaForoState extends State<PaginaForo> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _forosPopulares = [];
  List<Map<String, dynamic>> _forosRecientes = [];
  List<Map<String, dynamic>> _forosCategoria = [];
  bool _cargando = true;
  String _categoriaSeleccionada = 'Todo';

  final List<String> _categorias = [
    'Todo', 'Anime', 'Manga', 'Manhwa', 'Donghua', 'Noticias', 'Debates', 'Recomendaciones'
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
    setState(() {
      _cargando = true;
    });

    try {
      // Solo cargar foros desde Firebase, sin predeterminados
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
      
      // Foros populares (ordenados por respuestas y visitas)
      _forosPopulares = List.from(_forosRecientes);
      _forosPopulares.sort((a, b) {
        int scoreA = (a['respuestas'] as int) + ((a['vistas'] as int) ~/ 100);
        int scoreB = (b['respuestas'] as int) + ((b['vistas'] as int) ~/ 100);
        return scoreB.compareTo(scoreA);
      });
      
      if (_forosPopulares.length > 10) {
        _forosPopulares = _forosPopulares.sublist(0, 10);
      }
      
      _forosCategoria = List.from(_forosRecientes);
      
    } catch (e) {
      print('Error al cargar foros: $e');
      _forosRecientes = [];
      _forosPopulares = [];
      _forosCategoria = [];
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  void _filtrarPorCategoria() {
    if (_categoriaSeleccionada == 'Todo') {
      _forosCategoria = List.from(_forosRecientes);
    } else {
      _forosCategoria = _forosRecientes
          .where((foro) => foro['categoria'] == _categoriaSeleccionada)
          .toList();
    }
    setState(() {});
  }

  void _nuevoForo() {
    showDialog(
      context: context,
      builder: (context) => _DialogNuevoForo(
        onCreate: (foro) async {
          await _guardarForo(foro);
        },
      ),
    );
  }

  Future<void> _guardarForo(Map<String, dynamic> foro) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes iniciar sesión para crear un foro')),
        );
        return;
      }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
            onPressed: () => _mostrarBuscador(),
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
                _ListaForos(foros: _forosPopulares, onTap: (foro) => _abrirForo(foro)),
                _ListaForos(foros: _forosRecientes, onTap: (foro) => _abrirForo(foro)),
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
                            selectedColor: Coloresapp.colorPrimario.withOpacity(0.2),
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
                      child: _ListaForos(foros: _forosCategoria, onTap: (foro) => _abrirForo(foro)),
                    ),
                  ],
                ),
              ],
            ),
    );
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
      MaterialPageRoute(
        builder: (context) => PaginaDetalleForo(foro: foro),
      ),
    ).then((_) => _cargarForos());
  }
}

class _ListaForos extends StatelessWidget {
  final List<Map<String, dynamic>> foros;
  final Function(Map<String, dynamic>) onTap;

  const _ListaForos({required this.foros, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (foros.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay foros disponibles. ¡Crea el primero!'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: foros.length,
      itemBuilder: (context, index) {
        final foro = foros[index];
        return _CardForo(foro: foro, onTap: () => onTap(foro));
      },
    );
  }
}

class _CardForo extends StatelessWidget {
  final Map<String, dynamic> foro;
  final VoidCallback onTap;

  const _CardForo({required this.foro, required this.onTap});

  Color _getColorCategoria(String categoria) {
    switch (categoria) {
      case 'Anime': return Coloresapp.colorPrimario;
      case 'Manga': return Coloresapp.colorContorno;
      case 'Manhwa': return Coloresapp.colorMorado;
      case 'Donghua': return Coloresapp.colorNaranja;
      default: return Colors.grey;
    }
  }

  IconData _getIconoTipo(String tipo) {
    switch (tipo) {
      case 'Noticias': return Icons.newspaper_rounded;
      case 'Debates': return Icons.psychology_rounded;
      case 'Recomendaciones': return Icons.recommend_rounded;
      default: return Icons.chat_bubble_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fecha = foro['fecha'] as DateTime;
    final diferencia = DateTime.now().difference(fecha);
    String fechaString;
    
    if (diferencia.inDays > 0) {
      fechaString = 'Hace ${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
    } else if (diferencia.inHours > 0) {
      fechaString = 'Hace ${diferencia.inHours} hora${diferencia.inHours > 1 ? 's' : ''}';
    } else {
      fechaString = 'Hace ${diferencia.inMinutes} minuto${diferencia.inMinutes > 1 ? 's' : ''}';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getColorCategoria(foro['categoria']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getIconoTipo(foro['tipo']), size: 12, color: _getColorCategoria(foro['categoria'])),
                      const SizedBox(width: 4),
                      Text(foro['categoria'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getColorCategoria(foro['categoria']))),
                    ],
                  ),
                ),
                if (foro['destacado'] == true) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Coloresapp.colorPrimario.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department_rounded, size: 10, color: Coloresapp.colorPrimario),
                        SizedBox(width: 2),
                        Text('Hot', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Coloresapp.colorPrimario)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(foro['titulo'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Coloresapp.colorCasiNegro)),
            const SizedBox(height: 8),
            Text(
              foro['contenido'].length > 120 ? '${foro['contenido'].substring(0, 120)}...' : foro['contenido'],
              style: TextStyle(fontSize: 12, color: Coloresapp.colorTextoFlojo, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Coloresapp.colorPrimario.withOpacity(0.1),
                  child: Icon(Icons.person_rounded, size: 14, color: Coloresapp.colorPrimario),
                ),
                const SizedBox(width: 6),
                Text(foro['autor'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Coloresapp.colorPrimario)),
                const SizedBox(width: 12),
                Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(fechaString, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.comment_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${foro['respuestas']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(width: 12),
                    Icon(Icons.remove_red_eye_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${foro['vistas']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
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

class _DialogNuevoForo extends StatefulWidget {
  final Function(Map<String, dynamic>) onCreate;
  const _DialogNuevoForo({required this.onCreate});

  @override
  State<_DialogNuevoForo> createState() => _DialogNuevoForoState();
}

class _DialogNuevoForoState extends State<_DialogNuevoForo> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();
  String _categoria = 'Anime';
  String _tipo = 'Debates';

  final List<String> _categorias = ['Anime', 'Manga', 'Manhwa', 'Donghua'];
  final List<String> _tipos = ['Debates', 'Noticias', 'Recomendaciones'];

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
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
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
                validator: (value) => value?.isEmpty ?? true ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categoria,
                decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                items: _categorias.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) => setState(() => _categoria = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
                items: _tipos.map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))).toList(),
                onChanged: (value) => setState(() => _tipo = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contenidoController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Contenido', border: OutlineInputBorder(), alignLabelWithHint: true),
                validator: (value) => value?.isEmpty ?? true ? 'Ingresa el contenido' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onCreate({
                'titulo': _tituloController.text,
                'categoria': _categoria,
                'tipo': _tipo,
                'contenido': _contenidoController.text,
              });
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Coloresapp.colorPrimario),
          child: const Text('Crear'),
        ),
      ],
    );
  }
}

class _DialogBuscadorForos extends StatefulWidget {
  final List<Map<String, dynamic>> foros;
  final Function(Map<String, dynamic>) onTap;
  const _DialogBuscadorForos({required this.foros, required this.onTap});

  @override
  State<_DialogBuscadorForos> createState() => _DialogBuscadorForosState();
}

class _DialogBuscadorForosState extends State<_DialogBuscadorForos> {
  String _busqueda = '';
  
  List<Map<String, dynamic>> get _forosFiltrados {
    if (_busqueda.isEmpty) return [];
    return widget.foros.where((foro) {
      return foro['titulo'].toLowerCase().contains(_busqueda.toLowerCase()) ||
             foro['contenido'].toLowerCase().contains(_busqueda.toLowerCase());
    }).toList();
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
              onChanged: (value) => setState(() => _busqueda = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _busqueda.isEmpty
                  ? const Center(child: Text('Escribe algo para buscar'))
                  : _forosFiltrados.isEmpty
                      ? const Center(child: Text('No se encontraron resultados'))
                      : ListView.builder(
                          itemCount: _forosFiltrados.length,
                          itemBuilder: (context, index) {
                            final foro = _forosFiltrados[index];
                            return ListTile(
                              title: Text(foro['titulo'], maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(
                                foro['contenido'].length > 50 ? '${foro['contenido'].substring(0, 50)}...' : foro['contenido']
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                widget.onTap(foro);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
      ],
    );
  }
}

class PaginaDetalleForo extends StatefulWidget {
  final Map<String, dynamic> foro;
  const PaginaDetalleForo({super.key, required this.foro});

  @override
  State<PaginaDetalleForo> createState() => _PaginaDetalleForoState();
}

class _PaginaDetalleForoState extends State<PaginaDetalleForo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _comentarioController = TextEditingController();
  List<Map<String, dynamic>> _comentarios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _incrementarVistas();
    _cargarComentarios();
  }

  Future<void> _incrementarVistas() async {
    try {
      if (widget.foro.containsKey('id')) {
        final docRef = _firestore.collection('foros').doc(widget.foro['id']);
        await docRef.update({'vistas': FieldValue.increment(1)});
      }
    } catch (e) {
      print('Error al incrementar vistas: $e');
    }
  }

  Future<void> _cargarComentarios() async {
    try {
      final comentariosSnapshot = await _firestore
          .collection('foros')
          .doc(widget.foro['id'])
          .collection('comentarios')
          .orderBy('fecha', descending: false)
          .get();

      setState(() {
        _comentarios = comentariosSnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data(),
            'fecha': (doc.data()['fecha'] as Timestamp).toDate(),
          };
        }).toList();
        _cargando = false;
      });
    } catch (e) {
      print('Error al cargar comentarios: $e');
      setState(() => _cargando = false);
    }
  }

  Future<void> _agregarComentario() async {
    if (_comentarioController.text.trim().isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para comentar')),
      );
      return;
    }

    try {
      final nuevoComentario = {
        'autor': user.displayName ?? user.email?.split('@')[0] ?? 'Usuario',
        'autorId': user.uid,
        'contenido': _comentarioController.text.trim(),
        'fecha': DateTime.now(),
        'meGusta': 0,
      };

      await _firestore
          .collection('foros')
          .doc(widget.foro['id'])
          .collection('comentarios')
          .add(nuevoComentario);

      await _firestore.collection('foros').doc(widget.foro['id']).update({
        'respuestas': FieldValue.increment(1),
      });

      _comentarioController.clear();
      await _cargarComentarios();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comentario agregado')),
        );
      }
    } catch (e) {
      print('Error al agregar comentario: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
        title: Text(widget.foro['titulo'], style: const TextStyle(color: Colors.white, fontSize: 16)),
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Coloresapp.colorPrimario.withOpacity(0.1),
                              child: Icon(Icons.person_rounded, size: 16, color: Coloresapp.colorPrimario),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.foro['autor'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(formatter.format(fecha), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: Coloresapp.colorPrimario.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Text(widget.foro['categoria'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Coloresapp.colorPrimario)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(widget.foro['titulo'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(widget.foro['contenido'], style: TextStyle(fontSize: 14, color: Coloresapp.colorTexto, height: 1.5)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.comment_rounded, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${widget.foro['respuestas']} respuestas'),
                            const SizedBox(width: 16),
                            Icon(Icons.remove_red_eye_rounded, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${widget.foro['vistas']} vistas'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Comentarios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_cargando)
                    const Center(child: CircularProgressIndicator())
                  else if (_comentarios.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: const Column(
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No hay comentarios aún. ¡Sé el primero!'),
                        ],
                      ),
                    )
                  else
                    ..._comentarios.map((comentario) => _ComentarioCard(comentario: comentario)),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -2), blurRadius: 8)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _comentarioController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un comentario...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Coloresapp.colorPrimario,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Coloresapp.colorPrimario.withOpacity(0.1),
                child: Icon(Icons.person_rounded, size: 14, color: Coloresapp.colorPrimario),
              ),
              const SizedBox(width: 10),
              Text(comentario['autor'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 10),
              Text(formatter.format(fecha), style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(comentario['contenido'], style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}