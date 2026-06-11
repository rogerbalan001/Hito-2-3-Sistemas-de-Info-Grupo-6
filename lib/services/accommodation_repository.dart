import '../data/mock_data.dart';
import '../models/accommodation.dart';

/// PATRÓN DE DISEÑO: Repository.
/// Abstrae el origen de los datos. Hoy devuelve el catálogo simulado del
/// diseño (MockData); mañana se puede reemplazar por Firebase/Firestore SIN
/// tocar las pantallas, porque estas solo conocen [all] y [search].
class AccommodationRepository {
  static final AccommodationRepository _instance =
      AccommodationRepository._internal();
  factory AccommodationRepository() => _instance;
  AccommodationRepository._internal();

  List<Accommodation> get _all => MockData.accommodations;

  /// Catálogo completo (para secciones destacadas).
  List<Accommodation> all() => List.unmodifiable(_all);

  /// Devuelve los alojamientos que cumplen el texto de destino (nombre o
  /// ubicación) y el presupuesto máximo.
  List<Accommodation> search({
    String query = '',
    double maxBudget = double.infinity,
  }) {
    final q = query.trim().toLowerCase();
    return _all.where((a) {
      final matchesQuery = q.isEmpty ||
          a.name.toLowerCase().contains(q) ||
          a.location.toLowerCase().contains(q);
      final matchesBudget = a.pricePerNight <= maxBudget;
      return matchesQuery && matchesBudget;
    }).toList();
  }
}
