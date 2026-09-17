import 'package:jueguito/region.dart';

class Casilla {
  final Coordenada coordenada; 
  final Region region;         
  int? valor;                  

  Casilla({
    required this.coordenada,
    required this.region,
    this.valor,
  });

  bool get estaVacia => valor == null;
}