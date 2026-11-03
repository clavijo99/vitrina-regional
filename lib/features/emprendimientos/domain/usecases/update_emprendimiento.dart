import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/repositories/emprendimiento_repository.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/validar_emprendimiento.dart';

/// Caso de uso: actualizar un emprendimiento existente.
class UpdateEmprendimiento implements UseCase<Emprendimiento, Emprendimiento> {
  const UpdateEmprendimiento(this._repository);

  final EmprendimientoRepository _repository;

  @override
  Future<Either<Failure, Emprendimiento>> call(Emprendimiento params) async {
    if (params.esNuevo) {
      return const Left(ValidationFailure('El emprendimiento no existe aún.'));
    }
    final error = validarEmprendimiento(params);
    if (error != null) return Left(error);
    return _repository.update(params);
  }
}
