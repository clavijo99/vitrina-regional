/// Excepciones de la capa **data**.
///
/// Los datasources lanzan estas excepciones (traduciendo las de Firebase) y los
/// repositorios las capturan y las convierten en `Failure`. Nunca deben llegar
/// a la capa de presentación.
class ServerException implements Exception {
  const ServerException([this.message]);

  final String? message;

  @override
  String toString() => 'ServerException($message)';
}

class AuthException implements Exception {
  const AuthException(this.code, [this.message]);

  /// Código de error (por ejemplo, los de `FirebaseAuthException.code`).
  final String code;
  final String? message;

  @override
  String toString() => 'AuthException($code, $message)';
}

class PermissionException implements Exception {
  const PermissionException([this.message]);

  final String? message;

  @override
  String toString() => 'PermissionException($message)';
}

class NotFoundException implements Exception {
  const NotFoundException([this.message]);

  final String? message;

  @override
  String toString() => 'NotFoundException($message)';
}

class LocationException implements Exception {
  const LocationException([this.message]);

  final String? message;

  @override
  String toString() => 'LocationException($message)';
}
