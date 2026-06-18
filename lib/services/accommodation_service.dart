import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// PATRÓN DE DISEÑO: Repository + Singleton.
/// Maneja los alojamientos que los OPERADORES turísticos publican, guardados en
/// la colección "accommodations" de Cloud Firestore. Es distinto del
/// AccommodationRepository (catálogo mock en memoria que usa la búsqueda):
/// aquí viven las publicaciones reales creadas desde la app.
class AccommodationService {
  static final AccommodationService _instance =
      AccommodationService._internal();
  factory AccommodationService() => _instance;
  AccommodationService._internal();

  final CollectionReference<Map<String, dynamic>> _accommodations =
      FirebaseFirestore.instance.collection('accommodations');

  /// Registra un nuevo alojamiento publicado por el operador con sesión activa.
  /// (Cumple: "los operadores locales pueden registrar sus servicios,
  /// detallando costos y capacidad".)
  Future<void> agregarAlojamiento({
    required String nombre,
    required String destino,
    required String tipo,
    required double precioPorNoche,
    required int capacidad,
    String descripcion = '',
  }) async {
    final usuario = AuthService().currentUser;
    await _accommodations.add({
      'nombre': nombre,
      'destino': destino,
      'tipo': tipo,
      'precioPorNoche': precioPorNoche,
      'capacidad': capacidad,
      'descripcion': descripcion,
      'ownerId': usuario?.uid,
      'ownerEmail': usuario?.email,
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  /// Elimina un alojamiento por su id de documento. Pensado para uso del
  /// ADMINISTRADOR (la interfaz solo ofrece esta acción a cuentas admin).
  Future<void> eliminarAlojamiento(String id) async {
    await _accommodations.doc(id).delete();
  }

  /// Actualiza los campos editables de un alojamiento. Pensado para uso del
  /// ADMINISTRADOR desde la sección "Administración".
  Future<void> actualizarAlojamiento(
    String id, {
    required String nombre,
    required String destino,
    required String tipo,
    required double precioPorNoche,
    required int capacidad,
    String descripcion = '',
    bool available = true,
  }) async {
    await _accommodations.doc(id).update({
      'nombre': nombre,
      'destino': destino,
      'tipo': tipo,
      'precioPorNoche': precioPorNoche,
      'capacidad': capacidad,
      'descripcion': descripcion,
      'available': available,
    });
  }

  /// Alojamientos publicados por el operador actual, en tiempo real.
  Stream<QuerySnapshot<Map<String, dynamic>>> misAlojamientos() {
    final usuario = AuthService().currentUser;
    return _accommodations
        .where('ownerId', isEqualTo: usuario?.uid)
        .snapshots();
  }

  /// Todos los alojamientos publicados (para listarlos/mezclarlos a futuro).
  Stream<QuerySnapshot<Map<String, dynamic>>> todos() {
    return _accommodations.snapshots();
  }
}
