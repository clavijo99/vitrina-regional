import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/repositories/emprendimiento_repository.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/create_emprendimiento.dart';

import '../../../../helpers/fixtures.dart';

class MockEmprendimientoRepository extends Mock
    implements EmprendimientoRepository {}

void main() {
  late MockEmprendimientoRepository repository;
  late CreateEmprendimiento create;

  setUpAll(() => registerFallbackValue(Fixtures.cafe));

  setUp(() {
    repository = MockEmprendimientoRepository();
    create = CreateEmprendimiento(repository);
  });

  test('rechaza un nombre muy corto sin llamar al repositorio', () async {
    final result = await create(Fixtures.cafe.copyWith(id: '', nombre: 'A'));

    expect(result.getLeft().toNullable(), isA<ValidationFailure>());
    verifyNever(() => repository.create(any()));
  });

  test('delega en el repositorio cuando los datos son válidos', () async {
    final nuevo = Fixtures.cafe.copyWith(id: '');
    when(() => repository.create(nuevo))
        .thenAnswer((_) async => const Right(Fixtures.cafe));

    final result = await create(nuevo);

    expect(result, const Right<Failure, Emprendimiento>(Fixtures.cafe));
  });
}
