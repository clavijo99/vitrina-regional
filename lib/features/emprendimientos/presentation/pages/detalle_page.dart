import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vitrina_regional/core/utils/formatters.dart';
import 'package:vitrina_regional/core/widgets/app_network_image.dart';
import 'package:vitrina_regional/core/widgets/state_views.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/cubit/emprendimiento_detalle_cubit.dart';
import 'package:vitrina_regional/features/resenas/presentation/bloc/resenas_bloc.dart';
import 'package:vitrina_regional/features/resenas/presentation/widgets/resenas_section.dart';

/// Detalle de un emprendimiento con productos y reseñas en tiempo real.
///
/// Los blocs de esta página se crean AQUÍ (no globalmente): viven mientras
/// la página está abierta y se cierran solos al salir, cancelando el stream
/// de reseñas.
class DetallePage extends StatelessWidget {
  const DetallePage({required this.emprendimientoId, super.key});

  final String emprendimientoId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              EmprendimientoDetalleCubit(context.read())
                ..cargar(emprendimientoId),
        ),
        BlocProvider(
          create: (context) => ResenasBloc(
            watchResenas: context.read(),
            addResena: context.read(),
          )..add(ResenasSubscriptionRequested(emprendimientoId)),
        ),
      ],
      child:
          BlocBuilder<EmprendimientoDetalleCubit, EmprendimientoDetalleState>(
            builder: (context, state) {
              final emprendimiento = state.emprendimiento;
              return switch (state.status) {
                DetalleStatus.success when emprendimiento != null =>
                  _DetalleView(emprendimiento: emprendimiento),
                DetalleStatus.failure => Scaffold(
                  appBar: AppBar(),
                  body: ErrorView(
                    message: state.errorMessage ?? 'No se pudo cargar.',
                    onRetry: () => context
                        .read<EmprendimientoDetalleCubit>()
                        .cargar(emprendimientoId),
                  ),
                ),
                _ => Scaffold(appBar: AppBar(), body: const LoadingView()),
              };
            },
          ),
    );
  }
}

class _DetalleView extends StatelessWidget {
  const _DetalleView({required this.emprendimiento});

  final Emprendimiento emprendimiento;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
            title: Text(emprendimiento.nombre),
            flexibleSpace: FlexibleSpaceBar(
              background: emprendimiento.fotos.length <= 1
                  ? Hero(
                      tag: 'foto-${emprendimiento.id}',
                      child: AppNetworkImage(url: emprendimiento.fotoPrincipal),
                    )
                  : PageView(
                      children: [
                        for (final foto in emprendimiento.fotos)
                          AppNetworkImage(url: foto),
                      ],
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Chip(label: Text(emprendimiento.categoria.label)),
                    const Icon(Icons.place_outlined, size: 18),
                    Text(emprendimiento.municipio),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  emprendimiento.descripcion,
                  style: theme.textTheme.bodyLarge,
                ),
                // TODO(COIL-E2-6): Botón "Cómo llegar" que abra el mapa
                // centrado en emprendimiento.ubicacion.
                const SizedBox(height: 24),
                Text('Productos', style: theme.textTheme.titleLarge),
                if (emprendimiento.productos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Este emprendimiento aún no tiene productos.'),
                  ),
                for (final producto in emprendimiento.productos)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.shopping_bag_outlined),
                    title: Text(producto.nombre),
                    subtitle: producto.descripcion.isEmpty
                        ? null
                        : Text(producto.descripcion),
                    trailing: Text(
                      Formatters.precio(producto.precio),
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                const Divider(height: 32),
                ResenasSection(ownerId: emprendimiento.ownerId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
