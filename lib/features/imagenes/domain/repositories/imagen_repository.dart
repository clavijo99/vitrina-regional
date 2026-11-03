import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/imagenes/domain/entities/imagen_seleccionada.dart';

/// Contrato para elegir y subir imágenes.
abstract interface class ImagenRepository {
  /// `Right(null)` si el usuario canceló la selección.
  Future<Either<Failure, ImagenSeleccionada?>> seleccionar(FuenteImagen fuente);

  /// Comprime y sube la imagen a `carpeta`. Devuelve la URL pública.
  Future<Either<Failure, String>> subir({
    required ImagenSeleccionada imagen,
    required String carpeta,
  });
}
