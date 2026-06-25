import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/mock_data.dart';

/// PATRÓN DE DISEÑO: Repository + Singleton.
/// Gestiona los paquetes turísticos en la colección "paquetes" de Cloud
/// Firestore. Antes eran una lista fija (MockData); ahora se leen en tiempo
/// real y el administrador puede crearlos, editarlos y eliminarlos.
class PackageService {
  static final PackageService _instance = PackageService._internal();
  factory PackageService() => _instance;
  PackageService._internal();

  final CollectionReference<Map<String, dynamic>> _paquetes =
      FirebaseFirestore.instance.collection('paquetes');

  /// Catálogo de paquetes en tiempo real.
  Stream<List<TouristPackage>> watchAll() {
    return _paquetes.snapshots().map(
          (snap) => snap.docs
              .map((d) => TouristPackage.fromMap(d.data(), id: d.id))
              .toList(),
        );
  }

  Future<void> agregar(TouristPackage p) async {
    await _paquetes.add(p.toMap());
  }

  Future<void> actualizar(String id, TouristPackage p) async {
    await _paquetes.doc(id).update(p.toMap());
  }

  Future<void> eliminar(String id) async {
    await _paquetes.doc(id).delete();
  }
}
