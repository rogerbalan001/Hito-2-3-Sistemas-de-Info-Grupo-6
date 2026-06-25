import 'package:cloud_firestore/cloud_firestore.dart';

/// Elemento simple de catálogo (un id de documento + su nombre).
class NamedItem {
  final String id;
  final String nombre;
  const NamedItem(this.id, this.nombre);
}

/// PATRÓN DE DISEÑO: Repository.
/// Servicio genérico para las tablas de mantenimiento simples (una sola
/// columna "nombre"), como "transporte" y "regiones". Cada instancia apunta a
/// la colección que se le indica al construirla.
class CatalogService {
  CatalogService(String coleccion)
      : _col = FirebaseFirestore.instance.collection(coleccion);

  final CollectionReference<Map<String, dynamic>> _col;

  /// Elementos en tiempo real, ordenados alfabéticamente (orden en cliente).
  Stream<List<NamedItem>> watchAll() {
    return _col.snapshots().map((snap) {
      final items = snap.docs
          .map((d) => NamedItem(d.id, (d.data()['nombre'] ?? '') as String))
          .toList()
        ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
      return items;
    });
  }

  Future<void> agregar(String nombre) async {
    await _col.add({'nombre': nombre});
  }

  Future<void> actualizar(String id, String nombre) async {
    await _col.doc(id).update({'nombre': nombre});
  }

  Future<void> eliminar(String id) async {
    await _col.doc(id).delete();
  }
}
