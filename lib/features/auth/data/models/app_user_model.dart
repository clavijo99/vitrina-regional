import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';

/// Modelo de la capa data: sabe convertirse desde/hacia Firestore.
///
/// Separamos modelo y entidad para que domain no dependa del formato de la
/// base de datos. El repositorio convierte el modelo con [toEntity].
class AppUserModel extends Equatable {
  const AppUserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  factory AppUserModel.fromMap(String id, Map<String, dynamic> map) {
    return AppUserModel(
      id: id,
      nombre: map['nombre'] as String? ?? '',
      email: map['email'] as String? ?? '',
      rol: UserRole.fromName(map['rol'] as String?),
    );
  }

  factory AppUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) => AppUserModel.fromMap(doc.id, doc.data() ?? const {});

  factory AppUserModel.fromEntity(AppUser user) => AppUserModel(
    id: user.id,
    nombre: user.nombre,
    email: user.email,
    rol: user.rol,
  );

  final String id;
  final String nombre;
  final String email;
  final UserRole rol;

  /// Documento `users/{uid}`. El id no se guarda: es el id del documento.
  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'email': email,
    'rol': rol.name,
  };

  AppUser toEntity() => AppUser(id: id, nombre: nombre, email: email, rol: rol);

  @override
  List<Object?> get props => [id, nombre, email, rol];
}
