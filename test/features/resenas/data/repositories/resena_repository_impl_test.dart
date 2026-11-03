import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/resenas/data/datasources/resena_mock_datasource.dart';
import 'package:vitrina_regional/features/resenas/data/datasources/resena_remote_datasource.dart';
import 'package:vitrina_regional/features/resenas/data/models/resena_model.dart';
import 'package:vitrina_regional/features/resenas/data/repositories/resena_repository_impl.dart';

import '../../../../helpers/fixtures.dart';

class MockResenaDataSourceMocktail extends Mock implements ResenaDataSource {}

void main() {
  setUpAll(
    () => registerFallbackValue(ResenaModel.fromEntity(Fixtures.resena)),
  );

  test('watchResenas emite Right con las entidades', () async {
    final dataSource = MockResenaDataSourceMocktail();
    when(() => dataSource.watchResenas('e1')).thenAnswer(
      (_) => Stream.value([ResenaModel.fromEntity(Fixtures.resena)]),
    );

    final primero = await ResenaRepositoryImpl(dataSource)
        .watchResenas('e1')
        .first;

    expect(primero.getRight().toNullable(), [Fixtures.resena]);
  });

  test('un error de permisos en el stream llega como Left', () async {
    final dataSource = MockResenaDataSourceMocktail();
    when(() => dataSource.watchResenas(any()))
        .thenAnswer((_) => Stream.error(const PermissionException()));

    final primero = await ResenaRepositoryImpl(dataSource)
        .watchResenas('e1')
        .first;

    expect(primero.getLeft().toNullable(), isA<PermissionFailure>());
  });

  test('addResena con ServerException devuelve ServerFailure', () async {
    final dataSource = MockResenaDataSourceMocktail();
    when(() => dataSource.addResena(any()))
        .thenThrow(const ServerException('caído'));

    final result = await ResenaRepositoryImpl(dataSource)
        .addResena(Fixtures.resena);

    expect(result, const Left<Failure, Unit>(ServerFailure('caído')));
  });

  test(
    'con el mock, una reseña nueva aparece en el stream (tiempo real)',
    () async {
      final dataSource = MockResenaDataSource(seed: const []);
      final repository = ResenaRepositoryImpl(dataSource);

      final emisiones = repository
          .watchResenas('e1')
          .map((r) => r.getRight().toNullable()?.length)
          .take(2)
          .toList();
      await Future<void>.delayed(Duration.zero);
      await repository.addResena(Fixtures.resena);

      expect(await emisiones, [0, 1]);
      await dataSource.dispose();
    },
  );
}
