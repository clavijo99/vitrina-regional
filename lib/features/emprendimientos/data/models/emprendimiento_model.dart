import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitrina_regional/features/emprendimientos/data/models/producto_model.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/ubicacion.dart';

/// Modelo de Emprendimiento (documento de la colección `emprendimientos`).
///
/// Estructura en Firestore:
/// ```
/// emprendimientos/{id}
///   ownerId, nombre, descripcion, categoria, fotos[], municipio,
///   ubicacion: { lat, lng }, actualizadoEn
///   productos/{productoId}  <- subcolección
/// ```
class EmprendimientoModel {
  const EmprendimientoModel({
    required this.id,
    required this.ownerId,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.latitud,
    required this.longitud,
    required this.municipio,
    this.fotos = const [],
    this.productos = const [],
  });

  factory EmprendimientoModel.fromMap(
    String id,
    Map<String, dynamic> map, {
    List<ProductoModel> productos = const [],
  }) {
    final ubicacion = map['ubicacion'] as Map<String, dynamic>? ?? const {};
    return EmprendimientoModel(
      id: id,
      ownerId: map['ownerId'] as String? ?? '',
      nombre: map['nombre'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
      categoria: map['categoria'] as String? ?? Categoria.servicios.name,
      fotos: (map['fotos'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      latitud: (ubicacion['lat'] as num? ?? 0).toDouble(),
      longitud: (ubicacion['lng'] as num? ?? 0).toDouble(),
      municipio: map['municipio'] as String? ?? '',
      productos: productos,
    );
  }

  factory EmprendimientoModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    List<ProductoModel> productos = const [],
  }) => EmprendimientoModel.fromMap(
    doc.id,
    doc.data() ?? const {},
    productos: productos,
  );

  factory EmprendimientoModel.fromEntity(Emprendimiento e) {
    return EmprendimientoModel(
      id: e.id,
      ownerId: e.ownerId,
      nombre: e.nombre,
      descripcion: e.descripcion,
      categoria: e.categoria.name,
      fotos: e.fotos,
      latitud: e.ubicacion.latitud,
      longitud: e.ubicacion.longitud,
      municipio: e.municipio,
      productos: e.productos.map(ProductoModel.fromEntity).toList(),
    );
  }

  final String id;
  final String ownerId;
  final String nombre;
  final String descripcion;
  final String categoria;
  final List<String> fotos;
  final double latitud;
  final double longitud;
  final String municipio;
  final List<ProductoModel> productos;

  /// Los productos NO van aquí: se guardan en la subcolección.
  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'nombre': nombre,
    'descripcion': descripcion,
    'categoria': categoria,
    'fotos': fotos,
    'ubicacion': {'lat': latitud, 'lng': longitud},
    'municipio': municipio,
  };

  EmprendimientoModel copyWith({String? id, List<ProductoModel>? productos}) {
    return EmprendimientoModel(
      id: id ?? this.id,
      ownerId: ownerId,
      nombre: nombre,
      descripcion: descripcion,
      categoria: categoria,
      fotos: fotos,
      latitud: latitud,
      longitud: longitud,
      municipio: municipio,
      productos: productos ?? this.productos,
    );
  }

  Emprendimiento toEntity() => Emprendimiento(
    id: id,
    ownerId: ownerId,
    nombre: nombre,
    descripcion: descripcion,
    categoria: Categoria.fromName(categoria),
    fotos: fotos,
    ubicacion: Ubicacion(latitud: latitud, longitud: longitud),
    municipio: municipio,
    productos: productos.map((p) => p.toEntity()).toList(),
  );
}
