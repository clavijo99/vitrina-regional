/// Rutas de la app en un solo lugar (evita "strings mágicos" repetidos).
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String mapa = '/mapa';
  static const String miEmprendimiento = '/mi-emprendimiento';
  static const String detallePattern = '/emprendimiento/:id';

  static String detalle(String id) => '/emprendimiento/$id';
}
