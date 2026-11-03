import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:vitrina_regional/core/error/exceptions.dart';

/// Contrato para comprimir y subir bytes de imagen. Devuelve la URL pública.
abstract interface class ImagenStorageDataSource {
  Future<String> subir({
    required Uint8List bytes,
    required String carpeta,
    required String nombre,
  });
}

/// Implementación con Firebase Storage.
class FirebaseImagenStorageDataSource implements ImagenStorageDataSource {
  FirebaseImagenStorageDataSource(this._storage);

  final FirebaseStorage _storage;

  @override
  Future<String> subir({
    required Uint8List bytes,
    required String carpeta,
    required String nombre,
  }) async {
    // TODO(COIL-E4-1): Comprimir ANTES de subir con flutter_image_compress:
    //   final comprimidos = await FlutterImageCompress.compressWithList(
    //     bytes, minWidth: 1280, minHeight: 1280, quality: 75);
    //   (import 'package:flutter_image_compress/flutter_image_compress.dart')
    // TODO(COIL-E4-2): Subir los bytes comprimidos y devolver la URL:
    //   final ref = _storage.ref('$carpeta/${DateTime.now()
    //       .millisecondsSinceEpoch}_$nombre');
    //   await ref.putData(comprimidos,
    //       SettableMetadata(contentType: 'image/jpeg'));
    //   return ref.getDownloadURL();
    //   Capturar FirebaseException -> PermissionException / ServerException.
    //   Recuerden: storage.rules rechaza archivos >= 5 MB o que no sean imagen.
    throw ServerException(
      'Subida pendiente (encuentro E4). Bucket: ${_storage.bucket}',
    );
  }
}

/// Simula la subida devolviendo una imagen de ejemplo (modo mock).
class MockImagenStorageDataSource implements ImagenStorageDataSource {
  const MockImagenStorageDataSource();

  @override
  Future<String> subir({
    required Uint8List bytes,
    required String carpeta,
    required String nombre,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return 'https://picsum.photos/seed/${nombre.hashCode}/800/600';
  }
}
