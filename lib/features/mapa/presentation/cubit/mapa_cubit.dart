import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/ubicacion.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/get_emprendimientos.dart';
import 'package:vitrina_regional/features/mapa/domain/entities/emprendimiento_cercano.dart';
import 'package:vitrina_regional/features/mapa/domain/usecases/get_ubicacion_actual.dart';
import 'package:vitrina_regional/features/mapa/domain/usecases/ordenar_por_cercania.dart';

enum MapaStatus { initial, loading, success, failure }

class MapaState extends Equatable {
  const MapaState({
    this.status = MapaStatus.initial,
    this.centro = Ubicacion.villavicencio,
    this.ubicacionUsuario,
    this.cercanos = const [],
    this.aviso,
    this.errorMessage,
  });

  final MapaStatus status;

  /// Punto donde se centra el mapa.
  final Ubicacion centro;

  /// `null` si no se pudo obtener la ubicación real.
  final Ubicacion? ubicacionUsuario;
  final List<EmprendimientoCercano> cercanos;

  /// Mensaje informativo no bloqueante (p. ej. "usando ubicación por defecto").
  final String? aviso;
  final String? errorMessage;

  @override
  List<Object?> get props => [
    status,
    centro,
    ubicacionUsuario,
    cercanos,
    aviso,
    errorMessage,
  ];
}

/// Cubit del mapa: combina ubicación del usuario + emprendimientos y los
/// ordena por cercanía. Recibe solo casos de uso (de dos features distintas).
class MapaCubit extends Cubit<MapaState> {
  MapaCubit({
    required this._getUbicacionActual,
    required this._getEmprendimientos,
    required this._ordenarPorCercania,
  }) : super(const MapaState());

  final GetUbicacionActual _getUbicacionActual;
  final GetEmprendimientos _getEmprendimientos;
  final OrdenarPorCercania _ordenarPorCercania;

  Future<void> cargar() async {
    emit(const MapaState(status: MapaStatus.loading));

    final emprendimientosResult = await _getEmprendimientos(const NoParams());
    final ubicacionResult = await _getUbicacionActual(const NoParams());

    // Si falla la ubicación seguimos con el centro de Villavicencio.
    final ubicacionUsuario = ubicacionResult.toNullable();
    final origen = ubicacionUsuario ?? Ubicacion.villavicencio;
    final aviso = ubicacionResult.fold(
      (failure) => '${failure.message} Mostrando Villavicencio.',
      (_) => null,
    );

    emit(
      emprendimientosResult.fold(
        (failure) => MapaState(
          status: MapaStatus.failure,
          errorMessage: failure.message,
        ),
        (emprendimientos) => MapaState(
          status: MapaStatus.success,
          centro: origen,
          ubicacionUsuario: ubicacionUsuario,
          aviso: aviso,
          cercanos: _ordenarPorCercania(
            origen: origen,
            emprendimientos: emprendimientos,
          ),
        ),
      ),
    );
  }

  // TODO(COIL-E2-3): Agregar `seleccionar(EmprendimientoCercano?)` y un campo
  // `seleccionado` en MapaState para resaltar el marcador tocado.
}
