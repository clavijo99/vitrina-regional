import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vitrina_regional/app/router/app_router.dart';
import 'package:vitrina_regional/app/theme/app_theme.dart';
import 'package:vitrina_regional/features/auth/presentation/bloc/auth_bloc.dart';

/// Widget raíz: MaterialApp.router + tema + go_router.
///
/// Es StatefulWidget para crear el router UNA sola vez (si se creara en
/// `build`, cada reconstrucción reiniciaría la navegación).
class VitrinaRegionalApp extends StatefulWidget {
  const VitrinaRegionalApp({super.key});

  @override
  State<VitrinaRegionalApp> createState() => _VitrinaRegionalAppState();
}

class _VitrinaRegionalAppState extends State<VitrinaRegionalApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(context.read<AuthBloc>());
  }

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vitrina Regional',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _appRouter.router,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
