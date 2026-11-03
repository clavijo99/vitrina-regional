import 'package:equatable/equatable.dart';

/// Producto o servicio que ofrece un emprendimiento.
/// En Firestore vive en la subcolección `emprendimientos/{id}/productos`.
class Producto extends Equatable {
  const Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    this.descripcion = '',
    this.fotoUrl,
  });

  final String id;
  final String nombre;
  final double precio;
  final String descripcion;
  final String? fotoUrl;

  @override
  List<Object?> get props => [id, nombre, precio, descripcion, fotoUrl];
}
