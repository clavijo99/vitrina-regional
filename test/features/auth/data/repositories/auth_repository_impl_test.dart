import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:vitrina_regional/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:vitrina_regional/features/auth/data/models/app_user_model.dart';
import 'package:vitrina_regional/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';

class MockAuthDataSourceMocktail extends Mock implements AuthDataSource {}

void main() {
  late MockAuthDataSourceMocktail dataSource;
  late AuthRepositoryImpl repository;

  const model = AppUserModel(
    id: 'u1',
    nombre: 'Laura',
    email: 'laura@test.com',
    rol: UserRole.emprendedor,
  );

  setUp(() {
    dataSource = MockAuthDataSourceMocktail();
    repository = AuthRepositoryImpl(dataSource);
  });

  group('signIn', () {
    test('devuelve Right(AppUser) cuando el datasource responde', () async {
      when(() => dataSource.signIn(email: 'laura@test.com', password: '123456'))
          .thenAnswer((_) async => model);

      final result = await repository.signIn(
        email: 'laura@test.com',
        password: '123456',
      );

      expect(result, Right<Failure, AppUser>(model.toEntity()));
    });

    test(
      'convierte AuthException en AuthFailure con mensaje en español',
      () async {
        when(
          () => dataSource.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const AuthException('invalid-credential'));

        final result = await repository.signIn(
          email: 'x@y.co',
          password: 'bad',
        );

        expect(
          result,
          const Left<Failure, AppUser>(
            AuthFailure('Correo o contraseña incorrectos.'),
          ),
        );
      },
    );

    test('convierte ServerException en ServerFailure', () async {
      when(
        () => dataSource.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const ServerException('caído'));

      final result = await repository.signIn(email: 'x@y.co', password: '1');

      expect(result, const Left<Failure, AppUser>(ServerFailure('caído')));
    });
  });

  group('con MockAuthDataSource (modo demo)', () {
    test('login con usuario demo y luego signOut emite null', () async {
      final repo = AuthRepositoryImpl(
        MockAuthDataSource(latency: Duration.zero),
      );

      final login = await repo.signIn(
        email: 'cliente@demo.com',
        password: '123456',
      );
      expect(login.isRight(), isTrue);

      final emitted = <AppUser?>[];
      final sub = repo.watchAuthState().listen(emitted.add);
      await repo.signOut();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emitted.first?.email, 'cliente@demo.com');
      expect(emitted.last, isNull);
    });

    test('registrar un correo existente devuelve AuthFailure', () async {
      final repo = AuthRepositoryImpl(
        MockAuthDataSource(latency: Duration.zero),
      );

      final result = await repo.signUp(
        nombre: 'Otro',
        email: 'cliente@demo.com',
        password: '123456',
        rol: UserRole.cliente,
      );

      expect(
        result,
        const Left<Failure, AppUser>(
          AuthFailure('Ya existe una cuenta con ese correo.'),
        ),
      );
    });
  });
}
