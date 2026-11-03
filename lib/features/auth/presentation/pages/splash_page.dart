import 'package:material_ui/material_ui.dart';
import 'package:vitrina_regional/core/widgets/state_views.dart';

/// Se muestra mientras AuthBloc averigua si hay sesión (estado AuthInitial).
/// El redirect de go_router saca al usuario de aquí automáticamente.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoadingView(message: 'Vitrina Regional'));
  }
}
