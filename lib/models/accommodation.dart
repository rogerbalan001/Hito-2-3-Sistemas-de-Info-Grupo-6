/// Convierte un texto con una regla por línea en la lista usada por el modelo
/// (recorta espacios y descarta líneas vacías). Es la inversa de unir las
/// reglas con saltos de línea para mostrarlas/editarlas en un campo de texto.
List<String> reglasFromText(String raw) {
  return raw
      .split('\n')
      .map((linea) => linea.trim())
      .where((linea) => linea.isNotEmpty)
      .toList();
}

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
  // Galería completa de fotos del alojamiento (hasta 10). [imageUrl] sigue
  // existiendo para no romper los datos mock que ya usan un solo campo; en
  // los alojamientos publicados desde la app, [imageUrl] es simplemente la
  // primera foto de [imageUrls] (la portada).
  final List<String> imageUrls;
  final String? description;
  final int? capacity;
  // Datos estilo Airbnb/TuInmueble para describir mejor el espacio.
  final int? bedrooms; // habitaciones
  final int? bathrooms; // baños
  final int? beds; // camas
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
    this.imageUrls = const [],
    this.description,
    this.capacity,
    this.bedrooms,
    this.bathrooms,
    this.beds,
    this.transport = const [],
    this.amenities = const [],
    this.rules = const [],
    this.operatorId = '',
    this.available = true,
  });

  /// Todas las fotos disponibles, en orden, usables para mostrar una galería.
  /// Si el alojamiento solo tiene el [imageUrl] clásico (datos mock), lo
  /// devuelve como una lista de un elemento.
  List<String> get allImages =>
      imageUrls.isNotEmpty ? imageUrls : (imageUrl != null ? [imageUrl!] : []);

  factory Accommodation.fromMap(Map<String, dynamic> map, {String? id}) {
    final fotos =
        (map['imageUrls'] as List?)?.cast<String>() ?? const <String>[];
    return Accommodation(
      id: id,
      name: (map['nombre'] ?? '') as String,
      location: (map['destino'] ?? '') as String,
      region: (map['region'] ?? '') as String,
      type: (map['tipo'] ?? 'Posada') as String,
      pricePerNight: (map['precioPorNoche'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      imageUrl: (map['imageUrl'] as String?) ??
          (fotos.isNotEmpty ? fotos.first : null),
      imageUrls: fotos,
      description: map['descripcion'] as String?,
      capacity: (map['capacidad'] as num?)?.toInt(),
      bedrooms: (map['habitaciones'] as num?)?.toInt(),
      bathrooms: (map['banos'] as num?)?.toInt(),
      beds: (map['camas'] as num?)?.toInt(),
      transport: (map['transport'] as List?)?.cast<String>() ?? const [],
      amenities: (map['amenities'] as List?)?.cast<String>() ?? const [],
      rules: (map['reglas'] as List?)?.cast<String>() ?? const [],
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
      'imageUrls': imageUrls,
      'descripcion': description,
      'capacidad': capacity,
      'habitaciones': bedrooms,
      'banos': bathrooms,
      'camas': beds,
      'transport': transport,
      'amenities': amenities,
      'reglas': rules,
      'operatorId': operatorId,
      'available': available,
    };
  }
}
