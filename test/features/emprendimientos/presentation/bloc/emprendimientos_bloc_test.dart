import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/get_emprendimientos.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/search_by_categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/bloc/emprendimientos_bloc.dart';

import '../../../../helpers/fixtures.dart';

class MockGetEmprendimientos extends Mock implements GetEmprendimientos {}

class MockSearchByCategoria extends Mock implements SearchByCategoria {}

void main() {
  late MockGetEmprendimientos getEmprendimientos;
  late MockSearchByCategoria searchByCategoria;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(Categoria.agro);
  });

  setUp(() {
    getEmprendimientos = MockGetEmprendimientos();
    searchByCategoria = MockSearchByCategoria();
  });

  EmprendimientosBloc buildBloc() => EmprendimientosBloc(
    getEmprendimientos: getEmprendimientos,
    searchByCategoria: searchByCategoria,
  );

  blocTest<EmprendimientosBloc, EmprendimientosState>(
    'EmprendimientosRequested emite [loading, success] con los datos',
    setUp: () => when(() => getEmprendimientos(any()))
        .thenAnswer((_) async => const Right([Fixtures.cafe, Fixtures.cacao])),
    build: buildBloc,
    act: (bloc) => bloc.add(const EmprendimientosRequested()),
    expect: () => const [
      EmprendimientosState(status: EmprendimientosStatus.loading),
      EmprendimientosState(
        status: EmprendimientosStatus.success,
        items: [Fixtures.cafe, Fixtures.cacao],
      ),
    ],
  );

  blocTest<EmprendimientosBloc, EmprendimientosState>(
    'filtrar por categoría usa SearchByCategoria',
    setUp: () =>
        when(() => searchByCategoria(Categoria.agro))
            .thenAnswer((_) async => const Right([Fixtures.cacao])),
    build: buildBloc,
    act: (bloc) =>
        bloc.add(const EmprendimientosCategoriaFiltrada(Categoria.agro)),
    expect: () => const [
      EmprendimientosState(
        status: EmprendimientosStatus.loading,
        categoria: Categoria.agro,
      ),
      EmprendimientosState(
        status: EmprendimientosStatus.success,
        categoria: Categoria.agro,
        items: [Fixtures.cacao],
      ),
    ],
    verify: (_) => verifyNever(() => getEmprendimientos(any())),
  );

  blocTest<EmprendimientosBloc, EmprendimientosState>(
    'un Failure emite status failure con el mensaje',
    setUp: () =>
        when(() => getEmprendimientos(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Sin conexión'))),
    build: buildBloc,
    act: (bloc) => bloc.add(const EmprendimientosRequested()),
    expect: () => const [
      EmprendimientosState(status: EmprendimientosStatus.loading),
      EmprendimientosState(
        status: EmprendimientosStatus.failure,
        errorMessage: 'Sin conexión',
      ),
    ],
  );
}
