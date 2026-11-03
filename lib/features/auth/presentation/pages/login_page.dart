import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vitrina_regional/app/di/app_providers.dart';
import 'package:vitrina_regional/app/router/app_routes.dart';
import 'package:vitrina_regional/core/widgets/app_text_field.dart';
import 'package:vitrina_regional/core/widgets/primary_button.dart';
import 'package:vitrina_regional/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vitrina_regional/features/auth/presentation/cubit/login_form_cubit.dart';

/// Pantalla de inicio de sesión.
///
/// - LoginFormCubit (local a esta página) maneja los campos.
/// - AuthBloc (global) ejecuta el login. Al autenticarse NO navegamos a mano:
///   el redirect de go_router reacciona al nuevo estado y nos lleva a /home.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginFormCubit(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  void _submit(BuildContext context) {
    final formCubit = context.read<LoginFormCubit>();
    if (!formCubit.submit()) return;
    context.read<AuthBloc>().add(
      AuthSignInRequested(
        email: formCubit.state.email,
        password: formCubit.state.password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: BlocBuilder<LoginFormCubit, LoginFormState>(
                  builder: (context, form) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.storefront,
                          size: 72,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Vitrina Regional',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium,
                        ),
                        Text(
                          'Emprendimientos de Villavicencio y el Meta',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          label: 'Correo',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          errorText: form.emailError,
                          onChanged: context
                              .read<LoginFormCubit>()
                              .emailChanged,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Contraseña',
                          prefixIcon: Icons.lock_outline,
                          obscureText: form.obscurePassword,
                          errorText: form.passwordError,
                          onChanged: context
                              .read<LoginFormCubit>()
                              .passwordChanged,
                          suffixIcon: IconButton(
                            tooltip: 'Mostrar u ocultar contraseña',
                            icon: Icon(
                              form.obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: context
                                .read<LoginFormCubit>()
                                .toggleObscurePassword,
                          ),
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, authState) => PrimaryButton(
                            label: 'Ingresar',
                            icon: Icons.login,
                            isLoading: authState is AuthLoading,
                            onPressed: () => _submit(context),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.register),
                          child: const Text('¿No tienes cuenta? Regístrate'),
                        ),
                        if (useMockData) const _DemoCredentialsCard(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ayuda visible solo en modo mock: usuarios de prueba.
class _DemoCredentialsCard extends StatelessWidget {
  const _DemoCredentialsCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.only(top: 24),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Modo demo (sin Firebase)\n'
          'Emprendedor: emprendedor@demo.com\n'
          'Cliente: cliente@demo.com\n'
          'Contraseña: 123456',
        ),
      ),
    );
  }
}
