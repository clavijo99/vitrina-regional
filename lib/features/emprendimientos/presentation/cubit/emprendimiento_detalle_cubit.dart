import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/get_emprendimiento_by_id.dart';

enum DetalleStatus { initial, loading, success, failure }

class EmprendimientoDetalleState extends Equatable {
  const EmprendimientoDetalleState({
    this.status = DetalleStatus.initial,
    this.emprendimiento,
    this.errorMessage,
  });

  final DetalleStatus status;
  final Emprendimiento? emprendimiento;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, emprendimiento, errorMessage];
}

/// Carga el detalle de un emprendimiento (pantalla de detalle).
class EmprendimientoDetalleCubit extends Cubit<EmprendimientoDetalleState> {
  EmprendimientoDetalleCubit(this._getById)
    : super(const EmprendimientoDetalleState());

  final GetEmprendimientoById _getById;

  Future<void> cargar(String id) async {
    emit(const EmprendimientoDetalleState(status: DetalleStatus.loading));
    final result = await _getById(id);
    emit(
      result.fold(
        (failure) => EmprendimientoDetalleState(
          status: DetalleStatus.failure,
          errorMessage: failure.message,
        ),
        (emprendimiento) => EmprendimientoDetalleState(
          status: DetalleStatus.success,
          emprendimiento: emprendimiento,
        ),
      ),
    );
  }
}
