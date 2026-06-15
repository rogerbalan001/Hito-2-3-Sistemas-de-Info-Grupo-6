import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/accommodation.dart';

/// PATRÓN DE DISEÑO: Repository + Singleton.
/// Abstrae el origen de los datos del CATÁLOGO de alojamientos. Ahora lee en
/// tiempo real de la colección "accommodations" de Cloud Firestore (las mismas
/// publicaciones que crean los operadores/administradores). Las pantallas solo
/// conocen [watchAll] y [search], sin saber que detrás hay Firestore.
class AccommodationRepository {
  static final AccommodationRepository _instance =
      AccommodationRepository._internal();
  factory AccommodationRepository() => _instance;
  AccommodationRepository._internal();

  final CollectionReference<Map<String, dynamic>> _accommodations =
      FirebaseFirestore.instance.collection('accommodations');

  /// Catálogo completo en tiempo real. Cada documento se convierte al modelo
  /// de dominio con [Accommodation.fromMap].
  Stream<List<Accommodation>> watchAll() {
    return _accommodations.snapshots().map(
          (snap) => snap.docs
              .map((d) => Accommodation.fromMap(d.data(), id: d.id))
              .toList(),
        );
  }

  /// Filtra una lista ya cargada (la que entrega [watchAll]) por texto de
  /// destino (nombre o ubicación) y presupuesto máximo. Es lógica de interfaz
  /// pura: no toca la red, por eso recibe la lista de origen.
  List<Accommodation> search(
    List<Accommodation> source, {
    String query = '',
    double maxBudget = double.infinity,
  }) {
    final q = query.trim().toLowerCase();
    return source.where((a) {
      final matchesQuery = q.isEmpty ||
          a.name.toLowerCase().contains(q) ||
          a.location.toLowerCase().contains(q);
      final matchesBudget = a.pricePerNight <= maxBudget;
      return matchesQuery && matchesBudget;
    }).toList();
  }
}
