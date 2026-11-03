import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';

/// Contrato del repositorio de emprendimientos.
abstract interface class EmprendimientoRepository {
  Future<Either<Failure, List<Emprendimiento>>> getEmprendimientos();

  /// Incluye los productos (subcolección).
  Future<Either<Failure, Emprendimiento>> getById(String id);

  /// Emprendimiento del usuario indicado, o `null` si aún no tiene uno.
  Future<Either<Failure, Emprendimiento?>> getByOwner(String ownerId);

  Future<Either<Failure, List<Emprendimiento>>> searchByCategoria(
    Categoria categoria,
  );

  /// Devuelve el emprendimiento creado (con su nuevo id).
  Future<Either<Failure, Emprendimiento>> create(Emprendimiento emprendimiento);

  Future<Either<Failure, Emprendimiento>> update(Emprendimiento emprendimiento);
}
