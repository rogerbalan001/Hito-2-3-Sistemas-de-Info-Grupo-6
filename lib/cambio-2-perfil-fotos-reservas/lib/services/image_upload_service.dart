import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// PATRÓN DE DISEÑO: Singleton.
/// Centraliza la selección de imágenes (foto de perfil, fotos de un
/// alojamiento) y su subida a Firebase Storage. Funciona igual en web y en
/// móvil porque [ImagePicker] devuelve [XFile], que se lee como bytes en
/// ambos casos (no depende de `dart:io`).
class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  factory ImageUploadService() => _instance;
  ImageUploadService._internal();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Abre el selector y permite elegir VARIAS imágenes a la vez (galería de
  /// un alojamiento). [maxImages] limita cuántas se pueden elegir en esta
  /// llamada; quien use el servicio debe además respetar el máximo total
  /// (p. ej. 10 fotos por alojamiento) sumando lo que ya tenía.
  Future<List<XFile>> seleccionarImagenes({int maxImages = 10}) async {
    final archivos = await _picker.pickMultiImage(
      limit: maxImages,
      imageQuality: 85,
    );
    return archivos;
  }

  /// Abre el selector para UNA sola imagen (foto de perfil).
  Future<XFile?> seleccionarImagen() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
  }

  /// Sube una imagen ya elegida a `carpeta/nombreArchivo` en Storage y
  /// devuelve la URL pública de descarga para guardarla en Firestore.
  Future<String> subirImagen(
    XFile archivo, {
    required String carpeta,
    required String nombreArchivo,
  }) async {
    final Uint8List bytes = await archivo.readAsBytes();
    final ref = _storage.ref().child(carpeta).child(nombreArchivo);
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  /// Sube las fotos de un alojamiento publicado por [operatorId] y devuelve
  /// la lista de URLs en el mismo orden. Cada foto queda en
  /// `accommodations/{operatorId}/{timestamp}_{indice}.jpg`.
  Future<List<String>> subirFotosAlojamiento(
    List<XFile> fotos,
    String operatorId,
  ) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final urls = <String>[];
    for (var i = 0; i < fotos.length; i++) {
      final url = await subirImagen(
        fotos[i],
        carpeta: 'accommodations/$operatorId',
        nombreArchivo: '${timestamp}_$i.jpg',
      );
      urls.add(url);
    }
    return urls;
  }

  /// Sube la foto de perfil de [uid] y devuelve la URL. Siempre usa el mismo
  /// nombre de archivo para que la foto nueva reemplace a la anterior en
  /// Storage en vez de acumular archivos sin usar.
  Future<String> subirFotoPerfil(XFile foto, String uid) async {
    return subirImagen(
      foto,
      carpeta: 'usuarios/$uid',
      nombreArchivo: 'perfil.jpg',
    );
  }
}
