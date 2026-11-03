import 'package:equatable/equatable.dart';

/// Reseña que un cliente deja sobre un emprendimiento.
class Resena extends Equatable {
  const Resena({
    required this.id,
    required this.emprendimientoId,
    required this.autorId,
    required this.autorNombre,
    required this.estrellas,
    required this.comentario,
    required this.fecha,
  });

  static const int minEstrellas = 1;
  static const int maxEstrellas = 5;
  static const int maxComentario = 500;

  final String id;
  final String emprendimientoId;
  final String autorId;
  final String autorNombre;

  /// Entre [minEstrellas] y [maxEstrellas].
  final int estrellas;
  final String comentario;
  final DateTime fecha;

  @override
  List<Object?> get props => [
    id,
    emprendimientoId,
    autorId,
    autorNombre,
    estrellas,
    comentario,
    fecha,
  ];
}
