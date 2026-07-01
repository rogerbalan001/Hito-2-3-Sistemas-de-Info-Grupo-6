import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/mock_data.dart';

/// PATRÓN DE DISEÑO: Repository + Singleton.
/// Gestiona las reseñas (Comunidad / Feedback) en la colección "resenas" de
/// Cloud Firestore. Antes vivían solo en memoria (MockData); ahora se publican
/// y se leen en tiempo real, y el administrador puede moderarlas (eliminar).
class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final CollectionReference<Map<String, dynamic>> _resenas =
      FirebaseFirestore.instance.collection('resenas');

  /// Todas las reseñas en tiempo real, ordenadas de la más reciente a la más
  /// antigua (orden en cliente para no requerir un índice de Firestore).
  Stream<List<Review>> watchAll() {
    return _resenas.snapshots().map((snap) {
      final docs = snap.docs.toList()
        ..sort((a, b) {
          final ca = a.data()['creado'];
          final cb = b.data()['creado'];
          if (ca is Timestamp && cb is Timestamp) return cb.compareTo(ca);
          return 0;
        });
      return docs.map((d) => Review.fromMap(d.data(), id: d.id)).toList();
    });
  }

  /// Publica una nueva reseña.
  Future<void> agregar(Review r) async {
    await _resenas.add({
      ...r.toMap(),
      'creado': FieldValue.serverTimestamp(),
    });
  }

  /// Elimina una reseña (moderación del administrador).
  Future<void> eliminar(String id) async {
    await _resenas.doc(id).delete();
  }
}
