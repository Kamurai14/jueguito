import 'package:jueguito/region.dart';

class Casilla {
  final Coordenada coordenada;
  int? valor;

  Casilla({
    required this.coordenada,
    this.valor,
  });

  bool get estaVacia => valor == null;
}