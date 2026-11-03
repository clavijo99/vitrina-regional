import 'package:flutter_test/flutter_test.dart';
import 'package:vitrina_regional/app/router/app_router.dart';
import 'package:vitrina_regional/app/router/app_routes.dart';
import 'package:vitrina_regional/features/auth/presentation/bloc/auth_bloc.dart';

import '../../helpers/fixtures.dart';

void main() {
  String? redirect(AuthState state, String location) =>
      AppRouter.resolverRedirect(authState: state, location: location);

  group('AppRouter.resolverRedirect', () {
    test('mientras no se conoce la sesión, va a splash', () {
      expect(redirect(const AuthInitial(), AppRoutes.home), AppRoutes.splash);
      expect(redirect(const AuthInitial(), AppRoutes.splash), isNull);
    });

    test('sin sesión solo permite login y registro', () {
      const state = AuthUnauthenticated();
      expect(redirect(state, AppRoutes.home), AppRoutes.login);
      expect(redirect(state, AppRoutes.login), isNull);
      expect(redirect(state, AppRoutes.register), isNull);
    });

    test('con sesión, login y splash redirigen a home', () {
      const state = AuthAuthenticated(Fixtures.cliente);
      expect(redirect(state, AppRoutes.login), AppRoutes.home);
      expect(redirect(state, AppRoutes.splash), AppRoutes.home);
      expect(redirect(state, AppRoutes.detalle('e1')), isNull);
    });

    test('un cliente no puede entrar a Mi emprendimiento', () {
      const state = AuthAuthenticated(Fixtures.cliente);
      expect(redirect(state, AppRoutes.miEmprendimiento), AppRoutes.home);
      expect(redirect(state, AppRoutes.mapa), isNull);
    });

    test('un emprendedor sí puede entrar a Mi emprendimiento', () {
      const state = AuthAuthenticated(Fixtures.emprendedor);
      expect(redirect(state, AppRoutes.miEmprendimiento), isNull);
      expect(redirect(state, AppRoutes.mapa), AppRoutes.home);
    });
  });
}
