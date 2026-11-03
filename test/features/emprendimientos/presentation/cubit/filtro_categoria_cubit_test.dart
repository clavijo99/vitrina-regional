import 'package:bloc_test/bloc_test.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/cubit/filtro_categoria_cubit.dart';

void main() {
  blocTest<FiltroCategoriaCubit, Categoria?>(
    'seleccionar dos veces la misma categoría quita el filtro',
    build: FiltroCategoriaCubit.new,
    act: (cubit) => cubit
      ..seleccionar(Categoria.moda)
      ..seleccionar(Categoria.moda),
    expect: () => const [Categoria.moda, null],
  );

  blocTest<FiltroCategoriaCubit, Categoria?>(
    'limpiar vuelve a null',
    build: () => FiltroCategoriaCubit(Categoria.agro),
    act: (cubit) => cubit.limpiar(),
    expect: () => const <Categoria?>[null],
  );
}
