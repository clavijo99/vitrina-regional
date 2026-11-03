import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/create_emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/get_emprendimiento_by_owner.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/update_emprendimiento.dart';

enum MiEmprendimientoStatus { initial, loading, success, failure }

class MiEmprendimientoState extends Equatable {
  const MiEmprendimientoState({
    this.loadStatus = MiEmprendimientoStatus.initial,
    this.saveStatus = MiEmprendimientoStatus.initial,
    this.emprendimiento,
    this.errorMessage,
  });

  /// Estado de la carga inicial.
  final MiEmprendimientoStatus loadStatus;

  /// Estado del último guardado (crear/actualizar).
  final MiEmprendimientoStatus saveStatus;

  /// `null` = el emprendedor aún no ha creado su emprendimiento.
  final Emprendimiento? emprendimiento;
  final String? errorMessage;

  bool get guardando => saveStatus == MiEmprendimientoStatus.loading;

  MiEmprendimientoState copyWith({
    MiEmprendimientoStatus? loadStatus,
    MiEmprendimientoStatus? saveStatus,
    Emprendimiento? emprendimiento,
    String? errorMessage,
  }) {
    return MiEmprendimientoState(
      loadStatus: loadStatus ?? this.loadStatus,
      saveStatus: saveStatus ?? this.saveStatus,
      emprendimiento: emprendimiento ?? this.emprendimiento,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    saveStatus,
    emprendimiento,
    errorMessage,
  ];
}

/// Cubit de "Mi emprendimiento": carga el emprendimiento del usuario y lo
/// crea o actualiza según corresponda.
class MiEmprendimientoCubit extends Cubit<MiEmprendimientoState> {
  MiEmprendimientoCubit({
    required this._getByOwner,
    required this._create,
    required this._update,
  }) : super(const MiEmprendimientoState());

  final GetEmprendimientoByOwner _getByOwner;
  final CreateEmprendimiento _create;
  final UpdateEmprendimiento _update;

  Future<void> cargar(String ownerId) async {
    emit(state.copyWith(loadStatus: MiEmprendimientoStatus.loading));
    final result = await _getByOwner(ownerId);
    emit(
      result.fold(
        (failure) => state.copyWith(
          loadStatus: MiEmprendimientoStatus.failure,
          errorMessage: failure.message,
        ),
        (emprendimiento) => MiEmprendimientoState(
          loadStatus: MiEmprendimientoStatus.success,
          emprendimiento: emprendimiento,
        ),
      ),
    );
  }

  // TODO(COIL-E1-6): Documenten en docs/ARQUITECTURA_EQUIPO.md (con un
  // diagrama de secuencia mermaid) el recorrido completo de `guardar()`:
  // EmprendimientoForm -> MiEmprendimientoCubit -> Create/UpdateEmprendimiento
  // -> validarEmprendimiento -> EmprendimientoRepositoryImpl -> DataSource.
  // Incluyan el camino de error (ValidationFailure / PermissionFailure).
  Future<void> guardar(Emprendimiento emprendimiento) async {
    emit(state.copyWith(saveStatus: MiEmprendimientoStatus.loading));
    final result = emprendimiento.esNuevo
        ? await _create(emprendimiento)
        : await _update(emprendimiento);
    emit(
      result.fold(
        (failure) => state.copyWith(
          saveStatus: MiEmprendimientoStatus.failure,
          errorMessage: failure.message,
        ),
        (guardado) => state.copyWith(
          saveStatus: MiEmprendimientoStatus.success,
          emprendimiento: guardado,
        ),
      ),
    );
  }
}
