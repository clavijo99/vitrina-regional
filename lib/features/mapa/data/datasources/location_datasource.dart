import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/ubicacion.dart';

/// Contrato del datasource de ubicación.
abstract interface class LocationDataSource {
  /// Lanza [PermissionException] o [LocationException] si no es posible.
  Future<Ubicacion> getPosicionActual();
}

/// Implementación real con el paquete `geolocator`.
class GeolocatorLocationDataSource implements LocationDataSource {
  const GeolocatorLocationDataSource();

  @override
  Future<Ubicacion> getPosicionActual() async {
    // TODO(COIL-E2-1): Implementar con geolocator
    //   (import 'package:geolocator/geolocator.dart'):
    //   1. `Geolocator.isLocationServiceEnabled()`; si es false lanzar
    //      LocationException('Activa el GPS').
    //   2. `Geolocator.checkPermission()`; si es `denied` llamar a
    //      `Geolocator.requestPermission()`.
    //   3. Si queda `denied` o `deniedForever` lanzar PermissionException.
    //   4. `Geolocator.getCurrentPosition(locationSettings:
    //        const LocationSettings(accuracy: LocationAccuracy.high))`
    //      y devolver Ubicacion(latitud: p.latitude, longitud: p.longitude).
    // TODO(COIL-E1-5): Declarar los permisos de ubicación en
    //   android/app/src/main/AndroidManifest.xml (ACCESS_FINE_LOCATION y
    //   ACCESS_COARSE_LOCATION) e ios/Runner/Info.plist
    //   (NSLocationWhenInUseUsageDescription).
    throw const LocationException('Ubicación pendiente (encuentro E2).');
  }
}

/// Ubicación fija (Villavicencio) para el modo mock y las pruebas.
class MockLocationDataSource implements LocationDataSource {
  const MockLocationDataSource({this.ubicacion = Ubicacion.villavicencio});

  final Ubicacion ubicacion;

  @override
  Future<Ubicacion> getPosicionActual() async => ubicacion;
}
