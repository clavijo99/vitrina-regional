import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';
import 'package:vitrina_regional/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: registrar un usuario nuevo con su rol.
///
/// Las reglas de negocio puras (nombre mínimo) viven aquí, en domain, y no
/// dependen de la UI: así se cumplen también si mañana creamos otra pantalla.
class SignUp implements UseCase<AppUser, SignUpParams> {
  const SignUp(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(SignUpParams params) async {
    if (params.nombre.trim().length < 3) {
      return const Left(
        ValidationFailure('El nombre debe tener al menos 3 caracteres.'),
      );
    }
    return _repository.signUp(
      nombre: params.nombre.trim(),
      email: params.email.trim(),
      password: params.password,
      rol: params.rol,
    );
  }
}

class SignUpParams extends Equatable {
  const SignUpParams({
    required this.nombre,
    required this.email,
    required this.password,
    required this.rol,
  });

  final String nombre;
  final String email;
  final String password;
  final UserRole rol;

  @override
  List<Object?> get props => [nombre, email, password, rol];
}
