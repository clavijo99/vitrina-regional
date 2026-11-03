import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';
import 'package:vitrina_regional/features/auth/presentation/bloc/auth_bloc.dart';

/// Atajo para leer el usuario autenticado desde cualquier widget.
extension AuthContextX on BuildContext {
  /// Usuario actual o `null` si no hay sesión. No se suscribe a cambios.
  AppUser? get usuarioActual => switch (read<AuthBloc>().state) {
    AuthAuthenticated(:final user) => user,
    _ => null,
  };
}
