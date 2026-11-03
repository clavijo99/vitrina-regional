import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vitrina_regional/app/app.dart';
import 'package:vitrina_regional/app/di/app_providers.dart';
import 'package:vitrina_regional/core/bloc/app_bloc_observer.dart';
import 'package:vitrina_regional/firebase_options.dart';

/// Punto de entrada (bootstrap):
/// 1. Inicializa Firebase (solo si NO estamos en modo mock).
/// 2. Carga los formatos de fecha en español.
/// 3. Registra el observer global de Blocs.
/// 4. Monta los providers (DI) y la app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!useMockData) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await initializeDateFormatting('es');
  Bloc.observer = const AppBlocObserver();

  runApp(const AppProviders(child: VitrinaRegionalApp()));
}
