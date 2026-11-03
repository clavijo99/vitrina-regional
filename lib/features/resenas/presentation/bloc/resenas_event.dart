part of 'resenas_bloc.dart';

sealed class ResenasEvent extends Equatable {
  const ResenasEvent();

  @override
  List<Object?> get props => [];
}

/// Empieza a escuchar las reseñas de un emprendimiento.
final class ResenasSubscriptionRequested extends ResenasEvent {
  const ResenasSubscriptionRequested(this.emprendimientoId);

  final String emprendimientoId;

  @override
  List<Object?> get props => [emprendimientoId];
}

/// El usuario envía una reseña nueva.
final class ResenaAgregada extends ResenasEvent {
  const ResenaAgregada({
    required this.autorId,
    required this.autorNombre,
    required this.estrellas,
    required this.comentario,
  });

  final String autorId;
  final String autorNombre;
  final int estrellas;
  final String comentario;

  @override
  List<Object?> get props => [autorId, autorNombre, estrellas, comentario];
}
