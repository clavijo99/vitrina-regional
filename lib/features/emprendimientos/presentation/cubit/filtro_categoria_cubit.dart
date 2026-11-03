import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/categoria.dart';

/// Cubit de estado simple: la categoría seleccionada en los chips
/// (`null` = todas). La Home escucha este cubit y avisa al
/// EmprendimientosBloc para que vuelva a consultar.
class FiltroCategoriaCubit extends Cubit<Categoria?> {
  FiltroCategoriaCubit([super.inicial]);

  /// Si se toca la categoría ya seleccionada, se quita el filtro.
  void seleccionar(Categoria? categoria) =>
      emit(categoria == state ? null : categoria);

  void limpiar() => emit(null);
}
