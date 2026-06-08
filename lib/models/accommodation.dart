/// Capa de DATOS - Modelo de dominio.
/// Representa un alojamiento económico publicado en EcoSpot.
/// Se mantiene libre de dependencias de Flutter para no acoplar
/// la lógica de negocio con la interfaz.
class Accommodation {
  final String name;
  final String location;
  final String type; // Posada, Camping, Hostal, Cabaña, Eco-Lodge
  final double pricePerNight;

  const Accommodation({
    required this.name,
    required this.location,
    required this.type,
    required this.pricePerNight,
  });
}
