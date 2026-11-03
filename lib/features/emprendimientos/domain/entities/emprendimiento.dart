import 'package:equatable/equatable.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/producto.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/ubicacion.dart';

/// Entidad central de la app: un emprendimiento local.
///
/// Es inmutable: para "modificarlo" se crea una copia con [copyWith]. Esto
/// hace que Bloc detecte los cambios de estado de forma confiable.
class Emprendimiento extends Equatable {
  const Emprendimiento({
    required this.id,
    required this.ownerId,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.ubicacion,
    required this.municipio,
    this.fotos = const [],
    this.productos = const [],
  });

  /// Id vacío = todavía no se ha guardado en la base de datos.
  final String id;
  final String ownerId;
  final String nombre;
  final String descripcion;
  final Categoria categoria;
  final List<String> fotos;
  final Ubicacion ubicacion;
  final String municipio;
  final List<Producto> productos;

  bool get esNuevo => id.isEmpty;

  String? get fotoPrincipal => fotos.isEmpty ? null : fotos.first;

  bool perteneceA(String userId) => ownerId == userId;

  Emprendimiento copyWith({
    String? id,
    String? ownerId,
    String? nombre,
    String? descripcion,
    Categoria? categoria,
    List<String>? fotos,
    Ubicacion? ubicacion,
    String? municipio,
    List<Producto>? productos,
  }) {
    return Emprendimiento(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      fotos: fotos ?? this.fotos,
      ubicacion: ubicacion ?? this.ubicacion,
      municipio: municipio ?? this.municipio,
      productos: productos ?? this.productos,
    );
  }

  @override
  List<Object?> get props => [
    id,
    ownerId,
    nombre,
    descripcion,
    categoria,
    fotos,
    ubicacion,
    municipio,
    productos,
  ];
}
