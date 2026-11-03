import 'package:material_ui/material_ui.dart';
import 'package:vitrina_regional/core/utils/formatters.dart';
import 'package:vitrina_regional/core/utils/validators.dart';
import 'package:vitrina_regional/core/widgets/app_network_image.dart';
import 'package:vitrina_regional/core/widgets/app_text_field.dart';
import 'package:vitrina_regional/core/widgets/primary_button.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/producto.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/ubicacion.dart';

/// Formulario para crear o editar un emprendimiento.
///
/// Es un widget "tonto": no conoce Blocs. Recibe el valor inicial y devuelve
/// el resultado por [onGuardar]. Así se puede reutilizar y probar fácilmente.
class EmprendimientoForm extends StatefulWidget {
  const EmprendimientoForm({
    required this.ownerId,
    required this.onGuardar,
    this.inicial,
    this.guardando = false,
    super.key,
  });

  final String ownerId;
  final Emprendimiento? inicial;
  final bool guardando;
  final ValueChanged<Emprendimiento> onGuardar;

  @override
  State<EmprendimientoForm> createState() => _EmprendimientoFormState();
}

class _EmprendimientoFormState extends State<EmprendimientoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _municipio;
  late final TextEditingController _latitud;
  late final TextEditingController _longitud;
  late Categoria _categoria;
  late List<Producto> _productos;

  @override
  void initState() {
    super.initState();
    final e = widget.inicial;
    final ubicacion = e?.ubicacion ?? Ubicacion.villavicencio;
    _nombre = TextEditingController(text: e?.nombre);
    _descripcion = TextEditingController(text: e?.descripcion);
    _municipio = TextEditingController(text: e?.municipio ?? 'Villavicencio');
    _latitud = TextEditingController(text: ubicacion.latitud.toString());
    _longitud = TextEditingController(text: ubicacion.longitud.toString());
    _categoria = e?.categoria ?? Categoria.gastronomia;
    _productos = [...?e?.productos];
  }

  @override
  void didUpdateWidget(covariant EmprendimientoForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Tras guardar, los productos vuelven con sus ids definitivos.
    final nuevo = widget.inicial;
    if (nuevo != null && nuevo != oldWidget.inicial) {
      _productos = [...nuevo.productos];
    }
  }

  @override
  void dispose() {
    for (final c in [_nombre, _descripcion, _municipio, _latitud, _longitud]) {
      c.dispose();
    }
    super.dispose();
  }

  double _parse(String texto) => double.parse(texto.replaceAll(',', '.'));

  void _guardar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final base = widget.inicial;
    widget.onGuardar(
      Emprendimiento(
        id: base?.id ?? '',
        ownerId: widget.ownerId,
        nombre: _nombre.text.trim(),
        descripcion: _descripcion.text.trim(),
        categoria: _categoria,
        municipio: _municipio.text.trim(),
        ubicacion: Ubicacion(
          latitud: _parse(_latitud.text),
          longitud: _parse(_longitud.text),
        ),
        fotos: base?.fotos ?? const [],
        productos: _productos,
      ),
    );
  }

  Future<void> _agregarProducto() async {
    final producto = await showDialog<Producto>(
      context: context,
      builder: (_) => const _ProductoDialog(),
    );
    if (producto == null || !mounted) return;
    setState(() => _productos = [..._productos, producto]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fotos = widget.inicial?.fotos ?? const <String>[];
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppTextField(
            label: 'Nombre del emprendimiento',
            controller: _nombre,
            prefixIcon: Icons.storefront_outlined,
            validator: Validators.nombre,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Descripción',
            controller: _descripcion,
            maxLines: 3,
            validator: (v) =>
                (v ?? '').trim().length < 10 ? 'Mínimo 10 caracteres' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Categoria>(
            initialValue: _categoria,
            decoration: const InputDecoration(labelText: 'Categoría'),
            items: [
              for (final c in Categoria.values)
                DropdownMenuItem(value: c, child: Text(c.label)),
            ],
            onChanged: (c) => setState(() => _categoria = c ?? _categoria),
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Municipio',
            controller: _municipio,
            prefixIcon: Icons.location_city_outlined,
            validator: (v) => Validators.requerido(v, campo: 'El municipio'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Latitud',
                  controller: _latitud,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  validator: Validators.latitud,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Longitud',
                  controller: _longitud,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  validator: Validators.longitud,
                ),
              ),
            ],
          ),
          // TODO(COIL-E4-5): Botón "Usar mi ubicación actual" que llene
          // latitud/longitud con el caso de uso GetUbicacionActual.
          const SizedBox(height: 24),
          Text('Fotos', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final foto in fotos)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppNetworkImage(url: foto, width: 120, height: 90),
                    ),
                  ),
                // TODO(COIL-E4-3): Habilitar este botón con SubirImagenCubit.
                const OutlinedButton(
                  onPressed: null,
                  child: Text('+ Foto\n(E4)', textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Productos', style: theme.textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: _agregarProducto,
                icon: const Icon(Icons.add),
                label: const Text('Agregar'),
              ),
            ],
          ),
          for (final producto in _productos)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(producto.nombre),
              subtitle: Text(Formatters.precio(producto.precio)),
              trailing: IconButton(
                tooltip: 'Quitar producto',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(
                  () => _productos = [..._productos]..remove(producto),
                ),
              ),
            ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: widget.inicial == null ? 'Crear emprendimiento' : 'Guardar',
            icon: Icons.save_outlined,
            isLoading: widget.guardando,
            onPressed: _guardar,
          ),
        ],
      ),
    );
  }
}

/// Diálogo para capturar un producto nuevo.
class _ProductoDialog extends StatefulWidget {
  const _ProductoDialog();

  @override
  State<_ProductoDialog> createState() => _ProductoDialogState();
}

class _ProductoDialogState extends State<_ProductoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _precio = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    super.dispose();
  }

  void _aceptar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      Producto(
        id: '',
        nombre: _nombre.text.trim(),
        precio: double.parse(_precio.text.replaceAll(',', '.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo producto'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Nombre',
              controller: _nombre,
              validator: Validators.nombre,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Precio (COP)',
              controller: _precio,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: Validators.precio,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _aceptar, child: const Text('Agregar')),
      ],
    );
  }
}
