import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/// PATRÓN DE DISEÑO: Repository + Singleton.
/// Centraliza el acceso a la colección "reservas" en Cloud Firestore.
/// Las pantallas solo conocen [crearReserva] y [misReservas], sin saber que
/// detrás hay Firestore (igual que AccommodationRepository abstrae los datos).
class ReservationService {
  static final ReservationService _instance = ReservationService._internal();
  factory ReservationService() => _instance;
  ReservationService._internal();

  /// Referencia a la colección. Firestore la crea sola al guardar el primer
  /// documento; no hay que crearla manualmente en la consola.
  final CollectionReference<Map<String, dynamic>> _reservas =
      FirebaseFirestore.instance.collection('reservas');

  /// Crea una nueva reserva en estado inicial "Solicitado", asociada al
  /// usuario que tiene la sesión iniciada. (Cumple RF04: flujo de reservas.)
  Future<void> crearReserva({
    required String alojamiento,
    required String ubicacion,
    required double precioPorNoche,
  }) async {
    final usuario = AuthService().currentUser;
    await _reservas.add({
      'usuarioId': usuario?.uid,
      'usuarioEmail': usuario?.email,
      'alojamiento': alojamiento,
      'ubicacion': ubicacion,
      'precioPorNoche': precioPorNoche,
      // Ciclo de vida: Solicitado -> Aprobado -> Pagado -> Disfrutado.
      'estado': 'Solicitado',
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  /// Reservas del usuario actual, en tiempo real (para listarlas en pantalla).
  Stream<QuerySnapshot<Map<String, dynamic>>> misReservas() {
    final usuario = AuthService().currentUser;
    return _reservas.where('usuarioId', isEqualTo: usuario?.uid).snapshots();
  }

  /// Obtiene todas las reservas (para la vista de Administrador).
  /// Permite listar las solicitudes activas de los clientes.
  Stream<QuerySnapshot<Map<String, dynamic>>> todasLasReservas() {
    return _reservas.orderBy('fecha', descending: true).snapshots();
  }

  /// Actualiza el estado de una reserva (por ejemplo: Aprobado, Disfrutado).
  Future<void> actualizarEstado(String id, String nuevoEstado) async {
    await _reservas.doc(id).update({
      'estado': nuevoEstado,
    });
  }
}
