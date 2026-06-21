import 'package:cloud_firestore/cloud_firestore.dart';

/// PATRÓN DE DISEÑO: Repository + Singleton.
/// Agrega estadísticas para el Dashboard de administración a partir de la
/// colección "reservas" de Cloud Firestore. Centraliza los cálculos para que
/// la pantalla solo consuma streams/valores ya procesados, sin conocer la
/// estructura de Firestore.
class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  final CollectionReference<Map<String, dynamic>> _reservas =
      FirebaseFirestore.instance.collection('reservas');

  /// Métricas agregadas en tiempo real (recalculadas en cada cambio de la
  /// colección "reservas"). Devuelve ingresos, total de reservas y el conteo
  /// por estado, todo en una sola pasada para evitar varias lecturas.
  Stream<DashboardMetrics> watchMetrics() {
    return _reservas.snapshots().map((snap) {
      var ingresos = 0.0;
      final porEstado = <String, int>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final estado = (data['estado'] ?? 'Desconocido') as String;
        porEstado[estado] = (porEstado[estado] ?? 0) + 1;
        // Solo cuentan como ingreso las reservas efectivamente pagadas.
        if (estado == 'Pagado' || estado == 'Disfrutado') {
          ingresos += (data['precioPorNoche'] as num?)?.toDouble() ?? 0;
        }
      }
      return DashboardMetrics(
        ingresos: ingresos,
        totalReservas: snap.docs.length,
        porEstado: porEstado,
      );
    });
  }
}

/// Resultado agregado del dashboard.
class DashboardMetrics {
  final double ingresos;
  final int totalReservas;
  final Map<String, int> porEstado;

  const DashboardMetrics({
    required this.ingresos,
    required this.totalReservas,
    required this.porEstado,
  });

  static const empty =
      DashboardMetrics(ingresos: 0, totalReservas: 0, porEstado: {});
}
