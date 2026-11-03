import 'package:flutter_test/flutter_test.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/ubicacion.dart';
import 'package:vitrina_regional/features/mapa/domain/usecases/ordenar_por_cercania.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  const ordenar = OrdenarPorCercania();

  test('ordena del más cercano al más lejano', () {
    final resultado = ordenar(
      origen: Ubicacion.villavicencio,
      emprendimientos: const [Fixtures.cacao, Fixtures.cafe],
    );

    expect(resultado.map((c) => c.emprendimiento.id), ['e1', 'e2']);
    expect(
      resultado.first.distanciaMetros,
      lessThan(resultado.last.distanciaMetros),
    );
  });

  test('Villavicencio -> Granada está a unos 66 km en línea recta', () {
    final metros = OrdenarPorCercania.distanciaEnMetros(
      Ubicacion.villavicencio,
      Fixtures.cacao.ubicacion,
    );
    expect(metros, closeTo(66000, 3000));
  });

  test('la distancia de un punto a sí mismo es 0', () {
    expect(
      OrdenarPorCercania.distanciaEnMetros(
        Ubicacion.villavicencio,
        Ubicacion.villavicencio,
      ),
      0,
    );
  });
}
