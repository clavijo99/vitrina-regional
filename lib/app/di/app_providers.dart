import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitrina_regional/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:vitrina_regional/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:vitrina_regional/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vitrina_regional/features/auth/domain/repositories/auth_repository.dart';
import 'package:vitrina_regional/features/auth/domain/usecases/sign_in.dart';
import 'package:vitrina_regional/features/auth/domain/usecases/sign_out.dart';
import 'package:vitrina_regional/features/auth/domain/usecases/sign_up.dart';
import 'package:vitrina_regional/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:vitrina_regional/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vitrina_regional/features/emprendimientos/data/datasources/emprendimiento_mock_datasource.dart';
import 'package:vitrina_regional/features/emprendimientos/data/datasources/emprendimiento_remote_datasource.dart';
import 'package:vitrina_regional/features/emprendimientos/data/repositories/emprendimiento_repository_impl.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/repositories/emprendimiento_repository.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/create_emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/get_emprendimiento_by_id.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/get_emprendimiento_by_owner.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/get_emprendimientos.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/search_by_categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/usecases/update_emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/presentation/bloc/emprendimientos_bloc.dart';
import 'package:vitrina_regional/features/imagenes/data/datasources/imagen_picker_datasource.dart';
import 'package:vitrina_regional/features/imagenes/data/datasources/imagen_storage_datasource.dart';
import 'package:vitrina_regional/features/imagenes/data/repositories/imagen_repository_impl.dart';
import 'package:vitrina_regional/features/imagenes/domain/repositories/imagen_repository.dart';
import 'package:vitrina_regional/features/imagenes/domain/usecases/seleccionar_imagen.dart';
import 'package:vitrina_regional/features/imagenes/domain/usecases/subir_imagen.dart';
import 'package:vitrina_regional/features/mapa/data/datasources/location_datasource.dart';
import 'package:vitrina_regional/features/mapa/data/repositories/location_repository_impl.dart';
import 'package:vitrina_regional/features/mapa/domain/repositories/location_repository.dart';
import 'package:vitrina_regional/features/mapa/domain/usecases/get_ubicacion_actual.dart';
import 'package:vitrina_regional/features/mapa/domain/usecases/ordenar_por_cercania.dart';
import 'package:vitrina_regional/features/resenas/data/datasources/resena_mock_datasource.dart';
import 'package:vitrina_regional/features/resenas/data/datasources/resena_remote_datasource.dart';
import 'package:vitrina_regional/features/resenas/data/repositories/resena_repository_impl.dart';
import 'package:vitrina_regional/features/resenas/domain/repositories/resena_repository.dart';
import 'package:vitrina_regional/features/resenas/domain/usecases/add_resena.dart';
import 'package:vitrina_regional/features/resenas/domain/usecases/watch_resenas.dart';

/// `true`: la app usa datasources en memoria (sin Firebase).
/// `false`: usa Firebase (requiere `flutterfire configure`, ver README).
///
/// Es el ÚNICO interruptor que hay que tocar para cambiar de backend: gracias
/// a Clean Architecture, ni los Blocs ni las pantallas se enteran.
const bool useMockData = !bool.fromEnvironment('USE_FIREBASE');

/// Raíz de composición (composition root): aquí, y SOLO aquí, se decide qué
/// implementación concreta recibe cada contrato. No usamos get_it: todo se
/// inyecta con el patrón provider de flutter_bloc.
///
/// Orden: datasources -> repositorios -> casos de uso -> blocs globales.
/// Cada `create` puede leer (`context.read`) lo declarado ANTES que él.
/// Los blocs de una sola pantalla se crean en esa pantalla, no aquí.
class AppProviders extends StatelessWidget {
  const AppProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // ---------------- 1. Datasources (mock o Firebase) ----------------
        RepositoryProvider<AuthDataSource>(
          create: (_) => useMockData
              ? MockAuthDataSource()
              : FirebaseAuthRemoteDataSource(
                  auth: FirebaseAuth.instance,
                  firestore: FirebaseFirestore.instance,
                ),
        ),
        RepositoryProvider<EmprendimientoDataSource>(
          create: (_) => useMockData
              ? MockEmprendimientoDataSource()
              : FirestoreEmprendimientoDataSource(FirebaseFirestore.instance),
        ),
        RepositoryProvider<ResenaDataSource>(
          create: (_) => useMockData
              ? MockResenaDataSource()
              : FirestoreResenaDataSource(FirebaseFirestore.instance),
        ),
        RepositoryProvider<LocationDataSource>(
          create: (_) => useMockData
              ? const MockLocationDataSource()
              : const GeolocatorLocationDataSource(),
        ),
        RepositoryProvider<ImagenPickerDataSource>(
          create: (_) => ImagePickerDataSource(),
        ),
        RepositoryProvider<ImagenStorageDataSource>(
          create: (_) => useMockData
              ? const MockImagenStorageDataSource()
              : const CloudinaryImagenStorageDataSource(),
        ),

        // ---------------- 2. Repositorios (contratos de domain) -----------
        RepositoryProvider<AuthRepository>(
          create: (context) =>
              AuthRepositoryImpl(context.read<AuthDataSource>()),
        ),
        RepositoryProvider<EmprendimientoRepository>(
          create: (context) => EmprendimientoRepositoryImpl(
            context.read<EmprendimientoDataSource>(),
          ),
        ),
        RepositoryProvider<ResenaRepository>(
          create: (context) =>
              ResenaRepositoryImpl(context.read<ResenaDataSource>()),
        ),
        RepositoryProvider<LocationRepository>(
          create: (context) =>
              LocationRepositoryImpl(context.read<LocationDataSource>()),
        ),
        RepositoryProvider<ImagenRepository>(
          create: (context) => ImagenRepositoryImpl(
            picker: context.read<ImagenPickerDataSource>(),
            storage: context.read<ImagenStorageDataSource>(),
          ),
        ),

        // ---------------- 3. Casos de uso ----------------------------------
        // auth
        RepositoryProvider(
          create: (context) => WatchAuthState(context.read<AuthRepository>()),
        ),
        RepositoryProvider(
          create: (context) => SignIn(context.read<AuthRepository>()),
        ),
        RepositoryProvider(
          create: (context) => SignUp(context.read<AuthRepository>()),
        ),
        RepositoryProvider(
          create: (context) => SignOut(context.read<AuthRepository>()),
        ),
        // emprendimientos
        RepositoryProvider(
          create: (context) =>
              GetEmprendimientos(context.read<EmprendimientoRepository>()),
        ),
        RepositoryProvider(
          create: (context) =>
              GetEmprendimientoById(context.read<EmprendimientoRepository>()),
        ),
        RepositoryProvider(
          create: (context) => GetEmprendimientoByOwner(
            context.read<EmprendimientoRepository>(),
          ),
        ),
        RepositoryProvider(
          create: (context) =>
              SearchByCategoria(context.read<EmprendimientoRepository>()),
        ),
        RepositoryProvider(
          create: (context) =>
              CreateEmprendimiento(context.read<EmprendimientoRepository>()),
        ),
        RepositoryProvider(
          create: (context) =>
              UpdateEmprendimiento(context.read<EmprendimientoRepository>()),
        ),
        // resenas
        RepositoryProvider(
          create: (context) => WatchResenas(context.read<ResenaRepository>()),
        ),
        RepositoryProvider(
          create: (context) => AddResena(context.read<ResenaRepository>()),
        ),
        // mapa
        RepositoryProvider(
          create: (context) =>
              GetUbicacionActual(context.read<LocationRepository>()),
        ),
        RepositoryProvider(create: (_) => const OrdenarPorCercania()),
        // imagenes
        RepositoryProvider(
          create: (context) =>
              SeleccionarImagen(context.read<ImagenRepository>()),
        ),
        RepositoryProvider(
          create: (context) => SubirImagen(context.read<ImagenRepository>()),
        ),
      ],
      // ---------------- 4. Blocs globales -------------------------------
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              watchAuthState: context.read(),
              signIn: context.read(),
              signUp: context.read(),
              signOut: context.read(),
            )..add(const AuthSubscriptionRequested()),
          ),
          BlocProvider(
            create: (context) => EmprendimientosBloc(
              getEmprendimientos: context.read(),
              searchByCategoria: context.read(),
            )..add(const EmprendimientosRequested()),
          ),
        ],
        child: child,
      ),
    );
  }
}
