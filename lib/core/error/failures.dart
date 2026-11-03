import 'package:equatable/equatable.dart';

/// Un [Failure] es un error "de negocio" que viaja por el lado izquierdo de
/// `Either<Failure, T>`.
///
/// ¿Por qué no usar excepciones en todas partes? Porque así la capa de
/// presentación nunca conoce los detalles de Firebase: solo recibe un
/// Failure con un mensaje listo para mostrar, y el compilador nos obliga a
/// manejar el caso de error con `fold`.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Error del backend (Firestore, Storage, red...).
final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Error del servidor. Intenta de nuevo.',
  ]);
}

/// Error de autenticación (credenciales inválidas, correo en uso...).
final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'No se pudo autenticar.']);
}

/// El usuario no tiene permiso (reglas de Firestore, permisos del sistema).
final class PermissionFailure extends Failure {
  const PermissionFailure([
    super.message = 'No tienes permiso para realizar esta acción.',
  ]);
}

/// El recurso solicitado no existe.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'No encontramos lo que buscabas.']);
}

/// Los datos no cumplen una regla de negocio (validada en domain).
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// No fue posible obtener la ubicación del dispositivo.
final class LocationFailure extends Failure {
  const LocationFailure([super.message = 'No se pudo obtener tu ubicación.']);
}

/// Cualquier error no previsto.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Ocurrió un error inesperado.']);
}
