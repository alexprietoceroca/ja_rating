// lib/Components/pagina_principal/tabs/tab_perfil.dart
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/Login/texto_normal.dart';
import 'package:ja_rating/Paginas/pagina_login.dart';
import 'package:ja_rating/Paginas/pagina_perfil_ratings.dart';
import 'package:ja_rating/Components/pagina_perfil/mis_tierlists_page.dart';
import 'package:ja_rating/Components/pagina_perfil/mis_comentarios_page.dart';
import 'package:ja_rating/Components/pagina_perfil/foros_visitados_page.dart';

class TabPerfil extends StatefulWidget {
  const TabPerfil({super.key});

  @override
  State<TabPerfil> createState() => _TabPerfilState();
}

class _TabPerfilState extends State<TabPerfil>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Petala> _petalas = List.generate(30, (_) => _Petala());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _usuarioActual;
  String? _fotoPerfilBase64;
  String _nombreUsuario = '';
  bool _cargandoDatos = true;
  String _miembroDesde = '';

  int _totalRatings = 0;
  int _totalComentarios = 0;
  int _totalTierLists = 0;
  int _totalFavoritos = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatosBasicosUsuario();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  // --------------------------------------------------------------------------
  // CARGA INICIAL
  // --------------------------------------------------------------------------
  Future<void> _cargarDatosBasicosUsuario() async {
    setState(() => _cargandoDatos = true);
    try {
      _usuarioActual = _auth.currentUser;
      if (_usuarioActual != null) {
        final docRef = _firestore
            .collection('usuarios')
            .doc(_usuarioActual!.uid);
        final doc = await docRef.get();

        if (doc.exists) {
          final data = doc.data();
          _nombreUsuario =
              data?['nombreUsuario'] ??
              _usuarioActual?.displayName ??
              _usuarioActual?.email?.split('@')[0] ??
              'Usuario';
          _fotoPerfilBase64 = data?['fotoPerfilBase64'];
          if (_fotoPerfilBase64 == '') _fotoPerfilBase64 = null;
          _miembroDesde = _formatearFecha(data?['fechaRegistro']);
        } else {
          _nombreUsuario =
              _usuarioActual?.displayName ??
              _usuarioActual?.email?.split('@')[0] ??
              'Usuario';
          _miembroDesde = _formatearFecha(DateTime.now().toIso8601String());
          await docRef.set({
            'uid': _usuarioActual!.uid,
            'email': _usuarioActual!.email,
            'nombreUsuario': _nombreUsuario,
            'fotoPerfilBase64': '',
            'fechaRegistro': DateTime.now().toIso8601String(),
            'animesCalificados': 0,
            'comentarios': 0,
            'tierLists': 0,
          });
        }

        await _cargarEstadisticas();
        await _corregirContadorTierLists();
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      _nombreUsuario = 'Usuario';
    } finally {
      if (mounted) setState(() => _cargandoDatos = false);
    }
  }

  Future<void> _cargarEstadisticas() async {
    final uid = _usuarioActual!.uid;
    final ratings = await _firestore
        .collection('ratings')
        .where('userId', isEqualTo: uid)
        .get();
    _totalRatings = ratings.docs.length;

    final comentarios = await _firestore
        .collectionGroup('comentarios')
        .where('autorId', isEqualTo: uid)
        .get();
    _totalComentarios = comentarios.docs.length;

    final tierlists = await _firestore
        .collection('tierlists_comunidad')
        .where('ownerId', isEqualTo: uid)
        .get();
    _totalTierLists = tierlists.docs.length;

    final favoritos = await _firestore
        .collection('favoritos_foros')
        .where('userId', isEqualTo: uid)
        .get();
    _totalFavoritos = favoritos.docs.length;

    setState(() {});
  }

  Future<void> _corregirContadorTierLists() async {
    final user = _usuarioActual;
    if (user == null) return;

    final querySnapshot = await _firestore
        .collection('tierlists_comunidad')
        .where('ownerId', isEqualTo: user.uid)
        .get();

    final int count = querySnapshot.docs.length;
    await _firestore.collection('usuarios').doc(user.uid).update({
      'tierLists': count,
    });
    print('Contador corregido a $count');
  }

  String _formatearFecha(String? fechaIso) {
    if (fechaIso == null || fechaIso.isEmpty) return 'Miembro reciente';
    try {
      final fecha = DateTime.parse(fechaIso);
      return 'Miembro desde ${fecha.year}';
    } catch (e) {
      return 'Miembro reciente';
    }
  }

  // --------------------------------------------------------------------------
  // FOTO DE PERFIL (BASE64 EN FIRESTORE)
  // --------------------------------------------------------------------------
  void _mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Subir foto'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen();
              },
            ),
            if (_fotoPerfilBase64 != null && _fotoPerfilBase64!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto'),
                onTap: () async {
                  Navigator.pop(context);
                  await _eliminarFoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarImagen() async {
    print('Seleccionando imagen...');
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        print('Imagen seleccionada: ${pickedFile.path}');
        final bytes = await pickedFile.readAsBytes();
        final base64String = base64Encode(bytes);
        print('Base64 generado, longitud: ${base64String.length}');
        await _guardarFotoBase64(base64String);
      } else {
        print('No se seleccionó ninguna imagen');
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _guardarFotoBase64(String base64String) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      await _firestore.collection('usuarios').doc(user.uid).update({
        'fotoPerfilBase64': base64String,
      });

      if (mounted) {
        setState(() {
          _fotoPerfilBase64 = base64String;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil actualizada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error al guardar foto: $e');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _eliminarFoto() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      await _firestore.collection('usuarios').doc(user.uid).update({
        'fotoPerfilBase64': '',
      });

      if (mounted) {
        setState(() {
          _fotoPerfilBase64 = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil eliminada'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error al eliminar foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --------------------------------------------------------------------------
  // EDITAR NOMBRE
  // --------------------------------------------------------------------------
  void _editarNombre() {
    final TextEditingController controller = TextEditingController(
      text: _nombreUsuario,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nombre de usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Nuevo nombre de usuario',
                border: OutlineInputBorder(),
              ),
              maxLength: 20,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nuevoNombre = controller.text.trim();
              if (nuevoNombre.isNotEmpty && nuevoNombre != _nombreUsuario) {
                await _actualizarNombre(nuevoNombre);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Coloresapp.colorPrimario,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _actualizarNombre(String nuevoNombre) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');

      final querySnapshot = await _firestore
          .collection('usuarios')
          .where('nombreUsuario', isEqualTo: nuevoNombre)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty &&
          querySnapshot.docs.first.id != user.uid) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este nombre de usuario ya está en uso'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      await _firestore.collection('usuarios').doc(user.uid).update({
        'nombreUsuario': nuevoNombre,
      });
      await user.updateDisplayName(nuevoNombre);
      await user.reload();

      if (mounted) {
        setState(() {
          _nombreUsuario = nuevoNombre;
          _usuarioActual = _auth.currentUser;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nombre actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error al actualizar nombre: $e');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --------------------------------------------------------------------------
  // CERRAR SESIÓN
  // --------------------------------------------------------------------------
  Future<void> _cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesion'),
        content: const Text('¿Estas seguro de que quieres cerrar sesion?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesion'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PaginaLogin()),
        );
      }
    }
  }

  // --------------------------------------------------------------------------
  // BUILD
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_cargandoDatos) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando perfil...'),
          ],
        ),
      );
    }

    if (_usuarioActual == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay usuario logueado'),
          ],
        ),
      );
    }

    final double anchoPantalla = MediaQuery.of(context).size.width;
    final double padding = anchoPantalla > 800 ? 40 : 20;

    return Stack(
      children: [
        Container(color: Coloresapp.colorFondo),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => CustomPaint(
            painter: _PetalaPainterMultiple(_petalas, _controller.value),
            size: Size.infinite,
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/imagenes/logo.png',
                        width: 40,
                        height: 40,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image,
                          color: Coloresapp.colorTexto,
                        ),
                      ),
                      const Spacer(),
                      TextoNormal(
                        contingutText: 'Mi Perfil',
                        colorText: Coloresapp.colorTexto,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Coloresapp.colorTexto,
                        ),
                        onPressed: _cerrarSesion,
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      key: ValueKey(_fotoPerfilBase64),
                      radius: 60,
                      backgroundColor: Coloresapp.colorPrimario,
                      backgroundImage:
                          (_fotoPerfilBase64 != null &&
                              _fotoPerfilBase64!.isNotEmpty)
                          ? MemoryImage(base64Decode(_fotoPerfilBase64!))
                          : null,
                      child:
                          (_fotoPerfilBase64 == null ||
                              _fotoPerfilBase64!.isEmpty)
                          ? const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 60,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _mostrarOpcionesFoto,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Coloresapp.colorPrimario,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _nombreUsuario,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _editarNombre,
                      icon: const Icon(Icons.edit, size: 20),
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _usuarioActual?.email ?? 'Sin email',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  _miembroDesde,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Coloresapp.colorTextoFlojo,
                  ),
                ),
                const SizedBox(height: 30),

                // Tarjetas estadísticas
                Row(
                  children: [
                    _buildTarjetaEstadistica(
                      _totalRatings.toString(),
                      'Calificados',
                    ),
                    const SizedBox(width: 12),
                    _buildTarjetaEstadistica(
                      _totalComentarios.toString(),
                      'Comentarios',
                    ),
                    const SizedBox(width: 12),
                    _buildTarjetaEstadistica(
                      _totalTierLists.toString(),
                      'Tier Lists',
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Menú de opciones
                _ItemMenuPerfil(
                  icono: Icons.star_rounded,
                  etiqueta: 'Mis calificaciones',
                  sub: '$_totalRatings títulos calificados',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PaginaPerfilRatings(initialTab: 0),
                      ),
                    );
                  },
                ),
                _ItemMenuPerfil(
                  icono: Icons.chat_bubble_outline_rounded,
                  etiqueta: 'Mis comentarios',
                  sub: '$_totalComentarios comentarios',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MisComentariosPage(),
                      ),
                    );
                  },
                ),
                _ItemMenuPerfil(
                  icono: Icons.emoji_events_rounded,
                  etiqueta: 'Mis Tier Lists',
                  sub: '$_totalTierLists listas creadas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MisTierlistsPage(),
                      ),
                    );
                  },
                ),
                _ItemMenuPerfil(
                  icono: Icons.favorite_rounded,
                  etiqueta: 'Foros favoritos',
                  sub: '$_totalFavoritos foros guardados',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PaginaPerfilRatings(initialTab: 3),
                      ),
                    );
                  },
                ),
                _ItemMenuPerfil(
                  icono: Icons.forum_rounded,
                  etiqueta: 'Foros visitados',
                  sub: 'Historial de foros',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForosVisitadosPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Botón cerrar sesión
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTarjetaEstadistica(String valor, String etiqueta) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Coloresapp.colorPrimario,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 11,
                color: Coloresapp.colorTextoFlojo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== CLASES AUXILIARES ==========
class _Petala {
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double tamano = 0.5 + Random().nextDouble() * 0.8;
  double velocidadY = 0.2 + Random().nextDouble() * 0.3;
  double velocidadX = 0.03 + Random().nextDouble() * 0.07;
  double rotacion = Random().nextDouble() * 2 * pi;
  double velocidadRotacion = 0.2 + Random().nextDouble() * 0.5;
  double offsetOnda = Random().nextDouble() * 2 * pi;
  double amplitudOnda = 10 + Random().nextDouble() * 20;
}

class _PetalaPainterMultiple extends CustomPainter {
  final List<_Petala> petalas;
  final double tiempo;
  _PetalaPainterMultiple(this.petalas, this.tiempo);
  @override
  void paint(Canvas canvas, Size size) {
    for (var p in petalas) {
      double y = (p.y + tiempo * p.velocidadY) % 1.0;
      double x =
          p.x +
          sin(tiempo * p.velocidadX * 2 * pi + p.offsetOnda) *
              p.amplitudOnda /
              size.width;
      x = x % 1.0;
      double rot = p.rotacion + tiempo * p.velocidadRotacion * 2 * pi;

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(rot);
      canvas.scale(p.tamano);

      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(-6, 8, -10, 18, 0, 32)
        ..cubicTo(10, 18, 6, 8, 0, 0);
      final paint = Paint()
        ..color = Coloresapp.colorRosaClaro.withOpacity(0.85)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);

      final paintLine = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      final pathVena = Path()
        ..moveTo(0, 2)
        ..cubicTo(0, 12, 0, 22, 0, 30);
      canvas.drawPath(pathVena, paintLine);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ItemMenuPerfil extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String sub;
  final VoidCallback onTap;

  const _ItemMenuPerfil({
    required this.icono,
    required this.etiqueta,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Coloresapp.colorBlanco,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Icon(icono, color: Coloresapp.colorPrimario, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etiqueta,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Coloresapp.colorCasiNegro,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Coloresapp.colorTextoFlojo,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Coloresapp.colorTextoFlojo,
            ),
          ],
        ),
      ),
    );
  }
}
