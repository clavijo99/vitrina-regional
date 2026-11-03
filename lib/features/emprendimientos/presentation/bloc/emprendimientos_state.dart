part of 'emprendimientos_bloc.dart';

enum EmprendimientosStatus { initial, loading, success, failure }

class EmprendimientosState extends Equatable {
  const EmprendimientosState({
    this.status = EmprendimientosStatus.initial,
    this.items = const [],
    this.categoria,
    this.errorMessage,
  });

  final EmprendimientosStatus status;
  final List<Emprendimiento> items;
  final Categoria? categoria;
  final String? errorMessage;

  /// `categoria` es una función para poder asignar `null` explícitamente
  /// (con un parámetro `Categoria?` no sabríamos si "no cambiar" o "quitar").
  EmprendimientosState copyWith({
    EmprendimientosStatus? status,
    List<Emprendimiento>? items,
    Categoria? Function()? categoria,
    String? errorMessage,
  }) {
    return EmprendimientosState(
      status: status ?? this.status,
      items: items ?? this.items,
      categoria: categoria != null ? categoria() : this.categoria,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, categoria, errorMessage];
}
