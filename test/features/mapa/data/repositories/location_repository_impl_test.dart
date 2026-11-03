import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/ubicacion.dart';
import 'package:vitrina_regional/features/mapa/data/datasources/location_datasource.dart';
import 'package:vitrina_regional/features/mapa/data/repositories/location_repository_impl.dart';

class MockLocationDataSourceMocktail extends Mock
    implements LocationDataSource {}

void main() {
  late MockLocationDataSourceMocktail dataSource;
  late LocationRepositoryImpl repository;

  setUp(() {
    dataSource = MockLocationDataSourceMocktail();
    repository = LocationRepositoryImpl(dataSource);
  });

  test('devuelve la ubicación del datasource', () async {
    when(() => dataSource.getPosicionActual())
        .thenAnswer((_) async => Ubicacion.villavicencio);

    expect(
      await repository.getUbicacionActual(),
      const Right<Failure, Ubicacion>(Ubicacion.villavicencio),
    );
  });

  test('PermissionException -> PermissionFailure', () async {
    when(() => dataSource.getPosicionActual())
        .thenThrow(const PermissionException());

    final result = await repository.getUbicacionActual();

    expect(result.getLeft().toNullable(), isA<PermissionFailure>());
  });

  test('el datasource de geolocator aún no implementado -> LocationFailure '
      '(se completa en COIL-E2-1)', () async {
    const repo = LocationRepositoryImpl(GeolocatorLocationDataSource());

    final result = await repo.getUbicacionActual();

    expect(result.getLeft().toNullable(), isA<LocationFailure>());
  });
}
