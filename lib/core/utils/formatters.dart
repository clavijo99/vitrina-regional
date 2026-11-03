import 'package:intl/intl.dart';

/// Formateadores de presentación (moneda, fechas, distancias) con `intl`.
abstract final class Formatters {
  static final NumberFormat _moneda = NumberFormat.currency(
    locale: 'es',
    symbol: r'$',
    decimalDigits: 0,
  );

  /// 15000 -> "$ 15.000" (el espacio puede variar según el locale).
  static String precio(double valor) => _moneda.format(valor).trim();

  /// Requiere `initializeDateFormatting('es')` (se hace en main.dart).
  static String fecha(DateTime fecha) =>
      DateFormat('d MMM y', 'es').format(fecha);

  /// 850 -> "850 m", 12345 -> "12.3 km"
  static String distancia(double metros) {
    if (metros < 1000) return '${metros.round()} m';
    return '${(metros / 1000).toStringAsFixed(1)} km';
  }
}
