import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/ubicacion.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/get_emprendimientos.dart';
import 'package:vitrina_regional/features/mapa/domain/usecases/get_ubicacion_actual.dart';
import 'package:vitrina_regional/features/mapa/domain/usecases/ordenar_por_cercania.dart';
import 'package:vitrina_regional/features/mapa/presentation/cubit/mapa_cubit.dart';

import '../../../../helpers/fixtures.dart';

class MockGetUbicacionActual extends Mock implements GetUbicacionActual {}

class MockGetEmprendimientos extends Mock implements GetEmprendimientos {}

void main() {
  late MockGetUbicacionActual getUbicacion;
  late MockGetEmprendimientos getEmprendimientos;

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    getUbicacion = MockGetUbicacionActual();
    getEmprendimientos = MockGetEmprendimientos();
    when(() => getEmprendimientos(any()))
        .thenAnswer((_) async => const Right([Fixtures.cacao, Fixtures.cafe]));
  });

  MapaCubit buildCubit() => MapaCubit(
    getUbicacionActual: getUbicacion,
    getEmprendimientos: getEmprendimientos,
    ordenarPorCercania: const OrdenarPorCercania(),
  );

  blocTest<MapaCubit, MapaState>(
    'con ubicación: success y emprendimientos ordenados por cercanía',
    setUp: () =>
        when(() => getUbicacion(any()))
            .thenAnswer((_) async => const Right(Ubicacion.villavicencio)),
    build: buildCubit,
    act: (cubit) => cubit.cargar(),
    expect: () => [
      const MapaState(status: MapaStatus.loading),
      isA<MapaState>()
          .having((s) => s.status, 'status', MapaStatus.success)
          .having((s) => s.ubicacionUsuario, 'ubicación', isNotNull)
          .having(
            (s) => s.cercanos.map((c) => c.emprendimiento.id).toList(),
            'orden',
            ['e1', 'e2'],
          ),
    ],
  );

  blocTest<MapaCubit, MapaState>(
    'sin permiso de ubicación: usa Villavicencio y muestra un aviso',
    setUp: () => when(() => getUbicacion(any()))
        .thenAnswer((_) async => const Left(PermissionFailure('Sin permiso.'))),
    build: buildCubit,
    act: (cubit) => cubit.cargar(),
    expect: () => [
      const MapaState(status: MapaStatus.loading),
      isA<MapaState>()
          .having((s) => s.status, 'status', MapaStatus.success)
          .having((s) => s.ubicacionUsuario, 'ubicación', isNull)
          .having((s) => s.centro, 'centro', Ubicacion.villavicencio)
          .having((s) => s.aviso, 'aviso', contains('Sin permiso')),
    ],
  );
}
