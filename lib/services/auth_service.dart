import 'package:firebase_auth/firebase_auth.dart';

/// PATRÓN DE DISEÑO: Singleton.
/// Existe UNA sola instancia de AuthService compartida por toda la app, de
/// modo que el estado de sesión es consistente entre pantallas.
///
/// La autenticación real se delega a Firebase Authentication. Firebase ya
/// mantiene internamente la sesión activa (usuario actual) entre reinicios.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// LISTA CABLEADA (hardcoded) DE ADMINISTRADORES.
  /// El acceso al modo administrador NO se puede activar desde la interfaz:
  /// solo las cuentas cuyo correo aparezca en esta lista, definida aquí en el
  /// backend, obtienen los privilegios de administrador automáticamente al
  /// iniciar sesión.
  ///
  /// Para autorizar a un administrador, agrega su correo institucional aquí
  /// (en minúsculas). Reemplaza el correo de ejemplo por los reales.
  static const List<String> adminEmails = <String>[
    'admin@unimet.edu.ve',
    // 'otro.admin@correo.unimet.edu.ve',
  ];

  /// Usuario autenticado actualmente (null si no hay sesión).
  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  /// Indica si el correo dado pertenece a un administrador autorizado.
  /// La comparación es insensible a mayúsculas/minúsculas y a espacios.
  bool isAdminEmail(String? email) {
    if (email == null) return false;
    return adminEmails.contains(email.trim().toLowerCase());
  }

  /// Indica si el usuario con sesión activa es administrador (según la lista
  /// cableada en el backend). Es la ÚNICA fuente de verdad para el modo admin.
  bool get isCurrentUserAdmin => isAdminEmail(currentUser?.email);

  /// Registra un nuevo usuario en Firebase.
  /// Devuelve `null` si todo salió bien, o un mensaje de error en español.
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'El correo ya está registrado';
        case 'weak-password':
          return 'La contraseña es muy débil';
        case 'invalid-email':
          return 'El correo no es válido';
        default:
          return 'Error al registrar: ${e.message}';
      }
    }
  }

  /// Inicia sesión validando las credenciales contra Firebase.
  /// Devuelve `null` si todo salió bien, o un mensaje de error en español.
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'Correo o contraseña incorrectos';
        case 'invalid-email':
          return 'El correo no es válido';
        default:
          return 'Error al iniciar sesión: ${e.message}';
      }
    }
  }

  Future<void> logout() => _auth.signOut();
}
