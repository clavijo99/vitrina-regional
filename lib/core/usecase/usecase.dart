import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';

/// Contrato de un caso de uso: UNA acción de negocio.
///
/// Los Blocs/Cubits dependen de casos de uso (no de repositorios) para que cada
/// acción sea pequeña, nombrable y fácil de probar de forma aislada.
abstract interface class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Caso de uso que devuelve un flujo continuo de datos (tiempo real).
abstract interface class StreamUseCase<T, Params> {
  Stream<T> call(Params params);
}

/// Parámetro vacío para casos de uso que no necesitan datos de entrada.
final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
