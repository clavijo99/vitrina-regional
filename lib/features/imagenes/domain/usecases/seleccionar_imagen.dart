import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/imagenes/domain/entities/imagen_seleccionada.dart';
import 'package:vitrina_regional/features/imagenes/domain/repositories/imagen_repository.dart';

/// Caso de uso: elegir una imagen de la cámara o la galería.
class SeleccionarImagen implements UseCase<ImagenSeleccionada?, FuenteImagen> {
  const SeleccionarImagen(this._repository);

  final ImagenRepository _repository;

  @override
  Future<Either<Failure, ImagenSeleccionada?>> call(FuenteImagen fuente) =>
      _repository.seleccionar(fuente);
}
