import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/repositories/emprendimiento_repository.dart';

/// Caso de uso: obtener el emprendimiento del emprendedor autenticado.
/// Regla de negocio: cada emprendedor tiene como máximo UN emprendimiento.
class GetEmprendimientoByOwner implements UseCase<Emprendimiento?, String> {
  const GetEmprendimientoByOwner(this._repository);

  final EmprendimientoRepository _repository;

  @override
  Future<Either<Failure, Emprendimiento?>> call(String ownerId) =>
      _repository.getByOwner(ownerId);
}
