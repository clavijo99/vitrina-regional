import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitrina_regional/features/imagenes/domain/entities/imagen_seleccionada.dart';
import 'package:vitrina_regional/features/imagenes/domain/usecases/seleccionar_imagen.dart';
import 'package:vitrina_regional/features/imagenes/domain/usecases/subir_imagen.dart';

enum SubirImagenStatus { initial, loading, success, failure }

class SubirImagenState extends Equatable {
  const SubirImagenState({
    this.status = SubirImagenStatus.initial,
    this.url,
    this.errorMessage,
  });

  final SubirImagenStatus status;

  /// URL de la última imagen subida con éxito.
  final String? url;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, url, errorMessage];
}

/// Flujo "elegir imagen -> subir -> obtener URL".
class SubirImagenCubit extends Cubit<SubirImagenState> {
  SubirImagenCubit({required this._seleccionar, required this._subir})
    : super(const SubirImagenState());

  final SeleccionarImagen _seleccionar;
  final SubirImagen _subir;

  Future<void> seleccionarYSubir({
    required FuenteImagen fuente,
    required String carpeta,
  }) async {
    final seleccion = await _seleccionar(fuente);
    final imagen = seleccion.fold((failure) {
      emit(
        SubirImagenState(
          status: SubirImagenStatus.failure,
          errorMessage: failure.message,
        ),
      );
      return null;
    }, (imagen) => imagen);
    // Canceló o falló la selección: no hay nada que subir.
    if (imagen == null) return;

    emit(const SubirImagenState(status: SubirImagenStatus.loading));
    final result = await _subir(
      SubirImagenParams(imagen: imagen, carpeta: carpeta),
    );
    emit(
      result.fold(
        (failure) => SubirImagenState(
          status: SubirImagenStatus.failure,
          errorMessage: failure.message,
        ),
        (url) => SubirImagenState(status: SubirImagenStatus.success, url: url),
      ),
    );
  }

  // TODO(COIL-E4-3): Integrar este cubit en MiEmprendimientoPage: botón
  // "Agregar foto" (galería/cámara) y, al recibir `success`, añadir la URL a
  // `fotos` del emprendimiento antes de guardar. Mostrar miniaturas con
  // AppNetworkImage y permitir quitar fotos.
  // TODO(COIL-E4-6): Pruebas del flujo de imágenes: (a) en
  // subir_imagen_cubit_test, un caso que verifique los estados de progreso;
  // (b) un test de widget de FotosEditor que agregue y quite una foto
  // (mockeando SeleccionarImagen y SubirImagen con mocktail).
  // TODO(COIL-E4-4): Exponer el progreso de subida a Cloudinary. El paquete
  // `http` no da progreso nativo: usar un indicador indeterminado durante
  // `loading`, o (reto) un Stream contador de bytes / `dio` con onSendProgress.
}
