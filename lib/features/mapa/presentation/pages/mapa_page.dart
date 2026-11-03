import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vitrina_regional/app/router/app_routes.dart';
import 'package:vitrina_regional/core/widgets/state_views.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/ubicacion.dart';
import 'package:vitrina_regional/features/mapa/presentation/cubit/mapa_cubit.dart';

/// Mapa con los emprendimientos (OpenStreetMap vía flutter_map).
class MapaPage extends StatelessWidget {
  const MapaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapaCubit(
        getUbicacionActual: context.read(),
        getEmprendimientos: context.read(),
        ordenarPorCercania: context.read(),
      )..cargar(),
      child: const _MapaView(),
    );
  }
}

class _MapaView extends StatelessWidget {
  const _MapaView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de emprendimientos')),
      body: BlocConsumer<MapaCubit, MapaState>(
        listenWhen: (previous, current) => current.aviso != previous.aviso,
        listener: (context, state) {
          final aviso = state.aviso;
          if (aviso != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(aviso)));
          }
        },
        builder: (context, state) => switch (state.status) {
          MapaStatus.initial ||
          MapaStatus.loading => const LoadingView(message: 'Cargando mapa...'),
          MapaStatus.failure => ErrorView(
            message: state.errorMessage ?? 'No se pudo cargar el mapa.',
            onRetry: context.read<MapaCubit>().cargar,
          ),
          MapaStatus.success => _Mapa(state: state),
        },
      ),
      // TODO(COIL-E2-5): FloatingActionButton "Mi ubicación" que recentre el
      // mapa con un MapController (mapController.move(...)).
    );
  }
}

class _Mapa extends StatelessWidget {
  const _Mapa({required this.state});

  final MapaState state;

  static LatLng _toLatLng(Ubicacion u) => LatLng(u.latitud, u.longitud);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return FlutterMap(
      options: MapOptions(
        initialCenter: _toLatLng(state.centro),
        initialZoom: 9,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          // OSM exige identificar la app. Cambien por su applicationId.
          userAgentPackageName: 'co.edu.coil.vitrina_regional',
        ),
        MarkerLayer(
          markers: [
            for (final cercano in state.cercanos)
              Marker(
                point: _toLatLng(cercano.emprendimiento.ubicacion),
                width: 44,
                height: 44,
                child: GestureDetector(
                  // TODO(COIL-E2-4): En vez de navegar directo, mostrar un
                  // bottom sheet con nombre, categoría, distancia
                  // (Formatters.distancia) y un botón "Ver detalle".
                  onTap: () => context.push(
                    AppRoutes.detalle(cercano.emprendimiento.id),
                  ),
                  child: Tooltip(
                    message: cercano.emprendimiento.nombre,
                    child: Icon(Icons.location_on, size: 44, color: color),
                  ),
                ),
              ),
            // TODO(COIL-E2-2): Agregar un marcador distinto (p. ej. un punto
            // azul) en `state.ubicacionUsuario` cuando no sea null.
          ],
        ),
        const RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );
  }
}
