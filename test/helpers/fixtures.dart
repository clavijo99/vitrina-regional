import 'package:vitrina_regional/features/auth/domain/entities/app_user.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/categoria.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/producto.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/ubicacion.dart';
import 'package:vitrina_regional/features/resenas/domain/entities/resena.dart';

/// Datos de prueba compartidos por los tests.
abstract final class Fixtures {
  static const emprendedor = AppUser(
    id: 'u1',
    nombre: 'Laura',
    email: 'laura@test.com',
    rol: UserRole.emprendedor,
  );

  static const cliente = AppUser(
    id: 'u2',
    nombre: 'Carlos',
    email: 'carlos@test.com',
    rol: UserRole.cliente,
  );

  static const cafe = Emprendimiento(
    id: 'e1',
    ownerId: 'u1',
    nombre: 'Café Llanero',
    descripcion: 'Café especial del piedemonte llanero.',
    categoria: Categoria.gastronomia,
    ubicacion: Ubicacion(latitud: 4.1533, longitud: -73.6350),
    municipio: 'Villavicencio',
    productos: [Producto(id: 'p1', nombre: 'Café 500 g', precio: 28000)],
  );

  static const cacao = Emprendimiento(
    id: 'e2',
    ownerId: 'u3',
    nombre: 'Cacao del Ariari',
    descripcion: 'Chocolate de mesa de Granada, Meta.',
    categoria: Categoria.agro,
    ubicacion: Ubicacion(latitud: 3.5460, longitud: -73.7065),
    municipio: 'Granada',
  );

  static final resena = Resena(
    id: 'r1',
    emprendimientoId: 'e1',
    autorId: 'u2',
    autorNombre: 'Carlos',
    estrellas: 5,
    comentario: 'Excelente',
    fecha: DateTime(2026, 10, 1),
  );
}
