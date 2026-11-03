import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_regional/core/error/failures.dart';
import 'package:vitrina_regional/core/usecase/usecase.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';
import 'package:vitrina_regional/features/auth/domain/usecases/sign_in.dart';
import 'package:vitrina_regional/features/auth/domain/usecases/sign_out.dart';
import 'package:vitrina_regional/features/auth/domain/usecases/sign_up.dart';
import 'package:vitrina_regional/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:vitrina_regional/features/auth/presentation/bloc/auth_bloc.dart';

import '../../../../helpers/fixtures.dart';

class MockWatchAuthState extends Mock implements WatchAuthState {}

class MockSignIn extends Mock implements SignIn {}

class MockSignUp extends Mock implements SignUp {}

class MockSignOut extends Mock implements SignOut {}

void main() {
  late MockWatchAuthState watchAuthState;
  late MockSignIn signIn;
  late MockSignUp signUp;
  late MockSignOut signOut;

  setUpAll(() {
    // mocktail necesita un valor "de relleno" para usar any() con estos tipos.
    registerFallbackValue(const SignInParams(email: '', password: ''));
    registerFallbackValue(
      const SignUpParams(
        nombre: '',
        email: '',
        password: '',
        rol: UserRole.cliente,
      ),
    );
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    watchAuthState = MockWatchAuthState();
    signIn = MockSignIn();
    signUp = MockSignUp();
    signOut = MockSignOut();
  });

  AuthBloc buildBloc() => AuthBloc(
    watchAuthState: watchAuthState,
    signIn: signIn,
    signUp: signUp,
    signOut: signOut,
  );

  test('el estado inicial es AuthInitial', () {
    expect(buildBloc().state, const AuthInitial());
  });

  blocTest<AuthBloc, AuthState>(
    'AuthSubscriptionRequested emite Authenticated/Unauthenticated según el '
    'stream de sesión',
    setUp: () =>
        when(() => watchAuthState(any()))
            .thenAnswer((_) => Stream.fromIterable([Fixtures.cliente, null])),
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthSubscriptionRequested()),
    expect: () => const [
      AuthAuthenticated(Fixtures.cliente),
      AuthUnauthenticated(),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'login exitoso emite [Loading, Authenticated]',
    setUp: () =>
        when(() => signIn(any()))
            .thenAnswer((_) async => const Right(Fixtures.emprendedor)),
    build: buildBloc,
    act: (bloc) => bloc.add(
      const AuthSignInRequested(email: 'laura@test.com', password: '123456'),
    ),
    expect: () => const [
      AuthLoading(),
      AuthAuthenticated(Fixtures.emprendedor),
    ],
    verify: (_) => verify(
      () => signIn(
        const SignInParams(email: 'laura@test.com', password: '123456'),
      ),
    ).called(1),
  );

  blocTest<AuthBloc, AuthState>(
    'login fallido emite [Loading, AuthError]',
    setUp: () => when(() => signIn(any()))
        .thenAnswer((_) async => const Left(AuthFailure('Credenciales malas'))),
    build: buildBloc,
    act: (bloc) =>
        bloc.add(const AuthSignInRequested(email: 'a@b.co', password: 'x')),
    expect: () => const [AuthLoading(), AuthError('Credenciales malas')],
  );

  blocTest<AuthBloc, AuthState>(
    'registro exitoso emite [Loading, Authenticated]',
    setUp: () =>
        when(() => signUp(any()))
            .thenAnswer((_) async => const Right(Fixtures.cliente)),
    build: buildBloc,
    act: (bloc) => bloc.add(
      const AuthSignUpRequested(
        nombre: 'Carlos',
        email: 'carlos@test.com',
        password: '123456',
        rol: UserRole.cliente,
      ),
    ),
    expect: () => const [AuthLoading(), AuthAuthenticated(Fixtures.cliente)],
  );

  blocTest<AuthBloc, AuthState>(
    'logout emite [Loading, Unauthenticated]',
    setUp: () =>
        when(() => signOut(any())).thenAnswer((_) async => const Right(unit)),
    build: buildBloc,
    act: (bloc) => bloc.add(const AuthSignOutRequested()),
    expect: () => const [AuthLoading(), AuthUnauthenticated()],
  );
}
