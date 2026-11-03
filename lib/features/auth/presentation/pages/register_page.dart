import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vitrina_regional/app/router/app_routes.dart';
import 'package:vitrina_regional/core/utils/validators.dart';
import 'package:vitrina_regional/core/widgets/app_text_field.dart';
import 'package:vitrina_regional/core/widgets/primary_button.dart';
import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';
import 'package:vitrina_regional/features/auth/presentation/bloc/auth_bloc.dart';

/// Registro de usuario con selección de rol.
///
/// Aquí usamos un `Form` clásico con `GlobalKey` (en login usamos un Cubit)
/// para que el equipo compare ambos enfoques.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _rol = UserRole.cliente;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        nombre: _nombreController.text,
        email: _emailController.text,
        password: _passwordController.text,
        rol: _rol,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear cuenta'),
          leading: BackButton(onPressed: () => context.go(AppRoutes.login)),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '¿Cómo usarás la app?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<UserRole>(
                        segments: const [
                          ButtonSegment(
                            value: UserRole.cliente,
                            icon: Icon(Icons.person_search),
                            label: Text('Cliente'),
                          ),
                          ButtonSegment(
                            value: UserRole.emprendedor,
                            icon: Icon(Icons.storefront),
                            label: Text('Emprendedor'),
                          ),
                        ],
                        selected: {_rol},
                        onSelectionChanged: (seleccion) =>
                            setState(() => _rol = seleccion.first),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: 'Nombre completo',
                        controller: _nombreController,
                        prefixIcon: Icons.badge_outlined,
                        textInputAction: TextInputAction.next,
                        validator: Validators.nombre,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Correo',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Contraseña',
                        controller: _passwordController,
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        validator: Validators.password,
                      ),
                      // TODO(COIL-E1-3): Agregar un campo "Confirmar contraseña"
                      // que valide que coincide con la anterior.
                      const SizedBox(height: 24),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) => PrimaryButton(
                          label: 'Crear cuenta',
                          icon: Icons.person_add_alt_1,
                          isLoading: state is AuthLoading,
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
