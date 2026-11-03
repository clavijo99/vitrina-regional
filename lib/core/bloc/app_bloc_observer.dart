import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

/// Observa TODOS los Blocs/Cubits de la app y registra sus cambios en consola.
///
/// Es la herramienta de depuración número uno: muestra cada transición
/// (estado anterior -> estado nuevo) y cada error.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    developer.log(
      '${bloc.runtimeType}: ${change.currentState.runtimeType} -> '
      '${change.nextState.runtimeType}',
      name: 'bloc',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    developer.log(
      '${bloc.runtimeType} lanzó un error',
      name: 'bloc',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
