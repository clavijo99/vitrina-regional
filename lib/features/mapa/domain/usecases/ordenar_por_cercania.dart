import 'dart:math' as math;

import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/ubicacion.dart';
import 'package:vitrina_regional/features/mapa/domain/entities/emprendimiento_cercano.dart';

/// Caso de uso SÍNCRONO y puro: ordena emprendimientos del más cercano al
/// más lejano usando la fórmula de Haversine.
///
/// Al no depender de ningún paquete externo se prueba con un simple test
/// unitario (ver test/features/mapa/domain/ordenar_por_cercania_test.dart).
class OrdenarPorCercania {
  const OrdenarPorCercania();

  static const double _radioTierraMetros = 6371000;

  List<EmprendimientoCercano> call({
    required Ubicacion origen,
    required List<Emprendimiento> emprendimientos,
  }) {
    final cercanos = [
      for (final e in emprendimientos)
        EmprendimientoCercano(
          emprendimiento: e,
          distanciaMetros: distanciaEnMetros(origen, e.ubicacion),
        ),
    ]..sort((a, b) => a.distanciaMetros.compareTo(b.distanciaMetros));
    return cercanos;
  }

  /// Distancia sobre la superficie terrestre entre dos puntos.
  static double distanciaEnMetros(Ubicacion a, Ubicacion b) {
    final dLat = _rad(b.latitud - a.latitud);
    final dLng = _rad(b.longitud - a.longitud);
    final h =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(_rad(a.latitud)) *
            math.cos(_rad(b.latitud)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * _radioTierraMetros * math.asin(math.sqrt(h));
  }

  static double _rad(double grados) => grados * math.pi / 180;
}
