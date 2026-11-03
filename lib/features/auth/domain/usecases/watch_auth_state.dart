import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';
import 'package:vitrina_regional/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: escuchar los cambios de sesión (login, logout, app reiniciada).
class WatchAuthState implements StreamUseCase<AppUser?, NoParams> {
  const WatchAuthState(this._repository);

  final AuthRepository _repository;

  @override
  Stream<AppUser?> call(NoParams params) => _repository.watchAuthState();
}
