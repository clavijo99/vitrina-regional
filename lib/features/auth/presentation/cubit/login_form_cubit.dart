import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitrina_regional/core/utils/validators.dart';

/// Estado del formulario de login.
class LoginFormState extends Equatable {
  const LoginFormState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.showErrors = false,
  });

  final String email;
  final String password;
  final bool obscurePassword;

  /// Los errores solo se muestran después del primer intento de enviar.
  final bool showErrors;

  String? get emailError => showErrors ? Validators.email(email) : null;
  String? get passwordError =>
      showErrors ? Validators.password(password) : null;

  bool get isValid =>
      Validators.email(email) == null && Validators.password(password) == null;

  LoginFormState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    bool? showErrors,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      showErrors: showErrors ?? this.showErrors,
    );
  }

  @override
  List<Object?> get props => [email, password, obscurePassword, showErrors];
}

/// Cubit para un estado SIMPLE: los campos del formulario de login.
///
/// Un Cubit expone métodos en vez de eventos: ideal cuando no necesitamos
/// trazabilidad de eventos ni transformaciones (debounce, etc.).
class LoginFormCubit extends Cubit<LoginFormState> {
  LoginFormCubit() : super(const LoginFormState());

  void emailChanged(String value) => emit(state.copyWith(email: value));

  void passwordChanged(String value) => emit(state.copyWith(password: value));

  void toggleObscurePassword() =>
      emit(state.copyWith(obscurePassword: !state.obscurePassword));

  /// Marca el formulario como "enviado" y devuelve si es válido.
  bool submit() {
    emit(state.copyWith(showErrors: true));
    return state.isValid;
  }
}
