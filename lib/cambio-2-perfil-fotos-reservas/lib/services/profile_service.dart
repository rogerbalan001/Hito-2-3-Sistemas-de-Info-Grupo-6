import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// PATRÓN DE DISEÑO: Repository + Singleton.
/// Centraliza el acceso al perfil del usuario en la colección "usuarios" de
/// Cloud Firestore. Firebase Auth solo guarda email y displayName, así que los
/// datos adicionales (teléfono, rol) se guardan aquí, con el uid como id del
/// documento. (Soporta el módulo "Perfil de Usuario" del Hito 2.)
class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final CollectionReference<Map<String, dynamic>> _usuarios =
      FirebaseFirestore.instance.collection('usuarios');

  /// Lee el perfil del usuario con sesión iniciada. Devuelve `null` si no hay
  /// sesión o si aún no ha guardado datos.
  Future<Map<String, dynamic>?> obtenerPerfil() async {
    final usuario = AuthService().currentUser;
    if (usuario == null) return null;
    final doc = await _usuarios.doc(usuario.uid).get();
    return doc.data();
  }

  /// Crea o actualiza el perfil. Usa merge para no borrar campos previos y
  /// también sincroniza el nombre con Firebase Auth (displayName).
  ///
  /// Además de los datos básicos (nombre, teléfono, rol), guarda datos
  /// extendidos del perfil: foto, dirección, género, ocupación, fecha de
  /// nacimiento y una biografía corta. Todos son opcionales: si se omiten
  /// (quedan `null`), no se sobreescribe lo que ya había guardado.
  Future<void> guardarPerfil({
    required String nombre,
    required String telefono,
    required String rol,
    String? fotoUrl,
    String? direccion,
    String? genero,
    String? ocupacion,
    String? fechaNacimiento,
    String? biografia,
  }) async {
    final usuario = AuthService().currentUser;
    if (usuario == null) return;

    await _usuarios.doc(usuario.uid).set({
      'nombre': nombre,
      'telefono': telefono,
      'rol': rol, // 'Viajero' u 'Operador turístico'
      'email': usuario.email,
      if (fotoUrl != null) 'fotoUrl': fotoUrl,
      if (direccion != null) 'direccion': direccion,
      if (genero != null) 'genero': genero,
      if (ocupacion != null) 'ocupacion': ocupacion,
      if (fechaNacimiento != null) 'fechaNacimiento': fechaNacimiento,
      if (biografia != null) 'biografia': biografia,
      'actualizado': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Sincroniza el nombre visible de la cuenta y, si hay foto nueva, la
    // foto de perfil de Firebase Auth (se ve también en el avatar del menú).
    await usuario.updateDisplayName(nombre);
    if (fotoUrl != null) {
      await usuario.updatePhotoURL(fotoUrl);
    }
  }
}
