import '../models/accommodation.dart';

/// PATRÓN DE DISEÑO: Repository.
/// Abstrae el origen de los datos. Hoy devuelve datos simulados (mock) en
/// memoria; mañana se puede reemplazar la fuente por Firebase/Firestore SIN
/// tocar las pantallas, porque estas solo conocen el método [search].
class AccommodationRepository {
  // Singleton sencillo para reutilizar la misma instancia en toda la app.
  static final AccommodationRepository _instance =
      AccommodationRepository._internal();
  factory AccommodationRepository() => _instance;
  AccommodationRepository._internal();

  final List<Accommodation> _all = const [
    Accommodation(name: 'Posada Sol del Caribe', location: 'Isla Margarita', type: 'Posada', pricePerNight: 25),
    Accommodation(name: 'Camping Montaña Azul', location: 'Mérida', type: 'Camping', pricePerNight: 10),
    Accommodation(name: 'Hostal Centro Histórico', location: 'Coro', type: 'Hostal', pricePerNight: 18),
    Accommodation(name: 'Cabaña Los Andes', location: 'Mérida', type: 'Cabaña', pricePerNight: 45),
    Accommodation(name: 'Posada Playa Grande', location: 'Choroní', type: 'Posada', pricePerNight: 30),
    Accommodation(name: 'Camping Río Claro', location: 'Canaima', type: 'Camping', pricePerNight: 15),
    Accommodation(name: 'Hostal Backpackers', location: 'Caracas', type: 'Hostal', pricePerNight: 22),
    Accommodation(name: 'Eco-Lodge Gran Sabana', location: 'Santa Elena', type: 'Eco-Lodge', pricePerNight: 60),
  ];

  /// Devuelve únicamente los alojamientos que cumplen TODOS los filtros:
  /// el texto de destino (nombre o ubicación) y el presupuesto máximo.
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
