import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitrina_regional/core/error/exceptions.dart';
import 'package:vitrina_regional/features/emprendimientos/data/models/emprendimiento_model.dart';
import 'package:vitrina_regional/features/emprendimientos/data/models/producto_model.dart';

/// Contrato del datasource de emprendimientos (Firestore o mock).
abstract interface class EmprendimientoDataSource {
  Future<List<EmprendimientoModel>> getAll();

  Future<EmprendimientoModel> getById(String id);

  Future<EmprendimientoModel?> getByOwner(String ownerId);

  Future<List<EmprendimientoModel>> getByCategoria(String categoria);

  Future<EmprendimientoModel> create(EmprendimientoModel model);

  Future<EmprendimientoModel> update(EmprendimientoModel model);
}

/// Implementación con Cloud Firestore.
class FirestoreEmprendimientoDataSource implements EmprendimientoDataSource {
  FirestoreEmprendimientoDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _coleccion =>
      _firestore.collection('emprendimientos');

  CollectionReference<Map<String, dynamic>> _productos(String id) =>
      _coleccion.doc(id).collection('productos');

  @override
  Future<List<EmprendimientoModel>> getAll() => _run(() async {
    final snapshot = await _coleccion.orderBy('nombre').get();
    // En el listado no leemos productos (ahorra lecturas de Firestore).
    return snapshot.docs.map(EmprendimientoModel.fromFirestore).toList();
  });

  @override
  Future<EmprendimientoModel> getById(String id) => _run(() async {
    final doc = await _coleccion.doc(id).get();
    if (!doc.exists) throw NotFoundException('Emprendimiento $id no existe');
    final productos = await _productos(id).orderBy('nombre').get();
    return EmprendimientoModel.fromFirestore(
      doc,
      productos: productos.docs
          .map((p) => ProductoModel.fromMap(p.id, p.data()))
          .toList(),
    );
  });

  @override
  Future<EmprendimientoModel?> getByOwner(String ownerId) => _run(() async {
    final snapshot = await _coleccion
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return getById(snapshot.docs.first.id);
  });

  @override
  Future<List<EmprendimientoModel>> getByCategoria(String categoria) =>
      _run(() async {
        final snapshot = await _coleccion
            .where('categoria', isEqualTo: categoria)
            .get();
        final modelos = snapshot.docs
            .map(EmprendimientoModel.fromFirestore)
            .toList();
        // Ordenamos en memoria para no exigir un índice compuesto.
        return modelos..sort((a, b) => a.nombre.compareTo(b.nombre));
      });

  @override
  Future<EmprendimientoModel> create(EmprendimientoModel model) => _run(
    () async {
      final docRef = _coleccion.doc();
      final batch = _firestore.batch()
        ..set(docRef, {
          ...model.toMap(),
          'creadoEn': FieldValue.serverTimestamp(),
          'actualizadoEn': FieldValue.serverTimestamp(),
        });
      final productos = <ProductoModel>[];
      for (final producto in model.productos) {
        final productoRef = docRef.collection('productos').doc();
        batch.set(productoRef, producto.toMap());
        productos.add(ProductoModel.fromMap(productoRef.id, producto.toMap()));
      }
      // Un batch escribe todo o nada: evita emprendimientos a medias.
      await batch.commit();
      return model.copyWith(id: docRef.id, productos: productos);
    },
  );

  @override
  Future<EmprendimientoModel> update(EmprendimientoModel model) => _run(
    () async {
      final docRef = _coleccion.doc(model.id);
      final existentes = await _productos(model.id).get();
      final batch = _firestore.batch()
        ..update(docRef, {
          ...model.toMap(),
          'actualizadoEn': FieldValue.serverTimestamp(),
        });

      final idsNuevos = model.productos.map((p) => p.id).toSet();
      for (final doc in existentes.docs) {
        if (!idsNuevos.contains(doc.id)) batch.delete(doc.reference);
      }
      final productos = <ProductoModel>[];
      for (final producto in model.productos) {
        final productoRef = producto.id.isEmpty
            ? _productos(model.id).doc()
            : _productos(model.id).doc(producto.id);
        batch.set(productoRef, producto.toMap());
        productos.add(ProductoModel.fromMap(productoRef.id, producto.toMap()));
      }
      await batch.commit();
      return model.copyWith(productos: productos);
    },
  );

  /// Traduce las excepciones de Firebase a excepciones propias de la app.
  Future<T> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw PermissionException(e.message);
      if (e.code == 'not-found') throw NotFoundException(e.message);
      throw ServerException(e.message);
    }
  }
}
