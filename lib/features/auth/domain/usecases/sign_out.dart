import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: cerrar la sesión actual.
class SignOut implements UseCase<Unit, NoParams> {
  const SignOut(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) => _repository.signOut();
}
