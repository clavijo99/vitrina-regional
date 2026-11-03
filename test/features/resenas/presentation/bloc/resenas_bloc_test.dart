import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/resenas/domain/entities/resena.dart';
import 'package:vitrina_regional/features/resenas/domain/usecases/add_resena.dart';
import 'package:vitrina_regional/features/resenas/domain/usecases/watch_resenas.dart';
import 'package:vitrina_regional/features/resenas/presentation/bloc/resenas_bloc.dart';

import '../../../../helpers/fixtures.dart';

class MockWatchResenas extends Mock implements WatchResenas {}

class MockAddResena extends Mock implements AddResena {}

void main() {
  late MockWatchResenas watchResenas;
  late MockAddResena addResena;

  setUpAll(() => registerFallbackValue(Fixtures.resena));

  setUp(() {
    watchResenas = MockWatchResenas();
    addResena = MockAddResena();
  });

  ResenasBloc buildBloc() =>
      ResenasBloc(watchResenas: watchResenas, addResena: addResena);

  blocTest<ResenasBloc, ResenasState>(
    'cada emisión del stream produce un estado nuevo (emit.forEach)',
    setUp: () => when(() => watchResenas('e1')).thenAnswer(
      (_) => Stream.fromIterable([
        const Right<Failure, List<Resena>>([]),
        Right<Failure, List<Resena>>([Fixtures.resena]),
      ]),
    ),
    build: buildBloc,
    act: (bloc) => bloc.add(const ResenasSubscriptionRequested('e1')),
    expect: () => [
      const ResenasState(status: ResenasStatus.loading, emprendimientoId: 'e1'),
      const ResenasState(status: ResenasStatus.success, emprendimientoId: 'e1'),
      ResenasState(
        status: ResenasStatus.success,
        emprendimientoId: 'e1',
        resenas: [Fixtures.resena],
      ),
    ],
  );

  blocTest<ResenasBloc, ResenasState>(
    'ResenaAgregada exitosa emite envío [loading, success]',
    setUp: () =>
        when(() => addResena(any())).thenAnswer((_) async => const Right(unit)),
    build: buildBloc,
    seed: () => const ResenasState(emprendimientoId: 'e1'),
    act: (bloc) => bloc.add(
      const ResenaAgregada(
        autorId: 'u2',
        autorNombre: 'Carlos',
        estrellas: 4,
        comentario: '  Muy bueno  ',
      ),
    ),
    expect: () => const [
      ResenasState(emprendimientoId: 'e1', envioStatus: ResenasStatus.loading),
      ResenasState(emprendimientoId: 'e1', envioStatus: ResenasStatus.success),
    ],
    verify: (_) {
      final enviada =
          verify(() => addResena(captureAny())).captured.single as Resena;
      expect(enviada.comentario, 'Muy bueno');
      expect(enviada.emprendimientoId, 'e1');
    },
  );

  test('promedio de estrellas', () {
    final state = ResenasState(
      resenas: [
        Fixtures.resena,
        Resena(
          id: 'r2',
          emprendimientoId: 'e1',
          autorId: 'u9',
          autorNombre: 'Ana',
          estrellas: 2,
          comentario: '',
          fecha: DateTime(2026),
        ),
      ],
    );
    expect(state.promedio, 3.5);
  });
}
