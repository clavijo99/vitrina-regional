import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:vitrina_regional/features/emprendimientos/data/datasources/emprendimiento_remote_datasource.dart';
import 'package:vitrina_regional/features/emprendimientos/data/models/emprendimiento_model.dart';
import 'package:vitrina_regional/features/emprendimientos/data/models/producto_model.dart';

/// Datasource en memoria con 6 emprendimientos de ejemplo de Villavicencio y
/// el Meta. Permite trabajar el primer día sin configurar Firebase.
///
/// Los cambios (crear/editar) se pierden al reiniciar la app.
class MockEmprendimientoDataSource implements EmprendimientoDataSource {
  MockEmprendimientoDataSource({
    this.latency = const Duration(milliseconds: 400),
    List<EmprendimientoModel>? seed,
  }) : _items = {for (final e in seed ?? _semilla) e.id: e};

  final Duration latency;
  final Map<String, EmprendimientoModel> _items;
  int _secuencia = 0;

  @override
  Future<List<EmprendimientoModel>> getAll() async {
    await Future<void>.delayed(latency);
    return _ordenados(_items.values);
  }

  @override
  Future<EmprendimientoModel> getById(String id) async {
    await Future<void>.delayed(latency);
    final item = _items[id];
    if (item == null) throw NotFoundException('Emprendimiento $id no existe');
    return item;
  }

  @override
  Future<EmprendimientoModel?> getByOwner(String ownerId) async {
    await Future<void>.delayed(latency);
    for (final item in _items.values) {
      if (item.ownerId == ownerId) return item;
    }
    return null;
  }

  @override
  Future<List<EmprendimientoModel>> getByCategoria(String categoria) async {
    await Future<void>.delayed(latency);
    return _ordenados(_items.values.where((e) => e.categoria == categoria));
  }

  @override
  Future<EmprendimientoModel> create(EmprendimientoModel model) async {
    await Future<void>.delayed(latency);
    final id = 'mock-emp-${++_secuencia}';
    final creado = model.copyWith(id: id, productos: _conIds(model.productos));
    _items[id] = creado;
    return creado;
  }

  @override
  Future<EmprendimientoModel> update(EmprendimientoModel model) async {
    await Future<void>.delayed(latency);
    if (!_items.containsKey(model.id)) {
      throw NotFoundException('Emprendimiento ${model.id} no existe');
    }
    final actualizado = model.copyWith(productos: _conIds(model.productos));
    _items[model.id] = actualizado;
    return actualizado;
  }

  List<ProductoModel> _conIds(List<ProductoModel> productos) => [
    for (final p in productos)
      p.id.isNotEmpty
          ? p
          : ProductoModel(
              id: 'mock-prod-${++_secuencia}',
              nombre: p.nombre,
              precio: p.precio,
              descripcion: p.descripcion,
              fotoUrl: p.fotoUrl,
            ),
  ];

  List<EmprendimientoModel> _ordenados(Iterable<EmprendimientoModel> items) =>
      items.toList()..sort((a, b) => a.nombre.compareTo(b.nombre));

  static String _foto(String semilla) =>
      'https://picsum.photos/seed/$semilla/800/600';

  // TODO(COIL-E1-4): Agreguen un emprendimiento real de su municipio
  // (pidan permiso al emprendedor) siguiendo el mismo formato.
  static final List<EmprendimientoModel> _semilla = [
    EmprendimientoModel(
      id: 'emp-cafe-llanero',
      ownerId: kDemoEmprendedorId,
      nombre: 'Café de Origen Llanero',
      descripcion:
          'Café especial cultivado en el piedemonte llanero, tostado '
          'artesanalmente en Villavicencio.',
      categoria: 'gastronomia',
      fotos: [_foto('cafe-llanero'), _foto('cafe-taza')],
      latitud: 4.1533,
      longitud: -73.6350,
      municipio: 'Villavicencio',
      productos: const [
        ProductoModel(id: 'p1', nombre: 'Café molido 500 g', precio: 28000),
        ProductoModel(id: 'p2', nombre: 'Café en grano 1 kg', precio: 52000),
        ProductoModel(id: 'p3', nombre: 'Tinto campesino', precio: 3000),
      ],
    ),
    EmprendimientoModel(
      id: 'emp-mamona',
      ownerId: 'owner-mamona',
      nombre: 'Asadero La Mamona Dorada',
      descripcion:
          'Ternera a la llanera asada por 8 horas al estilo tradicional, '
          'con yuca, papa salada y guarapo.',
      categoria: 'gastronomia',
      fotos: [_foto('mamona-llanera')],
      latitud: 4.1290,
      longitud: -73.6100,
      municipio: 'Villavicencio',
      productos: const [
        ProductoModel(id: 'p4', nombre: 'Porción de mamona', precio: 35000),
        ProductoModel(id: 'p5', nombre: 'Guarapo de la casa', precio: 6000),
      ],
    ),
    EmprendimientoModel(
      id: 'emp-moriche',
      ownerId: 'owner-moriche',
      nombre: 'Artesanías Moriche',
      descripcion:
          'Bolsos, sombreros y canastos tejidos a mano con fibra de palma '
          'de moriche por artesanas de la región.',
      categoria: 'artesanias',
      fotos: [_foto('moriche-tejido')],
      latitud: 4.0896,
      longitud: -72.9616,
      municipio: 'Puerto López',
      productos: const [
        ProductoModel(id: 'p6', nombre: 'Bolso de moriche', precio: 85000),
        ProductoModel(id: 'p7', nombre: 'Sombrero llanero', precio: 120000),
      ],
    ),
    EmprendimientoModel(
      id: 'emp-cano-cristales',
      ownerId: 'owner-macarena',
      nombre: 'Ecoturismo Raudal Macarena',
      descripcion:
          'Guianza certificada a Caño Cristales y la Serranía de La '
          'Macarena con operadores locales.',
      categoria: 'turismo',
      fotos: [_foto('cano-cristales')],
      latitud: 2.1803,
      longitud: -73.7867,
      municipio: 'La Macarena',
      productos: const [
        ProductoModel(id: 'p8', nombre: 'Tour 1 día', precio: 180000),
        ProductoModel(id: 'p9', nombre: 'Plan 3 días', precio: 950000),
      ],
    ),
    EmprendimientoModel(
      id: 'emp-cacao-ariari',
      ownerId: 'owner-ariari',
      nombre: 'Cacao del Ariari',
      descripcion:
          'Chocolate de mesa y nibs de cacao fino de aroma producidos por '
          'familias campesinas de Granada, Meta.',
      categoria: 'agro',
      fotos: [_foto('cacao-ariari')],
      latitud: 3.5460,
      longitud: -73.7065,
      municipio: 'Granada',
      productos: const [
        ProductoModel(id: 'p10', nombre: 'Chocolate de mesa', precio: 12000),
        ProductoModel(id: 'p11', nombre: 'Nibs de cacao 250 g', precio: 18000),
      ],
    ),
    EmprendimientoModel(
      id: 'emp-tejidos-sikuani',
      ownerId: 'owner-sikuani',
      nombre: 'Tejidos Sikuani',
      descripcion:
          'Prendas y accesorios con diseños tradicionales del pueblo '
          'Sikuani, elaborados en Puerto Gaitán.',
      categoria: 'moda',
      fotos: [_foto('tejidos-sikuani')],
      latitud: 4.3133,
      longitud: -72.0820,
      municipio: 'Puerto Gaitán',
      productos: const [
        ProductoModel(id: 'p12', nombre: 'Mochila tejida', precio: 95000),
        ProductoModel(id: 'p13', nombre: 'Manilla artesanal', precio: 15000),
      ],
    ),
    EmprendimientoModel(
      id: 'emp-doña-rosa',
      ownerId: 'owner-rosa',
      nombre: 'Arepas Doña rosa',
      descripcion:
          'Ventas de arepas doña rosa'
          'Boliva, elaborados en Villavicencio.',
      categoria: 'gastronomia',
      fotos: [_foto('arepas-doña-rosa')],
      latitud: 4.3133,
      longitud: -72.0820,
      municipio: 'Villavicencio',
      productos: const [
        ProductoModel(id: 'p14', nombre: 'Carne', precio: 9500),
        ProductoModel(id: 'p15', nombre: 'Pollo', precio: 1500),
      ],
    ),
  ];
}
