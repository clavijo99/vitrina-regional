import 'package:equatable/equatable.dart';

/// Rol del usuario dentro de la app. Define qué rutas puede visitar.
enum UserRole {
  emprendedor('Emprendedor'),
  cliente('Cliente');

  const UserRole(this.label);

  final String label;

  /// Convierte el texto guardado en Firestore al enum (por defecto: cliente).
  static UserRole fromName(String? name) => UserRole.values.firstWhere(
    (rol) => rol.name == name,
    orElse: () => UserRole.cliente,
  );
}

/// Entidad de dominio: el usuario autenticado.
///
/// La capa domain es Dart puro: no conoce Flutter ni Firebase. Por eso esta
/// clase no tiene `fromFirestore`; eso vive en `data/models`.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  final String id;
  final String nombre;
  final String email;
  final UserRole rol;

  bool get esEmprendedor => rol == UserRole.emprendedor;
  bool get esCliente => rol == UserRole.cliente;

  @override
  List<Object?> get props => [id, nombre, email, rol];
}
