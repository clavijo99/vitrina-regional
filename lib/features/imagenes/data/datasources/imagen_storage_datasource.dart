import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:vitrina_regional/core/error/exceptions.dart';

/// Contrato para comprimir y subir bytes de imagen. Devuelve la URL pública.
abstract interface class ImagenStorageDataSource {
  Future<String> subir({
    required Uint8List bytes,
    required String carpeta,
    required String nombre,
  });
}

/// Implementación con Cloudinary usando un *upload preset* sin firmar
/// (`unsigned`): la app sube directo sin backend y sin exponer el API secret.
///
/// Solo se necesitan dos datos públicos (no son secretos en modo unsigned):
///   - [cloudName]: el "Cloud name" del dashboard.
///   - [uploadPreset]: el preset creado en Settings → Upload (Signing: Unsigned).
class CloudinaryImagenStorageDataSource implements ImagenStorageDataSource {
  const CloudinaryImagenStorageDataSource({
    this.cloudName = 'ssuvy1rd',
    this.uploadPreset = 'vitrina_unsigned',
  });

  final String cloudName;
  final String uploadPreset;

  Uri get _endpoint =>
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  @override
  Future<String> subir({
    required Uint8List bytes,
    required String carpeta,
    required String nombre,
  }) async {
    try {
      // 1) Comprimir antes de subir: ahorra ancho de banda y tiempo.
      //    No todas las plataformas de escritorio soportan la compresión
      //    nativa; si falla, subimos los bytes originales.
      Uint8List comprimidos;
      try {
        comprimidos = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 1280,
          minHeight: 1280,
          quality: 75,
        );
      } catch (_) {
        comprimidos = bytes;
      }

      // 2) Subida multipart al endpoint de Cloudinary.
      final request = http.MultipartRequest('POST', _endpoint)
        ..fields['upload_preset'] = uploadPreset
        // Subcarpeta por recurso, ej.: `emprendimientos/{id}`.
        ..fields['folder'] = 'vitrina-regional/$carpeta'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            comprimidos,
            filename: nombre,
          ),
        );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final url = data['secure_url'] as String?;
        if (url == null) {
          throw const ServerException('Cloudinary no devolvió una URL.');
        }
        return url;
      }

      // 401/400 suelen ser preset mal configurado (no está en Unsigned).
      if (response.statusCode == 401) {
        throw const PermissionException(
          'Cloudinary rechazó la subida (¿el preset está en modo Unsigned?).',
        );
      }
      throw ServerException(
        'Error al subir la imagen (HTTP ${response.statusCode}).',
      );
    } on PermissionException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('No se pudo subir la imagen: $e');
    }
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
