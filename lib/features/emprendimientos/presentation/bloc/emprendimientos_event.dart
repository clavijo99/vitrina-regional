part of 'emprendimientos_bloc.dart';

sealed class EmprendimientosEvent extends Equatable {
  const EmprendimientosEvent();

  @override
  List<Object?> get props => [];
}

/// Carga (o recarga) el listado respetando el filtro actual.
final class EmprendimientosRequested extends EmprendimientosEvent {
  const EmprendimientosRequested();
}

/// Cambia el filtro de categoría (`null` = todas).
final class EmprendimientosCategoriaFiltrada extends EmprendimientosEvent {
  const EmprendimientosCategoriaFiltrada(this.categoria);

  final Categoria? categoria;

  @override
  List<Object?> get props => [categoria];
}
