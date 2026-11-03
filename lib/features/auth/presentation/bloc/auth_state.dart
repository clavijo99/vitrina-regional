part of 'auth_bloc.dart';

/// Estados del AuthBloc modelados con una clase sellada.
///
/// `sealed` obliga a que un `switch` cubra TODOS los casos: si mañana
/// agregamos un estado, el compilador nos dirá dónde falta manejarlo
/// (por ejemplo, en el redirect de go_router).
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Todavía no sabemos si hay sesión (la app acaba de abrir).
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Se está procesando login, registro o logout.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// La última operación falló. Para el router equivale a "sin sesión".
final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
