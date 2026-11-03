import 'dart:async';

import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:vitrina_regional/features/auth/data/models/app_user_model.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';

/// Id del emprendedor de demostración. El mock de emprendimientos le asigna
/// un emprendimiento para que se pueda probar "Mi emprendimiento".
const String kDemoEmprendedorId = 'demo-emprendedor';
const String kDemoClienteId = 'demo-cliente';

/// Datasource en memoria para trabajar SIN Firebase (`useMockData = true`).
///
/// Usuarios de prueba (contraseña `123456`):
/// - emprendedor@demo.com (rol emprendedor)
/// - cliente@demo.com (rol cliente)
///
/// Los usuarios registrados se pierden al reiniciar la app.
class MockAuthDataSource implements AuthDataSource {
  MockAuthDataSource({this.latency = const Duration(milliseconds: 400)});

  final Duration latency;

  final StreamController<AppUserModel?> _controller =
      StreamController<AppUserModel?>.broadcast();

  AppUserModel? _usuarioActual;

  final Map<String, ({String password, AppUserModel user})> _usuarios = {
    'emprendedor@demo.com': (
      password: '123456',
      user: const AppUserModel(
        id: kDemoEmprendedorId,
        nombre: 'Laura Emprendedora',
        email: 'emprendedor@demo.com',
        rol: UserRole.emprendedor,
      ),
    ),
    'cliente@demo.com': (
      password: '123456',
      user: const AppUserModel(
        id: kDemoClienteId,
        nombre: 'Carlos Cliente',
        email: 'cliente@demo.com',
        rol: UserRole.cliente,
      ),
    ),
  };

  @override
  Stream<AppUserModel?> watchAuthState() async* {
    yield _usuarioActual;
    yield* _controller.stream;
  }

  @override
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(latency);
    final registro = _usuarios[email.toLowerCase()];
    if (registro == null || registro.password != password) {
      throw const AuthException('invalid-credential');
    }
    _emitir(registro.user);
    return registro.user;
  }

  @override
  Future<AppUserModel> signUp({
    required String nombre,
    required String email,
    required String password,
    required UserRole rol,
  }) async {
    await Future<void>.delayed(latency);
    final clave = email.toLowerCase();
    if (_usuarios.containsKey(clave)) {
      throw const AuthException('email-already-in-use');
    }
    final user = AppUserModel(
      id: 'mock-${DateTime.now().microsecondsSinceEpoch}',
      nombre: nombre,
      email: clave,
      rol: rol,
    );
    _usuarios[clave] = (password: password, user: user);
    _emitir(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(latency);
    _emitir(null);
  }

  void _emitir(AppUserModel? user) {
    _usuarioActual = user;
    _controller.add(user);
  }

  /// Libera el stream (útil en pruebas).
  Future<void> dispose() => _controller.close();
}
