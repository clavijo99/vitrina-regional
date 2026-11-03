part of 'resenas_bloc.dart';

enum ResenasStatus { initial, loading, success, failure }

class ResenasState extends Equatable {
  const ResenasState({
    this.status = ResenasStatus.initial,
    this.envioStatus = ResenasStatus.initial,
    this.emprendimientoId = '',
    this.resenas = const [],
    this.errorMessage,
  });

  /// Estado de la suscripción (lista).
  final ResenasStatus status;

  /// Estado del envío de una reseña nueva.
  final ResenasStatus envioStatus;
  final String emprendimientoId;
  final List<Resena> resenas;
  final String? errorMessage;

  /// Promedio de estrellas (0 si no hay reseñas).
  double get promedio {
    if (resenas.isEmpty) return 0;
    final total = resenas.fold<int>(0, (suma, r) => suma + r.estrellas);
    return total / resenas.length;
  }

  // TODO(COIL-E3-3): Exponer `bool yaReseno(String userId)` y usarlo en la UI
  // para impedir que un mismo cliente reseñe dos veces.

  ResenasState copyWith({
    ResenasStatus? status,
    ResenasStatus? envioStatus,
    String? emprendimientoId,
    List<Resena>? resenas,
    String? errorMessage,
  }) {
    return ResenasState(
      status: status ?? this.status,
      envioStatus: envioStatus ?? this.envioStatus,
      emprendimientoId: emprendimientoId ?? this.emprendimientoId,
      resenas: resenas ?? this.resenas,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    envioStatus,
    emprendimientoId,
    resenas,
    errorMessage,
  ];
}
