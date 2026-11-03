import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/emprendimientos/data/datasources/emprendimiento_remote_datasource.dart';
import 'package:vitrina_regional/features/emprendimientos/data/models/emprendimiento_model.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/repositories/emprendimiento_repository.dart';

/// Implementación del repositorio: modelos -> entidades y
/// excepciones -> Failures.
class EmprendimientoRepositoryImpl implements EmprendimientoRepository {
  const EmprendimientoRepositoryImpl(this._dataSource);

  final EmprendimientoDataSource _dataSource;

  @override
  Future<Either<Failure, List<Emprendimiento>>> getEmprendimientos() =>
      _guard(() async {
        final modelos = await _dataSource.getAll();
        return modelos.map((m) => m.toEntity()).toList();
      });

  @override
  Future<Either<Failure, Emprendimiento>> getById(String id) =>
      _guard(() async => (await _dataSource.getById(id)).toEntity());

  @override
  Future<Either<Failure, Emprendimiento?>> getByOwner(String ownerId) =>
      _guard(() async => (await _dataSource.getByOwner(ownerId))?.toEntity());

  @override
  Future<Either<Failure, List<Emprendimiento>>> searchByCategoria(
    Categoria categoria,
  ) => _guard(() async {
    final modelos = await _dataSource.getByCategoria(categoria.name);
    return modelos.map((m) => m.toEntity()).toList();
  });

  @override
  Future<Either<Failure, Emprendimiento>> create(
    Emprendimiento emprendimiento,
  ) => _guard(() async {
    final creado = await _dataSource.create(
      EmprendimientoModel.fromEntity(emprendimiento),
    );
    return creado.toEntity();
  });

  @override
  Future<Either<Failure, Emprendimiento>> update(
    Emprendimiento emprendimiento,
  ) => _guard(() async {
    final actualizado = await _dataSource.update(
      EmprendimientoModel.fromEntity(emprendimiento),
    );
    return actualizado.toEntity();
  });

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on NotFoundException {
      return const Left(NotFoundFailure('El emprendimiento no existe.'));
    } on PermissionException {
      return const Left(PermissionFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
