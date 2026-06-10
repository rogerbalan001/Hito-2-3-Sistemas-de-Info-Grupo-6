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

  // Fotos (Unsplash) reutilizadas del diseño en Figma, por tipo de paisaje.
  static const _beach =
      'https://images.unsplash.com/photo-1611946022552-d2ca5ffba186?auto=format&fit=crop&w=1080&q=80';
  static const _mountain =
      'https://images.unsplash.com/photo-1695664488281-d7166250482d?auto=format&fit=crop&w=1080&q=80';
  static const _colonial =
      'https://images.unsplash.com/photo-1762995350095-4d8479227c77?auto=format&fit=crop&w=1080&q=80';
  static const _hostel =
      'https://images.unsplash.com/photo-1768289269971-6171457bed13?auto=format&fit=crop&w=1080&q=80';
  static const _ecolodge =
      'https://images.unsplash.com/photo-1650201776749-fde3862e5354?auto=format&fit=crop&w=1080&q=80';
  static const _desert =
      'https://images.unsplash.com/photo-1725509408295-17d8def5b14e?auto=format&fit=crop&w=1080&q=80';

  final List<Accommodation> _all = const [
    Accommodation(
      name: 'Posada Sol del Caribe',
      location: 'Isla Margarita',
      type: 'Posada',
      pricePerNight: 25,
      rating: 4.6,
      reviewCount: 128,
      imageUrl: _beach,
      capacity: 4,
      description:
          'Posada frente al mar con desayuno incluido y acceso directo a la '
          'playa. Ideal para descansar sin gastar de más.',
      amenities: ['WiFi', 'Desayuno', 'Aire acondicionado', 'Playa'],
    ),
    Accommodation(
      name: 'Camping Montaña Azul',
      location: 'Mérida',
      type: 'Camping',
      pricePerNight: 10,
      rating: 4.3,
      reviewCount: 64,
      imageUrl: _mountain,
      capacity: 6,
      description:
          'Zona de acampada en plena montaña andina, con fogatas permitidas y '
          'senderos guiados al amanecer.',
      amenities: ['Fogata', 'Senderismo', 'Baños compartidos'],
    ),
    Accommodation(
      name: 'Hostal Centro Histórico',
      location: 'Coro',
      type: 'Hostal',
      pricePerNight: 18,
      rating: 4.1,
      reviewCount: 89,
      imageUrl: _colonial,
      capacity: 2,
      description:
          'Hostal colonial a pasos de la zona patrimonial, con habitaciones '
          'privadas y patio interno.',
      amenities: ['WiFi', 'Cocina compartida', 'Patio'],
    ),
    Accommodation(
      name: 'Cabaña Los Andes',
      location: 'Mérida',
      type: 'Cabaña',
      pricePerNight: 45,
      rating: 4.8,
      reviewCount: 152,
      imageUrl: _mountain,
      capacity: 5,
      description:
          'Cabaña de madera con chimenea y vista a los picos nevados. Perfecta '
          'para una escapada en pareja o familia.',
      amenities: ['Chimenea', 'Cocina', 'WiFi', 'Estacionamiento'],
    ),
    Accommodation(
      name: 'Posada Playa Grande',
      location: 'Choroní',
      type: 'Posada',
      pricePerNight: 30,
      rating: 4.4,
      reviewCount: 73,
      imageUrl: _beach,
      capacity: 4,
      description:
          'A pocos metros de una de las playas más bonitas de la costa, con '
          'terraza y hamacas.',
      amenities: ['WiFi', 'Terraza', 'Desayuno'],
    ),
    Accommodation(
      name: 'Camping Río Claro',
      location: 'Canaima',
      type: 'Camping',
      pricePerNight: 15,
      rating: 4.5,
      reviewCount: 41,
      imageUrl: _desert,
      capacity: 8,
      description:
          'Acampada a orillas de ríos cristalinos, con excursiones a saltos de '
          'agua incluidas.',
      amenities: ['Excursiones', 'Fogata', 'Guía local'],
    ),
    Accommodation(
      name: 'Hostal Backpackers',
      location: 'Caracas',
      type: 'Hostal',
      pricePerNight: 22,
      rating: 4.0,
      reviewCount: 210,
      imageUrl: _hostel,
      capacity: 1,
      description:
          'Hostal urbano para mochileros, con áreas comunes, lockers y muy '
          'buena conexión a transporte público.',
      amenities: ['WiFi', 'Lockers', 'Área común', 'Cerca del metro'],
    ),
    Accommodation(
      name: 'Eco-Lodge Gran Sabana',
      location: 'Santa Elena',
      type: 'Eco-Lodge',
      pricePerNight: 60,
      rating: 4.9,
      reviewCount: 97,
      imageUrl: _ecolodge,
      capacity: 4,
      description:
          'Eco-lodge sostenible en plena selva, con energía solar y tours de '
          'naturaleza de bajo impacto.',
      amenities: ['Energía solar', 'Tours', 'Desayuno', 'WiFi'],
    ),
  ];

  /// Catálogo completo (para secciones destacadas).
  List<Accommodation> all() => List.unmodifiable(_all);

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
