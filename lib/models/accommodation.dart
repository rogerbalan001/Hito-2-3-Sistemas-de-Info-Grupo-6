/// Capa de DATOS - Modelo de dominio.
/// Representa un alojamiento económico publicado en EcoSpot.
/// Se mantiene libre de dependencias de Flutter para no acoplar
/// la lógica de negocio con la interfaz.
class Accommodation {
  final String name;
  final String location;
  final String type; // Posada, Camping, Hostal, Cabaña, Eco-Lodge
  final double pricePerNight;

  // Campos opcionales usados por la vista de detalle (CU-02) y por los
  // alojamientos que publican los operadores desde Firestore.
  final String? description;
  final int? capacity;
  final List<String> rules;

  const Accommodation({
    required this.name,
    required this.location,
    required this.type,
    required this.pricePerNight,
    this.description,
    this.capacity,
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
      description: map['descripcion'] as String?,
      capacity: (map['capacidad'] as num?)?.toInt(),
    );
  }
}
