import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/imagenes/data/datasources/imagen_picker_datasource.dart';
import 'package:vitrina_regional/features/imagenes/data/datasources/imagen_storage_datasource.dart';
import 'package:vitrina_regional/features/imagenes/domain/entities/imagen_seleccionada.dart';
import 'package:vitrina_regional/features/imagenes/domain/repositories/imagen_repository.dart';

class ImagenRepositoryImpl implements ImagenRepository {
  const ImagenRepositoryImpl({required this._picker, required this._storage});

  final ImagenPickerDataSource _picker;
  final ImagenStorageDataSource _storage;

  @override
  Future<Either<Failure, ImagenSeleccionada?>> seleccionar(
    FuenteImagen fuente,
  ) async {
    try {
      return Right(await _picker.seleccionar(fuente));
    } catch (_) {
      return const Left(
        PermissionFailure('No se pudo acceder a la cámara o la galería.'),
      );
    }
  }

  @override
  Future<Either<Failure, String>> subir({
    required ImagenSeleccionada imagen,
    required String carpeta,
  }) async {
    try {
      final url = await _storage.subir(
        bytes: imagen.bytes,
        carpeta: carpeta,
        nombre: imagen.nombre,
      );
      return Right(url);
    } on PermissionException {
      return const Left(PermissionFailure('No tienes permiso para subir.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'No se pudo subir la imagen.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
