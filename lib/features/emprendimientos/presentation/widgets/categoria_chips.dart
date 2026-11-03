import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/cubit/filtro_categoria_cubit.dart';

/// Fila horizontal de chips para filtrar por categoría.
class CategoriaChips extends StatelessWidget {
  const CategoriaChips({super.key});

  @override
  Widget build(BuildContext context) {
    final seleccionada = context.watch<FiltroCategoriaCubit>().state;
    final cubit = context.read<FiltroCategoriaCubit>();
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Todas'),
              selected: seleccionada == null,
              onSelected: (_) => cubit.limpiar(),
            ),
          ),
          for (final categoria in Categoria.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(categoria.label),
                selected: seleccionada == categoria,
                onSelected: (_) => cubit.seleccionar(categoria),
              ),
            ),
        ],
      ),
    );
  }
}
