/// Capa de DATOS - Modelo de dominio.
/// Representa un alojamiento económico publicado en EcoSpot.
/// Se mantiene libre de dependencias de Flutter para no acoplar
/// la lógica de negocio con la interfaz.
class Accommodation {
  final String name;
  final String location;
  final String type; // Posada, Camping, Hostal, Cabaña, Eco-Lodge
  final double pricePerNight;

  // Datos enriquecidos usados por las tarjetas y la vista de detalle (CU-02),
  // alineados con el diseño del Figma (rating con estrellas, foto, amenidades).
  final double rating;
  final int reviewCount;
  final String? imageUrl;
  final String? description;
  final int? capacity;
  final List<String> amenities;
  final List<String> rules;

  const Accommodation({
    required this.name,
    required this.location,
    required this.type,
    required this.pricePerNight,
    this.rating = 0,
    this.reviewCount = 0,
    this.imageUrl,
    this.description,
    this.capacity,
    this.amenities = const [],
    this.rules = const [],
  });

  /// Construye un Accommodation a partir de un documento de Firestore
  /// (colección "accommodations"). Tolera campos ausentes.
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
