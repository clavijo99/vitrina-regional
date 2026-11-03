import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/resenas/domain/entities/resena.dart';

/// Contrato del repositorio de reseñas (tiempo real).
abstract interface class ResenaRepository {
  /// Emite la lista completa de reseñas cada vez que cambia en el servidor.
  /// Los errores llegan como `Left(Failure)` dentro del stream.
  Stream<Either<Failure, List<Resena>>> watchResenas(String emprendimientoId);

  Future<Either<Failure, Unit>> addResena(Resena resena);
}
