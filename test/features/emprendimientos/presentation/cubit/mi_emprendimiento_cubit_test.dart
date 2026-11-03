import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/create_emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/get_emprendimiento_by_owner.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/update_emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/cubit/mi_emprendimiento_cubit.dart';

import '../../../../helpers/fixtures.dart';

class MockGetByOwner extends Mock implements GetEmprendimientoByOwner {}

class MockCreate extends Mock implements CreateEmprendimiento {}

class MockUpdate extends Mock implements UpdateEmprendimiento {}

void main() {
  late MockGetByOwner getByOwner;
  late MockCreate create;
  late MockUpdate update;

  setUpAll(() => registerFallbackValue(Fixtures.cafe));

  setUp(() {
    getByOwner = MockGetByOwner();
    create = MockCreate();
    update = MockUpdate();
  });

  MiEmprendimientoCubit buildCubit() => MiEmprendimientoCubit(
    getByOwner: getByOwner,
    create: create,
    update: update,
  );

  blocTest<MiEmprendimientoCubit, MiEmprendimientoState>(
    'cargar sin emprendimiento deja el formulario vacío',
    setUp: () =>
        when(() => getByOwner('u1')).thenAnswer((_) async => const Right(null)),
    build: buildCubit,
    act: (cubit) => cubit.cargar('u1'),
    expect: () => const [
      MiEmprendimientoState(loadStatus: MiEmprendimientoStatus.loading),
      MiEmprendimientoState(loadStatus: MiEmprendimientoStatus.success),
    ],
  );

  blocTest<MiEmprendimientoCubit, MiEmprendimientoState>(
    'guardar uno nuevo usa CreateEmprendimiento',
    setUp: () =>
        when(() => create(any()))
            .thenAnswer((_) async => const Right(Fixtures.cafe)),
    build: buildCubit,
    act: (cubit) => cubit.guardar(Fixtures.cafe.copyWith(id: '')),
    expect: () => const [
      MiEmprendimientoState(saveStatus: MiEmprendimientoStatus.loading),
      MiEmprendimientoState(
        saveStatus: MiEmprendimientoStatus.success,
        emprendimiento: Fixtures.cafe,
      ),
    ],
    verify: (_) => verifyNever(() => update(any())),
  );
}
