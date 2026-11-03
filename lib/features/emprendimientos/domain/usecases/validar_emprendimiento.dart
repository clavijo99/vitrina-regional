import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';

/// Reglas de negocio compartidas por crear y actualizar.
///
/// Devuelve un [ValidationFailure] si algo no cumple, o `null` si todo está
/// bien. Vive en domain: aplica sin importar qué pantalla guarde los datos.
ValidationFailure? validarEmprendimiento(Emprendimiento e) {
  if (e.ownerId.isEmpty) {
    return const ValidationFailure('El emprendimiento debe tener un dueño.');
  }
  if (e.nombre.trim().length < 3) {
    return const ValidationFailure('El nombre debe tener al menos 3 letras.');
  }
  if (e.descripcion.trim().length < 10) {
    return const ValidationFailure(
      'La descripción debe tener al menos 10 caracteres.',
    );
  }
  if (e.municipio.trim().isEmpty) {
    return const ValidationFailure('Indica el municipio.');
  }
  if (e.productos.any((p) => p.precio < 0)) {
    return const ValidationFailure('Los precios no pueden ser negativos.');
  }
  return null;
}
