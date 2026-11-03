// =============================================================================
// PLACEHOLDER — NO contiene credenciales reales.
//
// Para conectar la app a Firebase ejecuta en la raíz del proyecto:
//
//   flutterfire configure --project=<id-de-tu-proyecto>
//
// Ese comando SOBRESCRIBE este archivo con la configuración real. Luego:
//   1. Cambia `useMockData` a `false` en lib/app/di/app_providers.dart.
//   2. Evita subir tu configuración real al repositorio:
//        git update-index --skip-worktree lib/firebase_options.dart
//
// Ver README.md, sección "Ejecutar con Firebase".
// =============================================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

// TODO(COIL-E1-1): Ejecutar `flutterfire configure` con el proyecto Firebase
// del equipo y cambiar useMockData a false.
abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'Firebase no está configurado. Ejecuta `flutterfire configure` '
    'o deja useMockData = true en lib/app/di/app_providers.dart.',
  );
}
