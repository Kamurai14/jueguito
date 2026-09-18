import 'package:jueguito/casilla.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/region.dart';

class Tablero {
  static const int tamano = 7;
  late List<List<Casilla>> _cuadricula;
  final CapaZonas capa; 

  Tablero(this.capa) {
    _construirTableroEnBlanco();
  }

  void _construirTableroEnBlanco() {
    _cuadricula = [];
    for (int filaMatriz = 0; filaMatriz < tamano; filaMatriz++) {
      List<Casilla> filaCasillas = [];
      for (int colMatriz = 0; colMatriz < tamano; colMatriz++) {
        int cartesianoX = colMatriz;
        int cartesianoY = (tamano - 1) - filaMatriz;
        
        filaCasillas.add(
          Casilla(coordenada: Coordenada(cartesianoX, cartesianoY))
        );
      }
      _cuadricula.add(filaCasillas);
    }
  }

  Casilla obtenerCasilla(int x, int y) {
    if (x < 0 || x >= tamano || y < 0 || y >= tamano) {
      throw Exception('Coordenada fuera del tablero');
    }
    int matrizY = (tamano - 1) - y;
    return _cuadricula[matrizY][x];
  }

  ZonaJuego obtenerZonaDeCasilla(int x, int y) {
    Casilla casilla = obtenerCasilla(x, y);
    return capa.obtenerZonaEn(casilla.coordenada);
  }
}