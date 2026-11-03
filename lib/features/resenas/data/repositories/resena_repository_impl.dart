import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/resenas/data/datasources/resena_remote_datasource.dart';
import 'package:vitrina_regional/features/resenas/data/models/resena_model.dart';
import 'package:vitrina_regional/features/resenas/domain/entities/resena.dart';
import 'package:vitrina_regional/features/resenas/domain/repositories/resena_repository.dart';

class ResenaRepositoryImpl implements ResenaRepository {
  const ResenaRepositoryImpl(this._dataSource);

  final ResenaDataSource _dataSource;

  /// Convierte cada lista en `Right` y cada error del stream en `Left`, así
  /// el stream NUNCA se rompe por un error: el Bloc decide qué mostrar.
  @override
  Stream<Either<Failure, List<Resena>>> watchResenas(
    String emprendimientoId,
  ) async* {
    try {
      await for (final modelos in _dataSource.watchResenas(emprendimientoId)) {
        yield Right(modelos.map((m) => m.toEntity()).toList());
      }
    } on PermissionException {
      yield const Left(PermissionFailure());
    } on ServerException catch (e) {
      yield Left(ServerFailure(e.message ?? 'Error del servidor.'));
    } catch (_) {
      yield const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> addResena(Resena resena) async {
    try {
      await _dataSource.addResena(ResenaModel.fromEntity(resena));
      return const Right(unit);
    } on PermissionException {
      return const Left(
        PermissionFailure('No tienes permiso para publicar esta reseña.'),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }
}
