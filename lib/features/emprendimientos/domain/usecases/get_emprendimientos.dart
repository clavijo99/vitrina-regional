import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/repositories/emprendimiento_repository.dart';

/// Caso de uso: listar todos los emprendimientos.
class GetEmprendimientos implements UseCase<List<Emprendimiento>, NoParams> {
  const GetEmprendimientos(this._repository);

  final EmprendimientoRepository _repository;

  @override
  Future<Either<Failure, List<Emprendimiento>>> call(NoParams params) =>
      _repository.getEmprendimientos();
}
