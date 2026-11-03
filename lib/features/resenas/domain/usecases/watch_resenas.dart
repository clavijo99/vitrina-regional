import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/resenas/domain/entities/resena.dart';
import 'package:vitrina_regional/features/resenas/domain/repositories/resena_repository.dart';

/// Caso de uso: escuchar en tiempo real las reseñas de un emprendimiento.
class WatchResenas
    implements StreamUseCase<Either<Failure, List<Resena>>, String> {
  const WatchResenas(this._repository);

  final ResenaRepository _repository;

  @override
  Stream<Either<Failure, List<Resena>>> call(String emprendimientoId) =>
      _repository.watchResenas(emprendimientoId);
}
