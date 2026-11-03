import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/ubicacion.dart';
import 'package:vitrina_regional/features/mapa/domain/repositories/location_repository.dart';

/// Caso de uso: obtener la posición actual del usuario.
class GetUbicacionActual implements UseCase<Ubicacion, NoParams> {
  const GetUbicacionActual(this._repository);

  final LocationRepository _repository;

  @override
  Future<Either<Failure, Ubicacion>> call(NoParams params) =>
      _repository.getUbicacionActual();
}
