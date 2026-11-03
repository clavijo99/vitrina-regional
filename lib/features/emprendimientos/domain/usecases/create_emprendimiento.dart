import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/repositories/emprendimiento_repository.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/validar_emprendimiento.dart';

/// Caso de uso: crear un emprendimiento (valida antes de guardar).
class CreateEmprendimiento implements UseCase<Emprendimiento, Emprendimiento> {
  const CreateEmprendimiento(this._repository);

  final EmprendimientoRepository _repository;

  @override
  Future<Either<Failure, Emprendimiento>> call(Emprendimiento params) async {
    final error = validarEmprendimiento(params);
    if (error != null) return Left(error);
    return _repository.create(params);
  }
}
