import 'package:material_ui/material_ui.dart';
import 'package:vitrina_regional/core/widgets/app_network_image.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';

/// Tarjeta de un emprendimiento en el listado.
class EmprendimientoCard extends StatelessWidget {
  const EmprendimientoCard({
    required this.emprendimiento,
    required this.onTap,
    super.key,
  });

  final Emprendimiento emprendimiento;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Hero(
                tag: 'foto-${emprendimiento.id}',
                child: AppNetworkImage(url: emprendimiento.fotoPrincipal),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emprendimiento.nombre,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(emprendimiento.municipio),
                      const Spacer(),
                      Chip(
                        label: Text(emprendimiento.categoria.label),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  Text(
                    emprendimiento.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
