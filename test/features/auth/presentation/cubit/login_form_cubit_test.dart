import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitrina_regional/features/auth/presentation/cubit/login_form_cubit.dart';

void main() {
  group('LoginFormCubit', () {
    blocTest<LoginFormCubit, LoginFormState>(
      'actualiza email y password',
      build: LoginFormCubit.new,
      act: (cubit) => cubit
        ..emailChanged('a@b.co')
        ..passwordChanged('123456'),
      expect: () => const [
        LoginFormState(email: 'a@b.co'),
        LoginFormState(email: 'a@b.co', password: '123456'),
      ],
    );

    test('submit con datos inválidos devuelve false y muestra errores', () {
      final cubit = LoginFormCubit()..emailChanged('malo');
      expect(cubit.submit(), isFalse);
      expect(cubit.state.showErrors, isTrue);
      expect(cubit.state.emailError, 'Correo no válido');
    });

    test('submit con datos válidos devuelve true', () {
      final cubit = LoginFormCubit()
        ..emailChanged('a@b.co')
        ..passwordChanged('123456');
      expect(cubit.submit(), isTrue);
    });
  });
}
