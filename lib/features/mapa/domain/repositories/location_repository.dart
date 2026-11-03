import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/ubicacion.dart';

/// Contrato para obtener la ubicación del dispositivo.
abstract interface class LocationRepository {
  /// `Left(PermissionFailure)` si el usuario negó el permiso,
  /// `Left(LocationFailure)` si el GPS está apagado o falla.
  Future<Either<Failure, Ubicacion>> getUbicacionActual();
}
