import '../models/accommodation.dart';

/// Fuente única de datos simulados (mock), alineada con el diseño del Figma.
/// Centraliza alojamientos, paquetes, reseñas, operadores y métricas para que
/// todas las pantallas (Inicio, Buscar, Paquetes, Comunidad, Operadores,
/// Dashboard, Administración) consuman exactamente lo mismo.

class EcoImages {
  EcoImages._();
  static const beach =
      'https://images.unsplash.com/photo-1611946022552-d2ca5ffba186?auto=format&fit=crop&w=1080&q=80';
  static const mountain =
      'https://images.unsplash.com/photo-1695664488281-d7166250482d?auto=format&fit=crop&w=1080&q=80';
  static const colonial =
      'https://images.unsplash.com/photo-1762995350095-4d8479227c77?auto=format&fit=crop&w=1080&q=80';
  static const hostel =
      'https://images.unsplash.com/photo-1768289269971-6171457bed13?auto=format&fit=crop&w=1080&q=80';
  static const ecolodge =
      'https://images.unsplash.com/photo-1650201776749-fde3862e5354?auto=format&fit=crop&w=1080&q=80';
  static const desert =
      'https://images.unsplash.com/photo-1725509408295-17d8def5b14e?auto=format&fit=crop&w=1080&q=80';
}

class TouristPackage {
  final String name;
  final String destination;
  final String duration;
  final double price;
  final List<String> includes;
  final String imageUrl;
  final double rating;
  const TouristPackage({
    required this.name,
    required this.destination,
    required this.duration,
    required this.price,
    required this.includes,
    required this.imageUrl,
    required this.rating,
  });
}

class Review {
  final String userName;
  final String avatar;
  final int rating;
  final String comment;
  final bool priceAccuracy;
  final String date;
  final String accommodationName;
  final String accommodationLocation;
  const Review({
    required this.userName,
    required this.avatar,
    required this.rating,
    required this.comment,
    required this.priceAccuracy,
    required this.date,
    required this.accommodationName,
    required this.accommodationLocation,
  });
}

class OperatorInfo {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int services;
  final bool verified;
  const OperatorInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.services,
    required this.verified,
  });
}

class DestinationStat {
  final String destination;
  final int searches;
  final int avgBudget;
  const DestinationStat(this.destination, this.searches, this.avgBudget);
}

class RangeCount {
  final String label;
  final int count;
  const RangeCount(this.label, this.count);
}

class StatusCount {
  final String status;
  final int count;
  final int colorValue; // 0xFF......
  const StatusCount(this.status, this.count, this.colorValue);
}

class MonthStat {
  final String month;
  final int reservations;
  final int revenue;
  const MonthStat(this.month, this.reservations, this.revenue);
}

/// Punto único de acceso a los datos simulados.
class MockData {
  MockData._();

  static const List<Accommodation> accommodations = [
    Accommodation(
      name: 'Posada Sol del Caribe',
      type: 'Posada',
      location: 'Isla Margarita',
      region: 'Caribe',
      pricePerNight: 25,
      capacity: 12,
      rating: 4.5,
      reviewCount: 89,
      imageUrl: EcoImages.beach,
      description:
          'Acogedora posada frente al mar con vista espectacular al atardecer. '
          'Ideal para viajeros con presupuesto ajustado.',
      transport: ['bus', 'lancha'],
      amenities: ['WiFi', 'Desayuno', 'Piscina', 'Estacionamiento'],
      operatorId: 'op-1',
    ),
    Accommodation(
      name: 'Camping Montaña Azul',
      type: 'Camping',
      location: 'Mérida',
      region: 'Andes',
      pricePerNight: 10,
      capacity: 30,
      rating: 4.2,
      reviewCount: 56,
      imageUrl: EcoImages.mountain,
      description:
          'Camping en la montaña con vistas panorámicas de los Andes. Incluye '
          'zona de fogata y baños compartidos.',
      transport: ['bus', 'colectivo'],
      amenities: ['Baños', 'Fogata', 'Zona BBQ', 'Seguridad 24h'],
      operatorId: 'op-2',
    ),
    Accommodation(
      name: 'Hostel Colonial Center',
      type: 'Hostel',
      location: 'Cartagena',
      region: 'Caribe',
      pricePerNight: 18,
      capacity: 40,
      rating: 4.7,
      reviewCount: 134,
      imageUrl: EcoImages.colonial,
      description:
          'Hostel en el corazón del centro histórico. Habitaciones compartidas '
          'y privadas disponibles.',
      transport: ['bus', 'colectivo'],
      amenities: ['WiFi', 'Cocina', 'Terraza', 'Lavandería'],
      operatorId: 'op-3',
    ),
    Accommodation(
      name: 'Posada La Ceiba',
      type: 'Posada',
      location: 'Canaima',
      region: 'Amazonas',
      pricePerNight: 35,
      capacity: 8,
      rating: 4.8,
      reviewCount: 42,
      imageUrl: EcoImages.ecolodge,
      description:
          'Posada rústica en plena selva amazónica. Excursiones al Salto Ángel '
          'incluidas.',
      transport: ['lancha'],
      amenities: ['Tours', 'Comidas', 'Guía local', 'Hamacas'],
      operatorId: 'op-1',
    ),
    Accommodation(
      name: 'Cabaña Desierto Dorado',
      type: 'Cabaña',
      location: 'Médanos de Coro',
      region: 'Occidente',
      pricePerNight: 22,
      capacity: 6,
      rating: 4.1,
      reviewCount: 28,
      imageUrl: EcoImages.desert,
      description:
          'Cabañas con vista al desierto. Experiencia única bajo cielos '
          'estrellados.',
      transport: ['bus'],
      amenities: ['A/C', 'WiFi', 'Estacionamiento', 'Piscina'],
      operatorId: 'op-4',
      available: false,
    ),
    Accommodation(
      name: 'Eco-Lodge Selva Verde',
      type: 'Eco-Lodge',
      location: 'Puerto Ayacucho',
      region: 'Amazonas',
      pricePerNight: 40,
      capacity: 16,
      rating: 4.6,
      reviewCount: 67,
      imageUrl: EcoImages.ecolodge,
      description:
          'Lodge ecológico con energía solar y huertos orgánicos. Turismo '
          'sustentable.',
      transport: ['lancha', 'bus'],
      amenities: ['Comidas orgánicas', 'Tours', 'WiFi', 'Yoga'],
      operatorId: 'op-5',
    ),
  ];

  static const List<TouristPackage> packages = [
    TouristPackage(
      name: 'Aventura Andina',
      destination: 'Mérida',
      duration: '5 días / 4 noches',
      price: 120,
      includes: ['Alojamiento', 'Transporte', 'Guía', 'Comidas'],
      imageUrl: EcoImages.mountain,
      rating: 4.6,
    ),
    TouristPackage(
      name: 'Paraíso Caribeño',
      destination: 'Isla Margarita',
      duration: '4 días / 3 noches',
      price: 150,
      includes: ['Alojamiento', 'Ferry', 'Tours', 'Desayunos'],
      imageUrl: EcoImages.beach,
      rating: 4.8,
    ),
    TouristPackage(
      name: 'Selva Mágica',
      destination: 'Canaima',
      duration: '3 días / 2 noches',
      price: 200,
      includes: ['Alojamiento', 'Vuelo', 'Excursiones', 'Comidas'],
      imageUrl: EcoImages.ecolodge,
      rating: 4.9,
    ),
    TouristPackage(
      name: 'Ruta Colonial',
      destination: 'Cartagena',
      duration: '3 días / 2 noches',
      price: 95,
      includes: ['Hostel', 'Tours a pie', 'Desayunos'],
      imageUrl: EcoImages.colonial,
      rating: 4.4,
    ),
  ];

  static const List<Review> reviews = [
    Review(
        userName: 'Juan Torres',
        avatar: 'JT',
        rating: 5,
        comment:
            'Excelente relación calidad-precio. Los \$25/noche son reales y la '
            'vista es increíble.',
        priceAccuracy: true,
        date: '2026-03-15',
        accommodationName: 'Posada Sol del Caribe',
        accommodationLocation: 'Isla Margarita'),
    Review(
        userName: 'Laura Méndez',
        avatar: 'LM',
        rating: 4,
        comment:
            'Muy buena posada. Cobran un extra por la piscina que no está en '
            'la publicación.',
        priceAccuracy: false,
        date: '2026-03-20',
        accommodationName: 'Posada Sol del Caribe',
        accommodationLocation: 'Isla Margarita'),
    Review(
        userName: 'Roberto Silva',
        avatar: 'RS',
        rating: 4,
        comment:
            'Camping bien mantenido. Los precios son exactos. La fogata es '
            'genial.',
        priceAccuracy: true,
        date: '2026-02-10',
        accommodationName: 'Camping Montaña Azul',
        accommodationLocation: 'Mérida'),
    Review(
        userName: 'Sofía Castro',
        avatar: 'SC',
        rating: 5,
        comment:
            'El mejor hostel de la zona. Todo limpio y el precio es justo.',
        priceAccuracy: true,
        date: '2026-04-01',
        accommodationName: 'Hostel Colonial Center',
        accommodationLocation: 'Cartagena'),
    Review(
        userName: 'Diego Ramírez',
        avatar: 'DR',
        rating: 5,
        comment:
            'Experiencia única. El Salto Ángel es impresionante. Precio justo '
            'por todo lo incluido.',
        priceAccuracy: true,
        date: '2026-03-25',
        accommodationName: 'Posada La Ceiba',
        accommodationLocation: 'Canaima'),
    Review(
        userName: 'Valentina López',
        avatar: 'VL',
        rating: 4,
        comment:
            'Buena ubicación, personal amable. El desayuno debería estar '
            'incluido a ese precio.',
        priceAccuracy: true,
        date: '2026-04-05',
        accommodationName: 'Hostel Colonial Center',
        accommodationLocation: 'Cartagena'),
  ];

  static const List<OperatorInfo> operators = [
    OperatorInfo(
        id: 'op-1',
        name: 'Turismo Sol S.A.',
        email: 'info@turismosol.com',
        phone: '+58 412-5551234',
        services: 2,
        verified: true),
    OperatorInfo(
        id: 'op-2',
        name: 'Aventuras Andinas',
        email: 'contacto@aventurasandinas.com',
        phone: '+58 414-5559876',
        services: 1,
        verified: true),
    OperatorInfo(
        id: 'op-3',
        name: 'Colonial Tours',
        email: 'reservas@colonialtours.com',
        phone: '+57 315-5554321',
        services: 1,
        verified: true),
    OperatorInfo(
        id: 'op-4',
        name: 'Desierto Extremo',
        email: 'info@desiertoextremo.com',
        phone: '+58 416-5558765',
        services: 1,
        verified: false),
    OperatorInfo(
        id: 'op-5',
        name: 'EcoVerde Lodge',
        email: 'eco@verde.com',
        phone: '+58 426-5552345',
        services: 1,
        verified: true),
  ];

  static const List<DestinationStat> searchesByDestination = [
    DestinationStat('Isla Margarita', 1240, 30),
    DestinationStat('Mérida', 980, 20),
    DestinationStat('Cartagena', 870, 25),
    DestinationStat('Canaima', 650, 45),
    DestinationStat('Médanos de Coro', 420, 22),
    DestinationStat('Puerto Ayacucho', 310, 40),
  ];

  static const List<RangeCount> priceRangeDistribution = [
    RangeCount('\$0-15', 340),
    RangeCount('\$16-25', 520),
    RangeCount('\$26-35', 380),
    RangeCount('\$36-50', 210),
    RangeCount('\$50+', 90),
  ];

  static const List<StatusCount> statusDistribution = [
    StatusCount('Solicitado', 35, 0xFFF59E0B),
    StatusCount('Aprobado', 28, 0xFF3B82F6),
    StatusCount('Pagado', 52, 0xFF10B981),
    StatusCount('Disfrutado', 120, 0xFF8B5CF6),
    StatusCount('Cancelado', 12, 0xFFEF4444),
  ];

  static const List<MonthStat> reservationsByMonth = [
    MonthStat('Ene', 45, 3200),
    MonthStat('Feb', 62, 4500),
    MonthStat('Mar', 78, 5800),
    MonthStat('Abr', 95, 7200),
    MonthStat('May', 110, 8400),
    MonthStat('Jun', 85, 6100),
  ];

  static const List<String> accommodationTypeLabels = [
    'Posada',
    'Camping',
    'Hostel',
    'Cabaña',
    'Eco-Lodge',
  ];

  static const List<String> regions = [
    'Caribe',
    'Andes',
    'Amazonas',
    'Occidente',
  ];

  static const List<String> transportLabels = [
    'Bus',
    'Tren',
    'Lancha',
    'Colectivo',
  ];
}
