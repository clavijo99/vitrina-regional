import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adapta un `Stream` (el de AuthBloc) a un `Listenable` que go_router
/// entiende: cada vez que cambia el estado de sesión, go_router vuelve a
/// evaluar `redirect` y nos lleva a la pantalla correcta.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
