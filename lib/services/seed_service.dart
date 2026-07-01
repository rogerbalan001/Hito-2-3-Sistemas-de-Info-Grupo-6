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

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final CollectionReference<Map<String, dynamic>> _accommodations =
      FirebaseFirestore.instance.collection('accommodations');

  /// Siembra TODAS las colecciones de catálogo que estén vacías (alojamientos,
  /// paquetes, reseñas, transporte y regiones). Pensado para llamarse una vez
  /// tras iniciar sesión. Cada colección se siembra de forma independiente.
  Future<void> seedAllIfEmpty() async {
    await seedAccommodationsIfEmpty();
    await _seedIfEmpty(
        'paquetes', () => MockData.packages.map((p) => p.toMap()).toList());
    await _seedIfEmpty('resenas', () {
      var i = 0;
      // 'creado' incremental para que el orden inicial sea estable.
      return MockData.reviews
          .map((r) => {
                ...r.toMap(),
                'creado': Timestamp.fromMillisecondsSinceEpoch(i++),
              })
          .toList();
    });
    await _seedIfEmpty('transporte',
        () => MockData.transportLabels.map((t) => {'nombre': t}).toList());
    await _seedIfEmpty(
        'regiones', () => MockData.regions.map((r) => {'nombre': r}).toList());
  }

  /// Siembra el catálogo de alojamientos solo si la colección está vacía.
  /// Pensado para llamarse una vez tras iniciar sesión (contexto autenticado).
  /// Cualquier error se ignora para no bloquear el flujo de la app.
  Future<void> seedAccommodationsIfEmpty() async {
    try {
      final existentes = await _accommodations.limit(1).get();
      if (existentes.docs.isNotEmpty) return; // ya hay datos: no hacer nada
      await _subirCatalogo();
    } catch (_) {
      // Sin permisos o sin red: se omite la siembra silenciosamente.
    }
  }

  /// Helper genérico: si [coleccion] está vacía, sube los documentos que
  /// produce [datos]. Silencioso ante errores.
  Future<void> _seedIfEmpty(
    String coleccion,
    List<Map<String, dynamic>> Function() datos,
  ) async {
    try {
      final col = _db.collection(coleccion);
      final existentes = await col.limit(1).get();
      if (existentes.docs.isNotEmpty) return;
      final batch = _db.batch();
      for (final d in datos()) {
        batch.set(col.doc(), d);
      }
      await batch.commit();
    } catch (_) {
      // Se omite la siembra silenciosamente.
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
