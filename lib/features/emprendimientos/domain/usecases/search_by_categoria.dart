import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/repositories/emprendimiento_repository.dart';

/// Caso de uso: filtrar emprendimientos por categoría.
class SearchByCategoria implements UseCase<List<Emprendimiento>, Categoria> {
  const SearchByCategoria(this._repository);

  final EmprendimientoRepository _repository;

  @override
  Future<Either<Failure, List<Emprendimiento>>> call(Categoria categoria) =>
      _repository.searchByCategoria(categoria);
}
