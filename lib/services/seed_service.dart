import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/mock_data.dart';
import '../models/accommodation.dart';

/// Carga inicial de datos ("seeding").
/// Sube el catálogo de alojamientos del diseño (MockData) a la colección
/// "accommodations" de Cloud Firestore para que la Búsqueda y el Inicio
/// muestren publicaciones reales desde la base de datos.
///
/// Es IDEMPOTENTE: usa un id de documento determinístico por alojamiento
/// (derivado del nombre), así que reejecutarlo no crea duplicados. Además solo
/// siembra si la colección está vacía, para no sobrescribir lo que ya exista.
class SeedService {
  static final SeedService _instance = SeedService._internal();
  factory SeedService() => _instance;
  SeedService._internal();

  final CollectionReference<Map<String, dynamic>> _accommodations =
      FirebaseFirestore.instance.collection('accommodations');

  /// Siembra el catálogo solo si la colección está vacía. Pensado para
  /// llamarse una vez tras iniciar sesión (contexto autenticado). Cualquier
  /// error se ignora para no bloquear el flujo de la app.
  Future<void> seedAccommodationsIfEmpty() async {
    try {
      final existentes = await _accommodations.limit(1).get();
      if (existentes.docs.isNotEmpty) return; // ya hay datos: no hacer nada
      await _subirCatalogo();
    } catch (_) {
      // Sin permisos o sin red: se omite la siembra silenciosamente.
    }
  }

  /// Escribe todos los alojamientos mock con id determinístico (set/merge).
  Future<void> _subirCatalogo() async {
    final batch = FirebaseFirestore.instance.batch();
    for (final a in MockData.accommodations) {
      final doc = _accommodations.doc(_slug(a.name));
      batch.set(doc, {
        ...a.toMap(),
        'seed': true, // marca de origen (dato de ejemplo)
        'fecha': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Convierte un nombre en un id estable (minúsculas, sin espacios ni signos).
  String _slug(String name) {
    final base = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'(^-|-$)'), '');
    return base.isEmpty ? 'alojamiento' : base;
  }
}
