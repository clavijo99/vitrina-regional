import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';
import 'package:vitrina_regional/features/auth/domain/usecases/sign_in.dart';
import 'package:vitrina_regional/features/auth/domain/usecases/sign_out.dart';
import 'package:vitrina_regional/features/auth/domain/usecases/sign_up.dart';
import 'package:vitrina_regional/features/auth/domain/usecases/watch_auth_state.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Bloc global de sesión.
///
/// Usamos **Bloc** (no Cubit) porque la sesión tiene varios flujos disparados
/// por eventos distintos y queremos trazabilidad de cada uno. Recibe CASOS DE
/// USO por constructor: nunca repositorios ni Firebase.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // `required this._signIn` se invoca como `signIn:` (parámetros nombrados
  // privados, Dart 3.12+).
  AuthBloc({
    required this._watchAuthState,
    required this._signIn,
    required this._signUp,
    required this._signOut,
  }) : super(const AuthInitial()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final WatchAuthState _watchAuthState;
  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;

  /// `emit.forEach` escucha el stream mientras el bloc viva y cancela la
  /// suscripción automáticamente al cerrarlo. No hace falta guardar
  /// StreamSubscription a mano.
  Future<void> _onSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) {
    return emit.forEach<AppUser?>(
      _watchAuthState(const NoParams()),
      onData: (user) =>
          user == null ? const AuthUnauthenticated() : AuthAuthenticated(user),
      onError: (_, _) => const AuthUnauthenticated(),
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signIn(
      SignInParams(email: event.email, password: event.password),
    );
    emit(
      result.fold(
        (failure) => AuthError(failure.message),
        AuthAuthenticated.new,
      ),
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signUp(
      SignUpParams(
        nombre: event.nombre,
        email: event.email,
        password: event.password,
        rol: event.rol,
      ),
    );
    emit(
      result.fold(
        (failure) => AuthError(failure.message),
        AuthAuthenticated.new,
      ),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signOut(const NoParams());
    emit(
      result.fold(
        (failure) => AuthError(failure.message),
        (_) => const AuthUnauthenticated(),
      ),
    );
  }
}
