import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitrina_regional/features/resenas/domain/entities/resena.dart';

/// Modelo de la colección `resenas` (colección raíz, filtrada por
/// `emprendimientoId`, para poder consultar todas las reseñas de un autor).
class ResenaModel {
  const ResenaModel({
    required this.id,
    required this.emprendimientoId,
    required this.autorId,
    required this.autorNombre,
    required this.estrellas,
    required this.comentario,
    required this.fecha,
  });

  factory ResenaModel.fromMap(String id, Map<String, dynamic> map) {
    return ResenaModel(
      id: id,
      emprendimientoId: map['emprendimientoId'] as String? ?? '',
      autorId: map['autorId'] as String? ?? '',
      autorNombre: map['autorNombre'] as String? ?? 'Anónimo',
      estrellas: (map['estrellas'] as num? ?? 0).toInt(),
      comentario: map['comentario'] as String? ?? '',
      fecha: _parseFecha(map['fecha']),
    );
  }

  factory ResenaModel.fromEntity(Resena r) => ResenaModel(
    id: r.id,
    emprendimientoId: r.emprendimientoId,
    autorId: r.autorId,
    autorNombre: r.autorNombre,
    estrellas: r.estrellas,
    comentario: r.comentario,
    fecha: r.fecha,
  );

  final String id;
  final String emprendimientoId;
  final String autorId;
  final String autorNombre;
  final int estrellas;
  final String comentario;
  final DateTime fecha;

  Map<String, dynamic> toMap() => {
    'emprendimientoId': emprendimientoId,
    'autorId': autorId,
    'autorNombre': autorNombre,
    'estrellas': estrellas,
    'comentario': comentario,
    'fecha': Timestamp.fromDate(fecha),
  };

  Resena toEntity() => Resena(
    id: id,
    emprendimientoId: emprendimientoId,
    autorId: autorId,
    autorNombre: autorNombre,
    estrellas: estrellas,
    comentario: comentario,
    fecha: fecha,
  );

  /// Con `serverTimestamp()` la fecha llega `null` en el primer snapshot
  /// local (antes de que responda el servidor): usamos "ahora" mientras tanto.
  static DateTime _parseFecha(Object? value) => switch (value) {
    Timestamp() => value.toDate(),
    DateTime() => value,
    _ => DateTime.now(),
  };
}
