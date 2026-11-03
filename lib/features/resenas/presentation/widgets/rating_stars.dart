import 'package:material_ui/material_ui.dart';

/// Muestra una calificación de 0 a 5 con estrellas (admite medias).
class RatingStars extends StatelessWidget {
  const RatingStars({required this.valor, this.size = 18, super.key});

  final double valor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Colors.amber.shade700;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            valor >= i
                ? Icons.star
                : valor >= i - 0.5
                ? Icons.star_half
                : Icons.star_border,
            size: size,
            color: color,
          ),
      ],
    );
  }
}
