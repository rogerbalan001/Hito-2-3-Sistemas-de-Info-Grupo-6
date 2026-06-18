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

  /// Crea una nueva reserva, asociada al usuario que tiene la sesión iniciada.
  /// (Cumple RF04: flujo de reservas.)
  ///
  /// Desde la integración de pagos, ya no hay un paso de aprobación manual:
  /// el pago se confirma en PaymentPage (PayPal Sandbox) y SOLO si se aprueba
  /// se llama a este método, ya con `estado: 'Pagado'`. El valor por defecto
  /// 'Solicitado' se conserva por compatibilidad, pero hoy ningún punto de la
  /// app lo usa sin pasar explícitamente el estado.
  Future<void> crearReserva({
    required String alojamiento,
    required String ubicacion,
    required double precioPorNoche,
    String estado = 'Solicitado',
    String? metodoPago,
    String? referenciaPago,
  }) async {
    final usuario = AuthService().currentUser;
    await _reservas.add({
      'usuarioId': usuario?.uid,
      'usuarioEmail': usuario?.email,
      'alojamiento': alojamiento,
      'ubicacion': ubicacion,
      'precioPorNoche': precioPorNoche,
      // Ciclo de vida actual: Pagado -> Disfrutado (o Cancelado).
      'estado': estado,
      'metodoPago': metodoPago,
      'referenciaPago': referenciaPago,
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
