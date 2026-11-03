import 'package:fpdart/fpdart.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/resenas/domain/entities/resena.dart';
import 'package:vitrina_regional/features/resenas/domain/repositories/resena_repository.dart';

/// Caso de uso: publicar una reseña.
///
/// Valida en domain las mismas reglas que exige `firestore.rules`
/// (defensa en profundidad: cliente + servidor).
class AddResena implements UseCase<Unit, Resena> {
  const AddResena(this._repository);

  final ResenaRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(Resena resena) async {
    if (resena.estrellas < Resena.minEstrellas ||
        resena.estrellas > Resena.maxEstrellas) {
      return const Left(
        ValidationFailure('La calificación debe estar entre 1 y 5 estrellas.'),
      );
    }
    if (resena.comentario.length > Resena.maxComentario) {
      return const Left(
        ValidationFailure('El comentario admite máximo 500 caracteres.'),
      );
    }
    // TODO(COIL-E3-4): Regla de negocio: el dueño del emprendimiento no puede
    // reseñar su propio negocio. Pista: recibir el ownerId en los parámetros
    // (cree un `AddResenaParams`) y devolver un ValidationFailure.
    return _repository.addResena(resena);
  }
}
