import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/imagenes/data/datasources/imagen_picker_datasource.dart';
import 'package:vitrina_regional/features/imagenes/data/datasources/imagen_storage_datasource.dart';
import 'package:vitrina_regional/features/imagenes/data/repositories/imagen_repository_impl.dart';
import 'package:vitrina_regional/features/imagenes/domain/entities/imagen_seleccionada.dart';

class MockPicker extends Mock implements ImagenPickerDataSource {}

class MockStorage extends Mock implements ImagenStorageDataSource {}

void main() {
  late MockPicker picker;
  late MockStorage storage;
  late ImagenRepositoryImpl repository;

  final imagen = ImagenSeleccionada(
    bytes: Uint8List.fromList([1, 2, 3]),
    nombre: 'foto.jpg',
  );

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    picker = MockPicker();
    storage = MockStorage();
    repository = ImagenRepositoryImpl(picker: picker, storage: storage);
  });

  test('subir devuelve la URL del storage', () async {
    when(
      () => storage.subir(
        bytes: any(named: 'bytes'),
        carpeta: 'emprendimientos/e1',
        nombre: 'foto.jpg',
      ),
    ).thenAnswer((_) async => 'https://img/1.jpg');

    final result = await repository.subir(
      imagen: imagen,
      carpeta: 'emprendimientos/e1',
    );

    expect(result, const Right<Failure, String>('https://img/1.jpg'));
  });

  test('PermissionException -> PermissionFailure', () async {
    when(
      () => storage.subir(
        bytes: any(named: 'bytes'),
        carpeta: any(named: 'carpeta'),
        nombre: any(named: 'nombre'),
      ),
    ).thenThrow(const PermissionException());

    final result = await repository.subir(imagen: imagen, carpeta: 'x');

    expect(result.getLeft().toNullable(), isA<PermissionFailure>());
  });

  test('seleccionar cancelado devuelve Right(null)', () async {
    when(() => picker.seleccionar(FuenteImagen.galeria))
        .thenAnswer((_) async => null);

    final result = await repository.seleccionar(FuenteImagen.galeria);

    expect(result, const Right<Failure, ImagenSeleccionada?>(null));
  });
}
