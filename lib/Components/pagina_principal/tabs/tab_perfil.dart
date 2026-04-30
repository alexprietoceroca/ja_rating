import 'dart:io';
// tab_perfil.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../coloresapp.dart';
import 'package:ja_rating/coloresapp.dart';
import 'package:ja_rating/Components/Login/texto_normal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ja_rating/Paginas/pagina_login.dart';

class TabPerfil extends StatefulWidget {
  const TabPerfil({super.key});

  @override
  State<TabPerfil> createState() => _TabPerfilState();
}

class _TabPerfilState extends State<TabPerfil> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  User? _usuarioActual;
  String? _fotoPerfilUrl;
  String _nombreUsuario = '';
  bool _cargandoDatos = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    setState(() {
      _cargandoDatos = true;
    });

    try {
      _usuarioActual = _auth.currentUser;
      
      if (_usuarioActual != null) {
        final docRef = _firestore.collection('usuarios').doc(_usuarioActual!.uid);
        final doc = await docRef.get();
        
        if (doc.exists) {
          final data = doc.data();
          _nombreUsuario = data?['nombreUsuario'] ?? 
                          _usuarioActual?.displayName ?? 
                          _usuarioActual?.email?.split('@')[0] ?? 
                          'Usuario';
          _fotoPerfilUrl = data?['fotoPerfilUrl'];
          if (_fotoPerfilUrl == '') {
            _fotoPerfilUrl = null;
          }
        } else {
          _nombreUsuario = _usuarioActual?.displayName ?? 
                          _usuarioActual?.email?.split('@')[0] ?? 
                          'Usuario';
          
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
      if (mounted) {
        setState(() {
          _cargandoDatos = false;
        });
      }
    }
  }

  // Mostrar opciones para cambiar foto
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

  // Seleccionar imagen
  Future<void> _seleccionarImagen(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    
    if (pickedFile != null) {
      await _subirImagen(File(pickedFile.path));
    }
  }

  // Subir imagen a Firebase
  Future<void> _subirImagen(File imagen) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Subir a Storage
      final ref = _storage.ref().child('perfiles/${user.uid}/foto_perfil.jpg');
      await ref.putFile(imagen);
      final url = await ref.getDownloadURL();
      
      // Guardar URL en Firestore
      await _firestore.collection('usuarios').doc(user.uid).update({
        'fotoPerfilUrl': url,
      });
      
      // Actualizar Auth
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
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Eliminar foto
  Future<void> _eliminarFoto() async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Eliminar de Storage
      try {
        final ref = _storage.ref().child('perfiles/${user.uid}/foto_perfil.jpg');
        await ref.delete();
      } catch (e) {
        print('No se pudo eliminar de Storage: $e');
      }
      
      // Actualizar Firestore
      await _firestore.collection('usuarios').doc(user.uid).update({
        'fotoPerfilUrl': '',
      });
      
      // Actualizar Auth
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
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Editar nombre de usuario
  void _editarNombre() {
    final TextEditingController controller = TextEditingController(text: _nombreUsuario);
    
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

  // Actualizar nombre
  Future<void> _actualizarNombre(String nuevoNombre) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Verificar si el nombre ya existe
      final querySnapshot = await _firestore
          .collection('usuarios')
          .where('nombreUsuario', isEqualTo: nuevoNombre)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.first.id != user.uid) {
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

      // Actualizar Firestore
      await _firestore.collection('usuarios').doc(user.uid).update({
        'nombreUsuario': nuevoNombre,
      });

      // Actualizar Auth
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
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Cerrar sesión
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
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  State<TabPerfil> createState() => _TabPerfilState();
}

class _TabPerfilState extends State<TabPerfil>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _posY;
  late Animation<double> _posX;
  late Animation<double> _rotacion;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: false);

    // Caída de arriba (0) a abajo (1)
    _posY = Tween<double>(
      begin: -0.1,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // Movimiento lateral ondulante
    _posX = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    // Rotación continua
    _rotacion = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
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
    super.build(context);
    final double anchoPantalla = MediaQuery.of(context).size.width;
    final double padding = anchoPantalla > 800 ? 40 : 20;

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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Avatar con botón de cámara
            Stack(
    return Stack(
      children: [
        // Fondo base
        Container(color: Coloresapp.colorFondo),
        // Pétalo animado
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              left: (_posX.value * MediaQuery.of(context).size.width) - 20,
              top: (_posY.value * MediaQuery.of(context).size.height) - 20,
              child: Transform.rotate(
                angle: _rotacion.value,
                child: CustomPaint(
                  painter: _PetalaPainter(),
                  size: const Size(40, 40),
                ),
              ),
            );
          },
        ),
        // Contenido original
        SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Coloresapp.colorPrimario,
                  backgroundImage: _fotoPerfilUrl != null && _fotoPerfilUrl!.isNotEmpty
                      ? NetworkImage(_fotoPerfilUrl!)
                      : null,
                  child: (_fotoPerfilUrl == null || _fotoPerfilUrl!.isEmpty)
                      ? const Icon(Icons.person_rounded, color: Colors.white, size: 60)
                      : null,
                // Cabecera (igual que antes)
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
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
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaginaLogin(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Coloresapp.colorPrimario,
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Akira_Fan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Coloresapp.colorCasiNegro,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Miembro desde 2023',
                          style: TextStyle(
                            fontSize: 13,
                            color: Coloresapp.colorTextoFlojo,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _EstadisticaPerfil(valor: '47', etiqueta: 'Calificados'),
                    const SizedBox(width: 12),
                    _EstadisticaPerfil(valor: '23', etiqueta: 'Comentarios'),
                    const SizedBox(width: 12),
                    _EstadisticaPerfil(valor: '5', etiqueta: 'Tier Lists'),
                  ],
                ),
                const SizedBox(height: 24),
                _ItemMenuPerfil(
                  icono: Icons.star_rounded,
                  etiqueta: 'Mis calificaciones',
                  sub: '47 títulos calificados',
                ),
                _ItemMenuPerfil(
                  icono: Icons.chat_bubble_outline_rounded,
                  etiqueta: 'Mis comentarios',
                  sub: '23 comentarios',
                ),
                _ItemMenuPerfil(
                  icono: Icons.emoji_events_rounded,
                  etiqueta: 'Mis Tier Lists',
                  sub: '5 listas creadas',
                ),
                _ItemMenuPerfil(
                  icono: Icons.forum_rounded,
                  etiqueta: 'Foros visitados',
                  sub: '12 hilos activos',
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Nombre de usuario
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
            
            // Email
            Text(
              _usuarioActual?.email ?? 'Sin email',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Estadísticas
            Row(
              children: [
                _buildTarjetaEstadistica('0', 'Calificados'),
                const SizedBox(width: 12),
                _buildTarjetaEstadistica('0', 'Comentarios'),
                const SizedBox(width: 12),
                _buildTarjetaEstadistica('0', 'Tier Lists'),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Botón de cerrar sesión
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
          ],
          ),
        ),
      ],
    );
  }

  Widget _buildTarjetaEstadistica(String valor, String etiqueta) {
// Painter que dibuja un pétalo de sakura
class _PetalaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Coloresapp.colorRosaClaro.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path();
    // Forma de pétalo (lágrima)
    path.moveTo(size.width / 2, 0);
    path.cubicTo(
      size.width * 0.7,
      size.height * 0.3,
      size.width,
      size.height * 0.7,
      size.width / 2,
      size.height,
    );
    path.cubicTo(
      0,
      size.height * 0.7,
      size.width * 0.3,
      size.height * 0.3,
      size.width / 2,
      0,
    );
    path.close();

    canvas.drawPath(path, paint);

    // Detalle central (vena)
    final paintLine = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final centerPath = Path();
    centerPath.moveTo(size.width / 2, 0);
    centerPath.cubicTo(
      size.width / 2,
      size.height * 0.4,
      size.width / 2,
      size.height * 0.7,
      size.width / 2,
      size.height,
    );
    canvas.drawPath(centerPath, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------
// Widgets auxiliares (EstadisticaPerfil, ItemMenuPerfil)
// ---------------------------------------------------------------------
class _EstadisticaPerfil extends StatelessWidget {
  final String valor;
  final String etiqueta;
  const _EstadisticaPerfil({required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
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
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
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
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
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
