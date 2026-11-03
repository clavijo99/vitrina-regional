import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// De dónde se toma la imagen.
enum FuenteImagen { camara, galeria }

/// Imagen elegida por el usuario, en memoria, antes de subirla.
///
/// Usamos bytes (no `File`) para que funcione también en web y para no
/// acoplar domain a `dart:io` ni a image_picker.
class ImagenSeleccionada extends Equatable {
  const ImagenSeleccionada({required this.bytes, required this.nombre});

  /// Límite que también exige storage.rules.
  static const int maxBytes = 5 * 1024 * 1024;

  final Uint8List bytes;
  final String nombre;

  int get tamanoBytes => bytes.lengthInBytes;

  @override
  List<Object?> get props => [nombre, tamanoBytes];
}
