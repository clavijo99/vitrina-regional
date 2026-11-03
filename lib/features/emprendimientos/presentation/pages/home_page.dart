import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vitrina_regional/app/router/app_routes.dart';
import 'package:vitrina_regional/core/widgets/state_views.dart';
import 'package:vitrina_regional/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/bloc/emprendimientos_bloc.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/cubit/filtro_categoria_cubit.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/widgets/categoria_chips.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/widgets/emprendimiento_card.dart';

/// Pantalla principal: listado de emprendimientos con filtro por categoría.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // El filtro arranca con la categoría que ya tenga el bloc global.
      create: (context) => FiltroCategoriaCubit(
        context.read<EmprendimientosBloc>().state.categoria,
      ),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final usuario = authState is AuthAuthenticated ? authState.user : null;

    // El cubit del filtro (estado simple) avisa al bloc del listado.
    return BlocListener<FiltroCategoriaCubit, Categoria?>(
      listener: (context, categoria) => context.read<EmprendimientosBloc>().add(
        EmprendimientosCategoriaFiltrada(categoria),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vitrina Regional'),
          actions: [
            if (usuario?.esCliente ?? false)
              IconButton(
                tooltip: 'Ver mapa',
                icon: const Icon(Icons.map_outlined),
                onPressed: () => context.push(AppRoutes.mapa),
              ),
            if (usuario?.esEmprendedor ?? false)
              IconButton(
                tooltip: 'Mi emprendimiento',
                icon: const Icon(Icons.storefront_outlined),
                onPressed: () => context.push(AppRoutes.miEmprendimiento),
              ),
            IconButton(
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthSignOutRequested()),
            ),
          ],
        ),
        body: Column(
          children: [
            if (usuario != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hola, ${usuario.nombre} (${usuario.rol.label})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
            const CategoriaChips(),
            const Expanded(child: _ListadoEmprendimientos()),
          ],
        ),
      ),
    );
  }
}

class _ListadoEmprendimientos extends StatelessWidget {
  const _ListadoEmprendimientos();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmprendimientosBloc, EmprendimientosState>(
      builder: (context, state) {
        final bloc = context.read<EmprendimientosBloc>();
        return switch (state.status) {
          EmprendimientosStatus.initial ||
          EmprendimientosStatus.loading => const LoadingView(),
          EmprendimientosStatus.failure => ErrorView(
            message: state.errorMessage ?? 'Error al cargar.',
            onRetry: () => bloc.add(const EmprendimientosRequested()),
          ),
          EmprendimientosStatus.success when state.items.isEmpty =>
            const EmptyView(
              message: 'No hay emprendimientos en esta categoría.',
              icon: Icons.storefront_outlined,
            ),
          EmprendimientosStatus.success => RefreshIndicator(
            onRefresh: () async {
              bloc.add(const EmprendimientosRequested());
              // Espera a que termine la recarga para ocultar el indicador.
              await bloc.stream.firstWhere(
                (s) => s.status != EmprendimientosStatus.loading,
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final emprendimiento = state.items[index];
                return EmprendimientoCard(
                  emprendimiento: emprendimiento,
                  onTap: () =>
                      context.push(AppRoutes.detalle(emprendimiento.id)),
                );
              },
            ),
          ),
        };
      },
    );
  }
}
