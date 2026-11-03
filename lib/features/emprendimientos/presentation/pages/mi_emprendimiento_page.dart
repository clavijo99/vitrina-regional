import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vitrina_regional/core/widgets/state_views.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';
import 'package:vitrina_regional/features/auth/presentation/auth_context_extension.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/bloc/emprendimientos_bloc.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/cubit/mi_emprendimiento_cubit.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/widgets/emprendimiento_form.dart';

/// "Mi emprendimiento": solo para el rol emprendedor (lo protege go_router).
class MiEmprendimientoPage extends StatelessWidget {
  const MiEmprendimientoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = context.usuarioActual;
    // El router ya garantiza sesión; esto es solo defensa extra.
    if (usuario == null) return const Scaffold(body: LoadingView());
    return BlocProvider(
      create: (context) => MiEmprendimientoCubit(
        getByOwner: context.read(),
        create: context.read(),
        update: context.read(),
      )..cargar(usuario.id),
      child: _MiEmprendimientoView(usuario: usuario),
    );
  }
}

class _MiEmprendimientoView extends StatelessWidget {
  const _MiEmprendimientoView({required this.usuario});

  final AppUser usuario;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MiEmprendimientoCubit, MiEmprendimientoState>(
      listenWhen: (previous, current) =>
          previous.saveStatus != current.saveStatus,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
        if (state.saveStatus == MiEmprendimientoStatus.success) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Emprendimiento guardado')),
          );
          // Refrescamos el listado global para que la Home lo muestre.
          context.read<EmprendimientosBloc>().add(
            const EmprendimientosRequested(),
          );
        } else if (state.saveStatus == MiEmprendimientoStatus.failure) {
          messenger.showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error al guardar')),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<MiEmprendimientoCubit>();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.emprendimiento == null
                  ? 'Crear mi emprendimiento'
                  : 'Mi emprendimiento',
            ),
          ),
          body: switch (state.loadStatus) {
            MiEmprendimientoStatus.initial ||
            MiEmprendimientoStatus.loading => const LoadingView(),
            MiEmprendimientoStatus.failure => ErrorView(
              message: state.errorMessage ?? 'No se pudo cargar.',
              onRetry: () => cubit.cargar(usuario.id),
            ),
            MiEmprendimientoStatus.success => EmprendimientoForm(
              ownerId: usuario.id,
              inicial: state.emprendimiento,
              guardando: state.guardando,
              onGuardar: cubit.guardar,
            ),
          },
        );
      },
    );
  }
}
