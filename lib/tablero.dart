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

    List<Coordenada> coordenadasIniciales = [
      Coordenada(2, 6), // Fila de arriba, casilla azul
      Coordenada(5, 5), // Fila abajo, segunda morada
      Coordenada(1, 3), // Dos filas abajo, casilla roja
      Coordenada(4, 3), // Misma fila, primera verde de las 3
      Coordenada(2, 1), // Dos filas abajo, casilla morada
      Coordenada(4, 0)  // Fila de hasta abajo, segunda roja
];

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

  List<int> obtenerNumerosEnZona(String idZona, {Coordenada? excluir}) {
    List<int> numerosActuales = [];

    for (int fila = 0; fila < tamano; fila++) {
      for (int col = 0; col < tamano; col++) {
        Casilla casilla = _cuadricula[fila][col];
        
        // Si la casilla no está vacía y no es la que queremos excluir
        if (!casilla.estaVacia && casilla.coordenada != excluir) {
          ZonaJuego zona = capa.obtenerZonaEn(casilla.coordenada);
          
          if (zona.id == idZona) {
            numerosActuales.add(casilla.valor!);
          }
        }
      }
    }
    return numerosActuales;
  }

  bool intentarColocarNumero(int x, int y, int numero) {
    Casilla casillaTarget = obtenerCasilla(x, y);
    ZonaJuego zonaTarget = capa.obtenerZonaEn(casillaTarget.coordenada);

    List<int> actuales = obtenerNumerosEnZona(zonaTarget.id, excluir: casillaTarget.coordenada);

    bool esValido = zonaTarget.tipo.esPosibleAgregar(actuales, numero);

    if (esValido) {
      casillaTarget.valor = numero;
      return true; 
    } else {
      return false; 
    }
  }

  bool esValidoParaInicial(int numero) {
    if (numero < 1 || numero > 6) return false; // Solo números del 1 al 6

    // Revisamos todas las casillas para ver si ya se usó este número en otra casilla inicial
    for (int fila = 0; fila < tamano; fila++) {
      for (int col = 0; col < tamano; col++) {
        Casilla casilla = _cuadricula[fila][col];
        if (casilla.esInicial && casilla.valor == numero) {
          return false; // El número ya está puesto en otra casilla especial
        }
      }
    }
    return true; // El número es válido y no se ha repetido
  }
}