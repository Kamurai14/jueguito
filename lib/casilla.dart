import 'package:jueguito/region.dart';

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