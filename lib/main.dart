import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vitrina_regional/app/app.dart';
import 'package:vitrina_regional/app/di/app_providers.dart';
import 'package:vitrina_regional/core/bloc/app_bloc_observer.dart';
import 'package:vitrina_regional/firebase_options.dart';



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
