import 'package:jueguito/tipo.dart';

abstract class Region{
  final Tipo tipo;
  const Region(this.tipo);
}

class ZonaJuego extends Region {
  final String id; 
  const ZonaJuego(this.id, Tipo tipo) : super(tipo);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZonaJuego && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Coordenada{
  final int x;
  final int y;

  const Coordenada(this.x, this.y);
}