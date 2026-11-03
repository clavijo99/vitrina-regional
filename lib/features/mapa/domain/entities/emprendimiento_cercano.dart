import 'package:equatable/equatable.dart';
import 'package:vitrina_regional/features/emprendimientos/domain/entities/emprendimiento.dart';

/// Un emprendimiento junto con su distancia al usuario.
class EmprendimientoCercano extends Equatable {
  const EmprendimientoCercano({
    required this.emprendimiento,
    required this.distanciaMetros,
  });

  final Emprendimiento emprendimiento;
  final double distanciaMetros;

  @override
  List<Object?> get props => [emprendimiento, distanciaMetros];
}
