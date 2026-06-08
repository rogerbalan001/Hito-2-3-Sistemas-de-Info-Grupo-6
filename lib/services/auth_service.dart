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

  /// Usuario autenticado actualmente (null si no hay sesión).
  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

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
