import 'package:flutter_test/flutter_test.dart';
import 'package:vitrina_regional/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email válido devuelve null', () {
      expect(Validators.email('ana@unimininuto.edu.co'), isNull);
    });

    test('email vacío o inválido devuelve mensaje', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('ana@'), 'Correo no válido');
    });

    test('password exige mínimo 6 caracteres', () {
      expect(Validators.password('12345'), 'Mínimo 6 caracteres');
      expect(Validators.password('123456'), isNull);
    });

    test('latitud fuera de rango es inválida', () {
      expect(Validators.latitud('4.14'), isNull);
      expect(Validators.latitud('95'), isNotNull);
      expect(Validators.longitud('-73,62'), isNull);
    });

    test('Comparar contraseñas', () {
      expect(Validators.confirmarContrasena('123456', '123456'), isNull);
      expect(
        Validators.confirmarContrasena('123456', '23456'),
        'Las contraseñas no coinciden',
      );
      expect(Validators.confirmarContrasena('', '123456'), isNotNull);
    });
  });
}
