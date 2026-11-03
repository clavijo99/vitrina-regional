import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/get_emprendimientos.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/search_by_categoria.dart';

part 'emprendimientos_event.dart';
part 'emprendimientos_state.dart';

/// Bloc del listado de emprendimientos (pantalla Home).
///
/// Estado modelado con enum de status + Equatable (alternativa a las clases
/// selladas usadas en AuthBloc): útil cuando queremos conservar los datos
/// anteriores mientras cargamos (por ejemplo, la categoría seleccionada).
class EmprendimientosBloc
    extends Bloc<EmprendimientosEvent, EmprendimientosState> {
  EmprendimientosBloc({
    required this._getEmprendimientos,
    required this._searchByCategoria,
  }) : super(const EmprendimientosState()) {
    on<EmprendimientosRequested>(_onRequested);
    on<EmprendimientosCategoriaFiltrada>(_onCategoriaFiltrada);
  }

  final GetEmprendimientos _getEmprendimientos;
  final SearchByCategoria _searchByCategoria;

  Future<void> _onRequested(
    EmprendimientosRequested event,
    Emitter<EmprendimientosState> emit,
  ) => _cargar(state.categoria, emit);

  Future<void> _onCategoriaFiltrada(
    EmprendimientosCategoriaFiltrada event,
    Emitter<EmprendimientosState> emit,
  ) => _cargar(event.categoria, emit);

  Future<void> _cargar(
    Categoria? categoria,
    Emitter<EmprendimientosState> emit,
  ) async {
    emit(
      state.copyWith(
        status: EmprendimientosStatus.loading,
        categoria: () => categoria,
      ),
    );
    final result = categoria == null
        ? await _getEmprendimientos(const NoParams())
        : await _searchByCategoria(categoria);
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: EmprendimientosStatus.failure,
          errorMessage: failure.message,
        ),
        (items) =>
            state.copyWith(status: EmprendimientosStatus.success, items: items),
      ),
    );
  }
}
