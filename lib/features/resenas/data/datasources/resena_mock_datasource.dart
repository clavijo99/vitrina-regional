import 'dart:async';

import 'package:vitrina_regional/features/resenas/data/datasources/resena_remote_datasource.dart';
import 'package:vitrina_regional/features/resenas/data/models/resena_model.dart';

/// Reseñas en memoria que SIMULAN el tiempo real con un StreamController.
///
/// Abre el mismo emprendimiento en dos pantallas (o agrega una reseña) y
/// verás la lista actualizarse sola, igual que con Firestore.
class MockResenaDataSource implements ResenaDataSource {
  MockResenaDataSource({List<ResenaModel>? seed})
    : _resenas = [...(seed ?? _semilla())];

  final List<ResenaModel> _resenas;
  final StreamController<void> _cambios = StreamController<void>.broadcast();
  int _secuencia = 0;

  @override
  Stream<List<ResenaModel>> watchResenas(String emprendimientoId) async* {
    yield _de(emprendimientoId);
    await for (final _ in _cambios.stream) {
      yield _de(emprendimientoId);
    }
  }

  @override
  Future<void> addResena(ResenaModel resena) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _resenas.add(
      ResenaModel(
        id: 'mock-resena-${++_secuencia}',
        emprendimientoId: resena.emprendimientoId,
        autorId: resena.autorId,
        autorNombre: resena.autorNombre,
        estrellas: resena.estrellas,
        comentario: resena.comentario,
        fecha: DateTime.now(),
      ),
    );
    _cambios.add(null);
  }

  List<ResenaModel> _de(String emprendimientoId) =>
      _resenas.where((r) => r.emprendimientoId == emprendimientoId).toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha));

  Future<void> dispose() => _cambios.close();

  static List<ResenaModel> _semilla() => [
    ResenaModel(
      id: 'r1',
      emprendimientoId: 'emp-cafe-llanero',
      autorId: 'demo-cliente',
      autorNombre: 'Carlos Cliente',
      estrellas: 5,
      comentario: 'El mejor café de Villavicencio, muy buena atención.',
      fecha: DateTime(2026, 10, 20),
    ),
    ResenaModel(
      id: 'r2',
      emprendimientoId: 'emp-mamona',
      autorId: 'otro-cliente',
      autorNombre: 'Ana',
      estrellas: 4,
      comentario: 'Mamona deliciosa, aunque hubo que esperar un poco.',
      fecha: DateTime(2026, 10, 25),
    ),
  ];
}
