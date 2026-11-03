import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vitrina_regional/core/utils/formatters.dart';
import 'package:vitrina_regional/features/auth/presentation/auth_context_extension.dart';
import 'package:vitrina_regional/features/resenas/presentation/bloc/resenas_bloc.dart';
import 'package:vitrina_regional/features/resenas/presentation/widgets/rating_stars.dart';
import 'package:vitrina_regional/features/resenas/presentation/widgets/resena_form.dart';

/// Sección de reseñas del detalle. Requiere un [ResenasBloc] arriba en el
/// árbol (lo provee la página de detalle).
class ResenasSection extends StatelessWidget {
  const ResenasSection({required this.ownerId, super.key});

  /// Dueño del emprendimiento (no puede reseñarse a sí mismo).
  final String ownerId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usuario = context.usuarioActual;
    final puedeResenar =
        usuario != null && usuario.esCliente && usuario.id != ownerId;

    return BlocBuilder<ResenasBloc, ResenasState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Reseñas', style: theme.textTheme.titleLarge),
                const Spacer(),
                RatingStars(valor: state.promedio),
                const SizedBox(width: 8),
                Text(
                  '${state.promedio.toStringAsFixed(1)} '
                  '(${state.resenas.length})',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (puedeResenar) const ResenaForm(),
            switch (state.status) {
              ResenasStatus.initial || ResenasStatus.loading => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              ResenasStatus.failure => Text(
                state.errorMessage ?? 'No se pudieron cargar las reseñas.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              ResenasStatus.success when state.resenas.isEmpty => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Aún no hay reseñas. ¡Sé el primero!'),
              ),
              ResenasStatus.success => Column(
                children: [
                  for (final resena in state.resenas)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text(
                          resena.autorNombre.isEmpty
                              ? '?'
                              : resena.autorNombre[0].toUpperCase(),
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(child: Text(resena.autorNombre)),
                          const SizedBox(width: 8),
                          RatingStars(
                            valor: resena.estrellas.toDouble(),
                            size: 14,
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '${resena.comentario}\n'
                        '${Formatters.fecha(resena.fecha)}',
                      ),
                      isThreeLine: true,
                    ),
                ],
              ),
            },
          ],
        );
      },
    );
  }
}
