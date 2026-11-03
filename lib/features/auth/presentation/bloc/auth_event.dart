part of 'auth_bloc.dart';

/// Eventos: lo que la UI (o el sistema) le PIDE al AuthBloc.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Empieza a escuchar la sesión. Se envía una sola vez al crear el bloc.
final class AuthSubscriptionRequested extends AuthEvent {
  const AuthSubscriptionRequested();
}

final class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
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

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
