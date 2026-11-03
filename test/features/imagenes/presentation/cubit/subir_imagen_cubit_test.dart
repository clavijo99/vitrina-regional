import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/imagenes/domain/entities/imagen_seleccionada.dart';
import 'package:vitrina_regional/features/imagenes/domain/usecases/seleccionar_imagen.dart';
import 'package:vitrina_regional/features/imagenes/domain/usecases/subir_imagen.dart';
import 'package:vitrina_regional/features/imagenes/presentation/cubit/subir_imagen_cubit.dart';

class MockSeleccionarImagen extends Mock implements SeleccionarImagen {}

class MockSubirImagen extends Mock implements SubirImagen {}

void main() {
  late MockSeleccionarImagen seleccionar;
  late MockSubirImagen subir;

  final imagen = ImagenSeleccionada(
    bytes: Uint8List.fromList([1, 2, 3]),
    nombre: 'foto.jpg',
  );

  setUpAll(() {
    registerFallbackValue(FuenteImagen.galeria);
    registerFallbackValue(SubirImagenParams(imagen: imagen, carpeta: ''));
  });

  setUp(() {
    seleccionar = MockSeleccionarImagen();
    subir = MockSubirImagen();
  });

  SubirImagenCubit buildCubit() =>
      SubirImagenCubit(seleccionar: seleccionar, subir: subir);

  blocTest<SubirImagenCubit, SubirImagenState>(
    'seleccionar y subir con éxito emite [loading, success(url)]',
    setUp: () {
      when(() => seleccionar(any())).thenAnswer((_) async => Right(imagen));
      when(() => subir(any()))
          .thenAnswer((_) async => const Right('https://img/1.jpg'));
    },
    build: buildCubit,
    act: (cubit) =>
        cubit.seleccionarYSubir(fuente: FuenteImagen.galeria, carpeta: 'e1'),
    expect: () => const [
      SubirImagenState(status: SubirImagenStatus.loading),
      SubirImagenState(
        status: SubirImagenStatus.success,
        url: 'https://img/1.jpg',
      ),
    ],
  );

  blocTest<SubirImagenCubit, SubirImagenState>(
    'si el usuario cancela no emite nada ni sube',
    setUp: () =>
        when(() => seleccionar(any()))
            .thenAnswer((_) async => const Right(null)),
    build: buildCubit,
    act: (cubit) =>
        cubit.seleccionarYSubir(fuente: FuenteImagen.camara, carpeta: 'e1'),
    expect: () => const <SubirImagenState>[],
    verify: (_) => verifyNever(() => subir(any())),
  );

  blocTest<SubirImagenCubit, SubirImagenState>(
    'un fallo al subir emite failure con el mensaje',
    setUp: () {
      when(() => seleccionar(any())).thenAnswer((_) async => Right(imagen));
      when(() => subir(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Pendiente E4')));
    },
    build: buildCubit,
    act: (cubit) =>
        cubit.seleccionarYSubir(fuente: FuenteImagen.galeria, carpeta: 'e1'),
    expect: () => const [
      SubirImagenState(status: SubirImagenStatus.loading),
      SubirImagenState(
        status: SubirImagenStatus.failure,
        errorMessage: 'Pendiente E4',
      ),
    ],
  );
}
