/// Categorías de emprendimiento. En Firestore se guarda `name` (ej. 'agro').
enum Categoria {
  gastronomia('Gastronomía'),
  artesanias('Artesanías'),
  moda('Moda'),
  turismo('Turismo'),
  agro('Agro'),
  servicios('Servicios');

  const Categoria(this.label);

  final String label;

  static Categoria fromName(String? name) => Categoria.values.firstWhere(
    (c) => c.name == name,
    orElse: () => Categoria.servicios,
  );
}
