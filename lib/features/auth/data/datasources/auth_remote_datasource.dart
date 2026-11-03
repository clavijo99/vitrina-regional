import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/features/auth/data/models/app_user_model.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';

/// Contrato del datasource de autenticación.
///
/// Lo implementan [FirebaseAuthRemoteDataSource] (real) y
/// `MockAuthDataSource` (en memoria, para trabajar sin Firebase).
/// Los datasources LANZAN excepciones de `core/error/exceptions.dart`.
abstract interface class AuthDataSource {
  Stream<AppUserModel?> watchAuthState();

  Future<AppUserModel> signIn({
    required String email,
    required String password,
  });

  Future<AppUserModel> signUp({
    required String nombre,
    required String email,
    required String password,
    required UserRole rol,
  });

  Future<void> signOut();
}

/// Implementación con Firebase Auth + colección `users` de Firestore.
class FirebaseAuthRemoteDataSource implements AuthDataSource {
  // Dart 3.12+: `this._auth` en un parámetro nombrado se invoca como `auth:`.
  FirebaseAuthRemoteDataSource({required this._auth, required this._firestore});

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Stream<AppUserModel?> watchAuthState() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        return await _leerPerfil(user);
      } on FirebaseException {
        // Sin conexión o sin permisos: devolvemos el perfil mínimo.
        return _perfilMinimo(user);
      }
    });
  }

  @override
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException('user-null');
      return await _leerPerfil(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message);
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  @override
  Future<AppUserModel> signUp({
    required String nombre,
    required String email,
    required String password,
    required UserRole rol,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException('user-null');
      final model = AppUserModel(
        id: user.uid,
        nombre: nombre,
        email: email,
        rol: rol,
      );
      // El perfil (con el rol) se guarda en users/{uid}. Las reglas de
      // Firestore solo permiten que cada usuario escriba su propio documento.
      await _users.doc(user.uid).set(model.toMap());
      await user.updateDisplayName(nombre);
      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message);
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message);
    }
  }

  Future<AppUserModel> _leerPerfil(User user) async {
    final doc = await _users.doc(user.uid).get();
    // Justo después del registro, authStateChanges puede emitir antes de que
    // exista el documento: usamos un perfil mínimo como respaldo.
    if (!doc.exists) return _perfilMinimo(user);
    return AppUserModel.fromFirestore(doc);
  }

  AppUserModel _perfilMinimo(User user) => AppUserModel(
    id: user.uid,
    nombre: user.displayName ?? '',
    email: user.email ?? '',
    rol: UserRole.cliente,
  );

  Exception _mapFirebaseException(FirebaseException e) {
    if (e.code == 'permission-denied') return PermissionException(e.message);
    return ServerException(e.message);
  }
}
