import 'package:image_picker/image_picker.dart';
import 'package:vitrina_regional/features/imagenes/domain/entities/imagen_seleccionada.dart';

/// Contrato para elegir imágenes del dispositivo.
abstract interface class ImagenPickerDataSource {
  Future<ImagenSeleccionada?> seleccionar(FuenteImagen fuente);
}

/// Implementación con `image_picker` (no requiere Firebase).
class ImagePickerDataSource implements ImagenPickerDataSource {
  ImagePickerDataSource([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<ImagenSeleccionada?> seleccionar(FuenteImagen fuente) async {
    final archivo = await _picker.pickImage(
      source: fuente == FuenteImagen.camara
          ? ImageSource.camera
          : ImageSource.gallery,
      // Un primer recorte de tamaño; la compresión fina es COIL-E4-1.
      maxWidth: 1600,
    );
    if (archivo == null) return null;
    return ImagenSeleccionada(
      bytes: await archivo.readAsBytes(),
      nombre: archivo.name,
    );
  }
}
