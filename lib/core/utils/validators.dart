/// Validadores reutilizables para formularios.
///
/// Devuelven `null` si el valor es válido o un mensaje de error en español,
/// que es justo lo que espera `TextFormField.validator`.
abstract final class Validators {
  static final RegExp _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? requerido(String? value, {String campo = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$campo es obligatorio';
    return null;
  }

  static String? email(String? value) {
    final requeridoError = requerido(value, campo: 'El correo');
    if (requeridoError != null) return requeridoError;
    if (!_emailRegExp.hasMatch(value!.trim())) return 'Correo no válido';
    return null;
  }

  static String? password(String? value) {
    final requeridoError = requerido(value, campo: 'La contraseña');
    if (requeridoError != null) return requeridoError;
    if (value!.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? confirmarContrasena(String value, String original) {
    final requeridoError = requerido(value, campo: 'La confirmacion');
    if (requeridoError != null) {
      return requeridoError;
    }
    if (value != original) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static String? nombre(String? value) {
    final requeridoError = requerido(value, campo: 'El nombre');
    if (requeridoError != null) return requeridoError;
    if (value!.trim().length < 3) return 'Mínimo 3 caracteres';
    return null;
  }

  static String? precio(String? value) {
    final requeridoError = requerido(value, campo: 'El precio');
    if (requeridoError != null) return requeridoError;
    final numero = double.tryParse(value!.replaceAll(',', '.'));
    if (numero == null || numero < 0) return 'Precio no válido';
    return null;
  }

  static String? latitud(String? value) =>
      _coordenada(value, minimo: -90, maximo: 90, campo: 'La latitud');

  static String? longitud(String? value) =>
      _coordenada(value, minimo: -180, maximo: 180, campo: 'La longitud');

  static String? _coordenada(
    String? value, {
    required double minimo,
    required double maximo,
    required String campo,
  }) {
    final requeridoError = requerido(value, campo: campo);
    if (requeridoError != null) return requeridoError;
    final numero = double.tryParse(value!.replaceAll(',', '.'));
    if (numero == null || numero < minimo || numero > maximo) {
      return '$campo debe estar entre $minimo y $maximo';
    }
    return null;
  }
}
