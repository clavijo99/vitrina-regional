import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/resenas/domain/entities/resena.dart';
import 'package:vitrina_regional/features/resenas/domain/repositories/resena_repository.dart';
import 'package:vitrina_regional/features/resenas/domain/usecases/add_resena.dart';

import '../../../../helpers/fixtures.dart';

class MockResenaRepository extends Mock implements ResenaRepository {}

void main() {
  late MockResenaRepository repository;

  setUpAll(() => registerFallbackValue(Fixtures.resena));

  setUp(() => repository = MockResenaRepository());

  Resena conEstrellas(int estrellas) => Resena(
    id: '',
    emprendimientoId: 'e1',
    autorId: 'u2',
    autorNombre: 'Carlos',
    estrellas: estrellas,
    comentario: 'ok',
    fecha: DateTime(2026),
  );

  test('rechaza 0 y 6 estrellas (igual que firestore.rules)', () async {
    final add = AddResena(repository);

    expect((await add(conEstrellas(0))).isLeft(), isTrue);
    expect((await add(conEstrellas(6))).isLeft(), isTrue);
    verifyNever(() => repository.addResena(any()));
  });

  test('acepta de 1 a 5 estrellas', () async {
    when(() => repository.addResena(any()))
        .thenAnswer((_) async => const Right(unit));

    final result = await AddResena(repository)(conEstrellas(5));

    expect(result, const Right<Failure, Unit>(unit));
  });
}
