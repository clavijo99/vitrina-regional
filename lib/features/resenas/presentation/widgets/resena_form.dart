import 'package:material_ui/material_ui.dart';

/// Formulario para escribir una reseña.
///
/// Esqueleto para el encuentro E3: hoy solo muestra un botón.
class ResenaForm extends StatelessWidget {
  const ResenaForm({super.key});

  // TODO(COIL-E3-1): Convertir en StatefulWidget con:
  //   - un selector de 1 a 5 estrellas (IconButton por estrella),
  //   - un TextField para el comentario (máx. Resena.maxComentario),
  //   - un botón "Publicar" que envíe al bloc:
  //       context.read<ResenasBloc>().add(ResenaAgregada(
  //         autorId: usuario.id, autorNombre: usuario.nombre,
  //         estrellas: estrellas, comentario: texto));
  //   (usuario = context.usuarioActual, ver auth_context_extension.dart)
  // TODO(COIL-E3-2): Con un BlocListener sobre `envioStatus` mostrar un
  // SnackBar de éxito/error y limpiar el formulario al publicar.
  // TODO(COIL-E3-6): Crear test/features/resenas/presentation/widgets/
  // resena_form_test.dart (testWidgets + MockBloc de bloc_test) que
  // verifique: sin estrellas no envía el evento; con 4 estrellas y texto
  // envía ResenaAgregada; con envioStatus success muestra el SnackBar.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Escribir reseña'),
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendiente: se construye en el encuentro E3.'),
          ),
        ),
      ),
    );
  }
}
