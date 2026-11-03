import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/imagenes/domain/entities/imagen_seleccionada.dart';
import 'package:vitrina_regional/features/imagenes/domain/repositories/imagen_repository.dart';

/// Caso de uso: subir una imagen y obtener su URL.
class SubirImagen implements UseCase<String, SubirImagenParams> {
  const SubirImagen(this._repository);

  final ImagenRepository _repository;

  @override
  Future<Either<Failure, String>> call(SubirImagenParams params) async {
    if (params.imagen.bytes.isEmpty) {
      return const Left(ValidationFailure('La imagen está vacía.'));
    }
    return _repository.subir(imagen: params.imagen, carpeta: params.carpeta);
  }
}

class SubirImagenParams extends Equatable {
  const SubirImagenParams({required this.imagen, required this.carpeta});

  final ImagenSeleccionada imagen;

  /// Ej.: `emprendimientos/{emprendimientoId}`.
  final String carpeta;

  @override
  List<Object?> get props => [imagen, carpeta];
}
