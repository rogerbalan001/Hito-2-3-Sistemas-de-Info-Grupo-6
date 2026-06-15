/// Capa de DATOS - Modelo de dominio.
/// Representa un alojamiento económico publicado en EcoSpot.
class Accommodation {
  /// Id del documento en Firestore (null para los datos en memoria/mock).
  /// Necesario para operaciones como eliminar el alojamiento.
  final String? id;
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
    this.id,
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

  factory Accommodation.fromMap(Map<String, dynamic> map, {String? id}) {
    return Accommodation(
      id: id,
      name: (map['nombre'] ?? '') as String,
      location: (map['destino'] ?? '') as String,
      region: (map['region'] ?? '') as String,
      type: (map['tipo'] ?? 'Posada') as String,
      pricePerNight: (map['precioPorNoche'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] as String?,
      description: map['descripcion'] as String?,
      capacity: (map['capacidad'] as num?)?.toInt(),
      transport: (map['transport'] as List?)?.cast<String>() ?? const [],
      amenities: (map['amenities'] as List?)?.cast<String>() ?? const [],
      operatorId: (map['operatorId'] ?? '') as String,
      available: (map['available'] as bool?) ?? true,
    );
  }

  /// Serializa el alojamiento al esquema (en español) usado en la colección
  /// "accommodations" de Firestore. Es la operación inversa de [fromMap], de
  /// modo que lo que se guarda se puede volver a leer sin pérdida de datos.
  Map<String, dynamic> toMap() {
    return {
      'nombre': name,
      'destino': location,
      'region': region,
      'tipo': type,
      'precioPorNoche': pricePerNight,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'descripcion': description,
      'capacidad': capacity,
      'transport': transport,
      'amenities': amenities,
      'operatorId': operatorId,
      'available': available,
    };
  }
}
