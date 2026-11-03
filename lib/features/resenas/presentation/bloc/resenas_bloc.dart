import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/resenas/domain/entities/resena.dart';
import 'package:vitrina_regional/features/resenas/domain/usecases/add_resena.dart';
import 'package:vitrina_regional/features/resenas/domain/usecases/watch_resenas.dart';

part 'resenas_event.dart';
part 'resenas_state.dart';

/// Bloc de reseñas en TIEMPO REAL de un emprendimiento.
///
/// Usa `emit.forEach` sobre el stream del caso de uso: cada snapshot de
/// Firestore (o del mock) se convierte en un nuevo estado. Se crea en la
/// página de detalle, así que se cierra (y cancela el stream) al salir.
class ResenasBloc extends Bloc<ResenasEvent, ResenasState> {
  ResenasBloc({required this._watchResenas, required this._addResena})
    : super(const ResenasState()) {
    on<ResenasSubscriptionRequested>(_onSubscriptionRequested);
    on<ResenaAgregada>(_onResenaAgregada);
  }

  final WatchResenas _watchResenas;
  final AddResena _addResena;

  Future<void> _onSubscriptionRequested(
    ResenasSubscriptionRequested event,
    Emitter<ResenasState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ResenasStatus.loading,
        emprendimientoId: event.emprendimientoId,
      ),
    );
    await emit.forEach<Either<Failure, List<Resena>>>(
      _watchResenas(event.emprendimientoId),
      onData: (result) => result.fold(
        (failure) => state.copyWith(
          status: ResenasStatus.failure,
          errorMessage: failure.message,
        ),
        (resenas) =>
            state.copyWith(status: ResenasStatus.success, resenas: resenas),
      ),
    );
  }

  Future<void> _onResenaAgregada(
    ResenaAgregada event,
    Emitter<ResenasState> emit,
  ) async {
    emit(state.copyWith(envioStatus: ResenasStatus.loading));
    final result = await _addResena(
      Resena(
        id: '',
        emprendimientoId: state.emprendimientoId,
        autorId: event.autorId,
        autorNombre: event.autorNombre,
        estrellas: event.estrellas,
        comentario: event.comentario.trim(),
        fecha: DateTime.now(),
      ),
    );
    // No agregamos la reseña a la lista a mano: llegará sola por el stream.
    emit(
      result.fold(
        (failure) => state.copyWith(
          envioStatus: ResenasStatus.failure,
          errorMessage: failure.message,
        ),
        (_) => state.copyWith(envioStatus: ResenasStatus.success),
      ),
    );
  }

  // TODO(COIL-E3-5): Agregar un evento `ResenasOrdenCambiado` para ordenar la
  // lista por "más recientes" o "mejor calificadas" sin volver a consultar.
}
