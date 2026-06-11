/// Capa de DATOS - Modelo de dominio.
/// Representa un alojamiento económico publicado en EcoSpot.
class Accommodation {
  final String name;
  final String location;
  final String region;
  final String type; // Posada, Camping, Hostel, Cabaña, Eco-Lodge
  final double pricePerNight;
  final double rating;
  final int reviewCount;
  final String? imageUrl;
  final String? description;
  final int? capacity;
  final List<String> transport; // bus, tren, lancha, colectivo
  final List<String> amenities;
  final List<String> rules;
  final String operatorId;
  final bool available;

  const Accommodation({
    required this.name,
    required this.location,
    this.region = '',
    required this.type,
    required this.pricePerNight,
    this.rating = 0,
    this.reviewCount = 0,
    this.imageUrl,
    this.description,
    this.capacity,
    this.transport = const [],
    this.amenities = const [],
    this.rules = const [],
    this.operatorId = '',
    this.available = true,
  });

  factory Accommodation.fromMap(Map<String, dynamic> map) {
    return Accommodation(
      name: (map['nombre'] ?? '') as String,
      location: (map['destino'] ?? '') as String,
      type: (map['tipo'] ?? 'Posada') as String,
      pricePerNight: (map['precioPorNoche'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] as String?,
      description: map['descripcion'] as String?,
      capacity: (map['capacidad'] as num?)?.toInt(),
    );
  }
}
