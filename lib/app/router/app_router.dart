import 'package:go_router/go_router.dart';
import 'package:vitrina_regional/app/router/app_routes.dart';
import 'package:vitrina_regional/app/router/go_router_refresh_stream.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';
import 'package:vitrina_regional/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vitrina_regional/features/auth/presentation/pages/login_page.dart';
import 'package:vitrina_regional/features/auth/presentation/pages/register_page.dart';
import 'package:vitrina_regional/features/auth/presentation/pages/splash_page.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/pages/detalle_page.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/pages/home_page.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/pages/mi_emprendimiento_page.dart';
import 'package:vitrina_regional/features/mapa/presentation/pages/mapa_page.dart';

/// Configuración de go_router con guardas por sesión y por rol.
///
/// Las pantallas NUNCA navegan después de login/logout: solo cambian el
/// estado de AuthBloc. [GoRouterRefreshStream] avisa a go_router, que vuelve
/// a ejecutar [resolverRedirect] y decide a dónde ir.
class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  late final GoRouterRefreshStream _refresh = GoRouterRefreshStream(
    _authBloc.stream,
  );

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _refresh,
    redirect: (context, state) => resolverRedirect(
      authState: _authBloc.state,
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.detallePattern,
        builder: (context, state) =>
            DetallePage(emprendimientoId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: AppRoutes.mapa,
        builder: (context, state) => const MapaPage(),
      ),
      GoRoute(
        path: AppRoutes.miEmprendimiento,
        builder: (context, state) => const MiEmprendimientoPage(),
      ),
    ],
  );

  /// Rutas restringidas por rol. Las que no aparecen aquí son para cualquier
  /// usuario autenticado.
  static const Map<String, Set<UserRole>> rutasPorRol = {
    AppRoutes.miEmprendimiento: {UserRole.emprendedor},
    AppRoutes.mapa: {UserRole.cliente},
  };

  static const Set<String> _rutasPublicas = {
    AppRoutes.login,
    AppRoutes.register,
  };

  /// Función PURA (sin contexto) para poder probarla con un test unitario.
  /// Devuelve la ruta a la que hay que redirigir o `null` para quedarse.
  static String? resolverRedirect({
    required AuthState authState,
    required String location,
  }) {
    final esPublica = _rutasPublicas.contains(location);
    switch (authState) {
      case AuthInitial():
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      case AuthLoading() || AuthUnauthenticated() || AuthError():
        return esPublica ? null : AppRoutes.login;
      case AuthAuthenticated(:final user):
        if (esPublica || location == AppRoutes.splash) return AppRoutes.home;
        final rolesPermitidos = rutasPorRol[location];
        if (rolesPermitidos != null && !rolesPermitidos.contains(user.rol)) {
          return AppRoutes.home;
        }
        return null;
    }
  }

  void dispose() {
    _refresh.dispose();
    router.dispose();
  }
}
