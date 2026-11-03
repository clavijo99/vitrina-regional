import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitrina_regional/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vitrina_regional/features/auth/presentation/pages/login_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc authBloc;

  setUpAll(() => registerFallbackValue(const AuthSignOutRequested()));

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(const AuthUnauthenticated());
  });

  Widget buildSubject() => BlocProvider<AuthBloc>.value(
    value: authBloc,
    child: const MaterialApp(home: LoginPage()),
  );

  testWidgets('muestra errores de validación y no envía el evento', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(find.text('El correo es obligatorio'), findsOneWidget);
    verifyNever(() => authBloc.add(any()));
  });

  testWidgets('con datos válidos envía AuthSignInRequested', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.co');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    verify(
      () => authBloc.add(
        const AuthSignInRequested(email: 'a@b.co', password: '123456'),
      ),
    ).called(1);
  });
}
