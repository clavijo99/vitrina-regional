import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/repositories/emprendimiento_repository.dart';

/// Caso de uso: obtener el detalle de un emprendimiento (con productos).
class GetEmprendimientoById implements UseCase<Emprendimiento, String> {
  const GetEmprendimientoById(this._repository);

  final EmprendimientoRepository _repository;

  @override
  Future<Either<Failure, Emprendimiento>> call(String id) =>
      _repository.getById(id);
}
