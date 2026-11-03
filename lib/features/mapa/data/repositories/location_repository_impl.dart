import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/ubicacion.dart';
import 'package:vitrina_regional/features/mapa/data/datasources/location_datasource.dart';
import 'package:vitrina_regional/features/mapa/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl(this._dataSource);

  final LocationDataSource _dataSource;

  @override
  Future<Either<Failure, Ubicacion>> getUbicacionActual() async {
    try {
      return Right(await _dataSource.getPosicionActual());
    } on PermissionException {
      return const Left(
        PermissionFailure('Necesitamos permiso de ubicación para el mapa.'),
      );
    } on LocationException catch (e) {
      return Left(LocationFailure(e.message ?? 'No se pudo ubicar.'));
    } catch (_) {
      return const Left(LocationFailure());
    }
  }
}
