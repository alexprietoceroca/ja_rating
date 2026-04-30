import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../coloresapp.dart';

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
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
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
          ],
        ),
      ),
    );
  }
}