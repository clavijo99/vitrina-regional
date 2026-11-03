import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';
import 'package:vitrina_regional/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: iniciar sesión con correo y contraseña.
class SignIn implements UseCase<AppUser, SignInParams> {
  const SignIn(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AppUser>> call(SignInParams params) =>
      _repository.signIn(email: params.email.trim(), password: params.password);
}

class SignInParams extends Equatable {
  const SignInParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
