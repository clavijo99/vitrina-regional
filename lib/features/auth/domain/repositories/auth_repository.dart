import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';

/// Contrato del repositorio de autenticación.
///
/// Domain define QUÉ se necesita; data decide CÓMO (Firebase o mock). Gracias a
/// esta interfaz podemos cambiar el backend sin tocar Blocs ni pantallas.
abstract interface class AuthRepository {
  /// Emite el usuario actual cada vez que cambia la sesión (o `null`).
  Stream<AppUser?> watchAuthState();

  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signUp({
    required String nombre,
    required String email,
    required String password,
    required UserRole rol,
  });

  Future<Either<Failure, Unit>> signOut();
}
