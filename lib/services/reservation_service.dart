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
  /// Flujo: la reserva nace en estado "Solicitado". El administrador la revisa
  /// y la pasa a "Aprobado"; solo entonces el viajero puede pagarla (PayPal
  /// Sandbox) desde "Mis Reservas", lo que la deja en "Pagado".
  Future<void> crearReserva({
    required String alojamiento,
    required String ubicacion,
    required double precioPorNoche,
    String estado = 'Solicitado',
    String? metodoPago,
    String? referenciaPago,
    int? cantidadPersonas,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final usuario = AuthService().currentUser;
    await _reservas.add({
      'usuarioId': usuario?.uid,
      'usuarioEmail': usuario?.email,
      'alojamiento': alojamiento,
      'ubicacion': ubicacion,
      'precioPorNoche': precioPorNoche,
      // Ciclo de vida: Solicitado -> Aprobado -> Pagado -> Disfrutado
      // (o Cancelado).
      'estado': estado,
      'metodoPago': metodoPago,
      'referenciaPago': referenciaPago,
      // Cuántas personas viajan, elegido por el viajero al reservar.
      if (cantidadPersonas != null) 'cantidadPersonas': cantidadPersonas,
      // Fechas de la estadía elegidas por el viajero al reservar. Se usan para
      // promover la reserva a "Disfrutado" cuando termina la estancia.
      if (fechaInicio != null) 'fechaInicio': Timestamp.fromDate(fechaInicio),
      if (fechaFin != null) 'fechaFin': Timestamp.fromDate(fechaFin),
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  /// Marca como "Pagado" una reserva YA existente (la que el admin aprobó),
  /// guardando los datos del pago. Se llama desde PaymentPage cuando PayPal
  /// confirma la captura.
  Future<void> registrarPago(
    String id, {
    String? metodoPago,
    String? referenciaPago,
  }) async {
    await _reservas.doc(id).update({
      'estado': 'Pagado',
      'metodoPago': metodoPago,
      'referenciaPago': referenciaPago,
      'fechaPago': FieldValue.serverTimestamp(),
    });
  }

  /// Reservas del usuario actual, en tiempo real (para listarlas en pantalla).
  Stream<QuerySnapshot<Map<String, dynamic>>> misReservas() {
    final usuario = AuthService().currentUser;
    return _reservas.where('usuarioId', isEqualTo: usuario?.uid).snapshots();
  }

  /// Devuelve los nombres de alojamientos donde el usuario actual tiene una
  /// reserva en estado "Disfrutado" o "Pagado". Se usa para validar que solo
  /// pueda reseñar lugares donde realmente se ha alojado.
  Future<Set<String>> alojamientosVisitados() async {
    final usuario = AuthService().currentUser;
    if (usuario == null) return {};
    final snap = await _reservas
        .where('usuarioId', isEqualTo: usuario.uid)
        .where('estado', whereIn: ['Disfrutado', 'Pagado']).get();
    return snap.docs
        .map((d) => (d.data()['alojamiento'] as String?) ?? '')
        .where((n) => n.isNotEmpty)
        .toSet();
  }

  /// Verifica si un alojamiento (por nombre) tiene reservas activas
  /// (Solicitado, Aprobado o Pagado). Usado por el administrador para evitar
  /// eliminar un alojamiento con reservas en curso.
  Future<bool> tieneReservasActivas(String nombreAlojamiento) async {
    final snap = await _reservas
        .where('alojamiento', isEqualTo: nombreAlojamiento)
        .where('estado', whereIn: ['Solicitado', 'Aprobado', 'Pagado']).get();
    return snap.docs.isNotEmpty;
  }

  /// Devuelve todas las reservas de un alojamiento específico (por nombre).
  /// Usada en la pantalla de detalle para mostrar reseñas asociadas al lugar.
  Stream<QuerySnapshot<Map<String, dynamic>>> reservasDelAlojamiento(
      String nombreAlojamiento) {
    return _reservas
        .where('alojamiento', isEqualTo: nombreAlojamiento)
        .snapshots();
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

  /// Control de fechas: promueve automáticamente a "Disfrutado" las reservas
  /// "Pagado" cuya fecha de fin de estadía ya pasó. Así el ciclo avanza solo,
  /// sin que el administrador tenga que marcarlas a mano.
  ///
  /// Solo filtra por un campo (`estado`) en el servidor para no requerir un
  /// índice compuesto en Firestore; la comparación de la fecha se hace en el
  /// cliente.
  Future<void> promoverReservasVencidas() async {
    final ahora = DateTime.now();
    final pagadas =
        await _reservas.where('estado', isEqualTo: 'Pagado').get();
    for (final doc in pagadas.docs) {
      final fechaFin = doc.data()['fechaFin'];
      if (fechaFin is Timestamp && !fechaFin.toDate().isAfter(ahora)) {
        await doc.reference.update({'estado': 'Disfrutado'});
      }
    }
  }
}
