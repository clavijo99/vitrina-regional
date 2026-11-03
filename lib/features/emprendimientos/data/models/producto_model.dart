import 'package:vitrina_regional/features/emprendimientos/domain/entities/producto.dart';

/// Modelo de Producto (documento de `emprendimientos/{id}/productos/{pid}`).
class ProductoModel {
  const ProductoModel({
    required this.id,
    required this.nombre,
    required this.precio,
    this.descripcion = '',
    this.fotoUrl,
  });

  factory ProductoModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductoModel(
      id: id,
      nombre: map['nombre'] as String? ?? '',
      // Firestore puede devolver int o double: `num` cubre ambos.
      precio: (map['precio'] as num? ?? 0).toDouble(),
      descripcion: map['descripcion'] as String? ?? '',
      fotoUrl: map['fotoUrl'] as String?,
    );
  }

  factory ProductoModel.fromEntity(Producto p) => ProductoModel(
    id: p.id,
    nombre: p.nombre,
    precio: p.precio,
    descripcion: p.descripcion,
    fotoUrl: p.fotoUrl,
  );

  final String id;
  final String nombre;
  final double precio;
  final String descripcion;
  final String? fotoUrl;

  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'precio': precio,
    'descripcion': descripcion,
    'fotoUrl': fotoUrl,
  };

  Producto toEntity() => Producto(
    id: id,
    nombre: nombre,
    precio: precio,
    descripcion: descripcion,
    fotoUrl: fotoUrl,
  );
}
