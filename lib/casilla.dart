class Casilla {
  final Coordenada coordenada;
  int? valor;
  bool esInicial;

  Casilla({
    required this.coordenada,
    this.valor,
    this.esInicial = false,
  });

  bool get estaVacia => valor == null;
}

// Aquí vivirá ahora la coordenada, ya no necesitamos region.dart
class Coordenada {
  final int x;
  final int y;

  const Coordenada(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coordenada &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}