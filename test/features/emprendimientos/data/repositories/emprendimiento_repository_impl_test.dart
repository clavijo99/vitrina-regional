import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/emprendimientos/data/datasources/emprendimiento_mock_datasource.dart';
import 'package:vitrina_regional/features/emprendimientos/data/datasources/emprendimiento_remote_datasource.dart';
import 'package:vitrina_regional/features/emprendimientos/data/models/emprendimiento_model.dart';
import 'package:vitrina_regional/features/emprendimientos/data/repositories/emprendimiento_repository_impl.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';

import '../../../../helpers/fixtures.dart';

class MockEmprendimientoDataSourceMocktail extends Mock
    implements EmprendimientoDataSource {}

void main() {
  group('con datasource simulado (mocktail)', () {
    late MockEmprendimientoDataSourceMocktail dataSource;
    late EmprendimientoRepositoryImpl repository;

    setUp(() {
      dataSource = MockEmprendimientoDataSourceMocktail();
      repository = EmprendimientoRepositoryImpl(dataSource);
    });

    test('getEmprendimientos convierte modelos en entidades', () async {
      when(() => dataSource.getAll()).thenAnswer(
        (_) async => [EmprendimientoModel.fromEntity(Fixtures.cafe)],
      );

      final result = await repository.getEmprendimientos();

      expect(result.getRight().toNullable(), [Fixtures.cafe]);
    });

    test('NotFoundException se convierte en NotFoundFailure', () async {
      when(() => dataSource.getById('x')).thenThrow(const NotFoundException());

      final result = await repository.getById('x');

      expect(
        result,
        const Left<Failure, Emprendimiento>(
          NotFoundFailure('El emprendimiento no existe.'),
        ),
      );
    });

    test('PermissionException se convierte en PermissionFailure', () async {
      when(() => dataSource.getAll()).thenThrow(const PermissionException());

      final result = await repository.getEmprendimientos();

      expect(result.getLeft().toNullable(), isA<PermissionFailure>());
    });
  });

  group('con MockEmprendimientoDataSource (datos de ejemplo)', () {
    late EmprendimientoRepositoryImpl repository;

    setUp(() {
      repository = EmprendimientoRepositoryImpl(
        MockEmprendimientoDataSource(latency: Duration.zero),
      );
    });

    test('trae los 6 emprendimientos de ejemplo', () async {
      final result = await repository.getEmprendimientos();
      expect(result.getRight().toNullable(), hasLength(6));
    });

    test('filtra por categoría', () async {
      final result = await repository.searchByCategoria(Categoria.gastronomia);
      final items = result.getRight().toNullable()!;
      expect(items, isNotEmpty);
      expect(items.every((e) => e.categoria == Categoria.gastronomia), isTrue);
    });

    test('create asigna id y luego getByOwner lo encuentra', () async {
      final nuevo = Fixtures.cafe.copyWith(id: '', ownerId: 'nuevo-owner');

      final creado = (await repository.create(nuevo)).getRight().toNullable()!;
      final delOwner = await repository.getByOwner('nuevo-owner');

      expect(creado.id, isNotEmpty);
      expect(creado.productos.first.id, isNotEmpty);
      expect(delOwner.getRight().toNullable()?.id, creado.id);
    });
  });
}
