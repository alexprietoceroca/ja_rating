// tab_perfil.dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../coloresapp.dart';
import 'package:ja_rating/Components/Login/texto_normal.dart';
import 'package:ja_rating/Paginas/pagina_login.dart';

class TabPerfil extends StatefulWidget {
  const TabPerfil({super.key});

  @override
  State<TabPerfil> createState() => _TabPerfilState();
}

class _TabPerfilState extends State<TabPerfil>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Petala> _petalas = List.generate(
    30,
    (_) => _Petala(),
  ); // 30 pétalos

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _usuarioActual;
  String? _fotoPerfilUrl;
  String _nombreUsuario = '';
  bool _cargandoDatos = true;

  String _animesCalificados = '0';
  String _comentarios = '0';
  String _tierLists = '0';
  String _miembroDesde = '';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(); // Animación continua para todos los pétalos
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _cargarDatosUsuario() async {
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
          _fotoPerfilUrl = data?['fotoPerfilUrl'];
          if (_fotoPerfilUrl == '') _fotoPerfilUrl = null;
          _animesCalificados = (data?['animesCalificados'] ?? 0).toString();
          _comentarios = (data?['comentarios'] ?? 0).toString();
          _tierLists = (data?['tierLists'] ?? 0).toString();
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
            'fotoPerfilUrl': '',
            'fechaRegistro': DateTime.now().toIso8601String(),
            'animesCalificados': 0,
            'comentarios': 0,
            'tierLists': 0,
          });
        }
      }
    } catch (e) {
      print('Error al cargar datos: $e');
      _nombreUsuario = 'Usuario';
    } finally {
      if (mounted) setState(() => _cargandoDatos = false);
    }
  }

  String _formatearFecha(String? fechaIso) {
    if (fechaIso == null) return 'Miembro reciente';
    try {
      final fecha = DateTime.parse(fechaIso);
      return 'Miembro desde ${fecha.year}';
    } catch (e) {
      return 'Miembro reciente';
    }
  }

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
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.camera);
              },
            ),
            if (_fotoPerfilUrl != null && _fotoPerfilUrl!.isNotEmpty)
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

  Future<void> _seleccionarImagen(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (pickedFile != null) await _subirImagen(File(pickedFile.path));
  }

  Future<void> _subirImagen(File imagen) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No hay usuario autenticado');
      final ref = _storage.ref().child('perfiles/${user.uid}/foto_perfil.jpg');
      await ref.putFile(imagen);
      final url = await ref.getDownloadURL();
      await _firestore.collection('usuarios').doc(user.uid).update({
        'fotoPerfilUrl': url,
      });
      await user.updatePhotoURL(url);
      await user.reload();
      if (mounted) {
        setState(() {
          _fotoPerfilUrl = url;
          _usuarioActual = _auth.currentUser;
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
      print('Error al subir imagen: $e');
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
      try {
        await _storage
            .ref()
            .child('perfiles/${user.uid}/foto_perfil.jpg')
            .delete();
      } catch (e) {}
      await _firestore.collection('usuarios').doc(user.uid).update({
        'fotoPerfilUrl': '',
      });
      await user.updatePhotoURL(null);
      await user.reload();
      if (mounted) {
        setState(() {
          _fotoPerfilUrl = null;
          _usuarioActual = _auth.currentUser;
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
              if (nuevoNombre.isNotEmpty && nuevoNombre != _nombreUsuario)
                await _actualizarNombre(nuevoNombre);
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

  Future<void> _cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _auth.signOut();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

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
        // Fondo base
        Container(color: Coloresapp.colorFondo),
        // Pétalos animados (múltiples)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => CustomPaint(
            painter: _PetalaPainterMultiple(_petalas, _controller.value),
            size: Size.infinite,
          ),
        ),
        // Contenido principal
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Cabecera
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
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Coloresapp.colorPrimario,
                      backgroundImage:
                          (_fotoPerfilUrl != null && _fotoPerfilUrl!.isNotEmpty)
                          ? NetworkImage(_fotoPerfilUrl!)
                          : null,
                      child: (_fotoPerfilUrl == null || _fotoPerfilUrl!.isEmpty)
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
                // Nombre
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
                // Estadísticas
                Row(
                  children: [
                    _buildTarjetaEstadistica(_animesCalificados, 'Calificados'),
                    const SizedBox(width: 12),
                    _buildTarjetaEstadistica(_comentarios, 'Comentarios'),
                    const SizedBox(width: 12),
                    _buildTarjetaEstadistica(_tierLists, 'Tier Lists'),
                  ],
                ),
                const SizedBox(height: 40),
                // Menú
                _ItemMenuPerfil(
                  icono: Icons.star_rounded,
                  etiqueta: 'Mis calificaciones',
                  sub: '$_animesCalificados títulos calificados',
                ),
                _ItemMenuPerfil(
                  icono: Icons.chat_bubble_outline_rounded,
                  etiqueta: 'Mis comentarios',
                  sub: '$_comentarios comentarios',
                ),
                _ItemMenuPerfil(
                  icono: Icons.emoji_events_rounded,
                  etiqueta: 'Mis Tier Lists',
                  sub: '$_tierLists listas creadas',
                ),
                _ItemMenuPerfil(
                  icono: Icons.forum_rounded,
                  etiqueta: 'Foros visitados',
                  sub: 'Comunidad activa',
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
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

// Clase que representa un pétalo con sus propiedades
class _Petala {
  double x = Random().nextDouble(); // posición horizontal inicial (0-1)
  double y = Random().nextDouble(); // posición vertical inicial (0-1)
  double tamano = 0.5 + Random().nextDouble() * 0.8;
  double velocidadY = 0.2 + Random().nextDouble() * 0.3; // velocidad de caída
  double velocidadX = 0.03 + Random().nextDouble() * 0.07; // velocidad lateral
  double rotacion = Random().nextDouble() * 2 * pi;
  double velocidadRotacion = 0.2 + Random().nextDouble() * 0.5;
  double offsetOnda = Random().nextDouble() * 2 * pi;
  double amplitudOnda = 10 + Random().nextDouble() * 20;
}

// Painter que dibuja múltiples pétalos con forma alargada y puntiaguda
class _PetalaPainterMultiple extends CustomPainter {
  final List<_Petala> petalas;
  final double tiempo;
  _PetalaPainterMultiple(this.petalas, this.tiempo);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in petalas) {
      // Posición Y: caída continua (se reinicia al llegar al fondo)
      double y = (p.y + tiempo * p.velocidadY) % 1.0;
      // Posición X: movimiento lateral ondulante
      double x =
          p.x +
          sin(tiempo * p.velocidadX * 2 * pi + p.offsetOnda) *
              p.amplitudOnda /
              size.width;
      x = x % 1.0;
      // Rotación
      double rot = p.rotacion + tiempo * p.velocidadRotacion * 2 * pi;

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(rot);
      canvas.scale(p.tamano);

      // Forma de pétalo alargado y puntiagudo (más delgado que el anterior)
      final path = Path();
      path.moveTo(0, 0); // punta superior
      path.cubicTo(-6, 8, -10, 18, 0, 32); // lado izquierdo curvado
      path.cubicTo(10, 18, 6, 8, 0, 0); // lado derecho curvado
      path.close();

      final paint = Paint()
        ..color = Coloresapp.colorRosaClaro.withOpacity(0.85)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);

      // Vena central fina
      final paintLine = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      final pathVena = Path();
      pathVena.moveTo(0, 2);
      pathVena.cubicTo(0, 12, 0, 22, 0, 30);
      canvas.drawPath(pathVena, paintLine);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Widget auxiliar para items del menú (sin cambios)
class _ItemMenuPerfil extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String sub;
  const _ItemMenuPerfil({
    required this.icono,
    required this.etiqueta,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
