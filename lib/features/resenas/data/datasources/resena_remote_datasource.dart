import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/features/resenas/data/models/resena_model.dart';

/// Contrato del datasource de reseñas.
abstract interface class ResenaDataSource {
  Stream<List<ResenaModel>> watchResenas(String emprendimientoId);

  Future<void> addResena(ResenaModel resena);
}

/// Implementación en tiempo real con `snapshots()` de Firestore.
///
/// `snapshots()` mantiene un canal abierto con el servidor: cada vez que
/// alguien agrega una reseña, TODOS los dispositivos que estén viendo ese
/// emprendimiento reciben la lista actualizada sin recargar.
class FirestoreResenaDataSource implements ResenaDataSource {
  FirestoreResenaDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _coleccion =>
      _firestore.collection('resenas');

  @override
  Stream<List<ResenaModel>> watchResenas(String emprendimientoId) {
    // Esta consulta necesita el índice compuesto definido en
    // firestore.indexes.json (emprendimientoId ASC + fecha DESC).
    // TODO(COIL-E1-1): Desplegar el índice con
    // `firebase deploy --only firestore:indexes` y verificar en la consola.
    return _coleccion
        .where('emprendimientoId', isEqualTo: emprendimientoId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ResenaModel.fromMap(doc.id, doc.data()))
              .toList(),
        )
        .handleError((Object error) {
          if (error is FirebaseException && error.code == 'permission-denied') {
            throw PermissionException(error.message);
          }
          throw ServerException(error.toString());
        });
  }

  @override
  Future<void> addResena(ResenaModel resena) async {
    try {
      await _coleccion.add({
        ...resena.toMap(),
        // La fecha la pone el servidor: el cliente no puede falsificarla.
        'fecha': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw PermissionException(e.message);
      throw ServerException(e.message);
    }
  }
}
