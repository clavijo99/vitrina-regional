import 'package:equatable/equatable.dart';

/// Punto geográfico (latitud/longitud en grados decimales).
///
/// Es un "value object" de domain: no depende de geolocator ni de latlong2;
/// la capa de presentación lo convierte a `LatLng` para el mapa.
class Ubicacion extends Equatable {
  const Ubicacion({required this.latitud, required this.longitud});

  /// Parque Los Fundadores, Villavicencio. Centro por defecto del mapa.
  static const Ubicacion villavicencio = Ubicacion(
    latitud: 4.1420,
    longitud: -73.6266,
  );

  final double latitud;
  final double longitud;

  @override
  List<Object?> get props => [latitud, longitud];
}
