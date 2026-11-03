import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';
import 'package:vitrina_regional/features/auth/domain/repositories/auth_repository.dart';

/// Implementación del contrato de domain.
///
/// Su trabajo: llamar al datasource, convertir modelos en entidades y
/// convertir EXCEPCIONES en FAILURES (`Left`). Nada de excepciones hacia arriba.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  Stream<AppUser?> watchAuthState() =>
      _dataSource.watchAuthState().map((model) => model?.toEntity());

  @override
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  }) => _guard(() async {
    final model = await _dataSource.signIn(email: email, password: password);
    return model.toEntity();
  });

  @override
  Future<Either<Failure, AppUser>> signUp({
    required String nombre,
    required String email,
    required String password,
    required UserRole rol,
  }) => _guard(() async {
    final model = await _dataSource.signUp(
      nombre: nombre,
      email: email,
      password: password,
      rol: rol,
    );
    return model.toEntity();
  });

  @override
  Future<Either<Failure, Unit>> signOut() => _guard(() async {
    await _dataSource.signOut();
    return unit;
  });

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on AuthException catch (e) {
      return Left(AuthFailure(mensajeParaCodigo(e.code)));
    } on PermissionException {
      return const Left(PermissionFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message ?? 'Error del servidor.'));
    } catch (_) {
      return const Left(UnexpectedFailure());
    }
  }

  /// Traduce los códigos de Firebase Auth a mensajes amigables en español.
  static String mensajeParaCodigo(String code) => switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'Correo o contraseña incorrectos.',
    'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
    'invalid-email' => 'El correo no es válido.',
    'weak-password' => 'La contraseña es muy débil (mínimo 6 caracteres).',
    'too-many-requests' => 'Demasiados intentos. Espera un momento.',
    'network-request-failed' => 'Sin conexión a internet.',
    _ => 'No se pudo completar la autenticación.',
  };
}
