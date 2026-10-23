import 'package:jueguito/casilla.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/motor_reglas.dart'; 

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
        
        // El tablero se construye solo con los asteriscos de CapaZonas
        bool esEspecial = capa.esCasillaInicial(cartesianoX, cartesianoY);
        
        filaCasillas.add(
          Casilla(
            coordenada: Coordenada(cartesianoX, cartesianoY),
            esInicial: esEspecial, 
          )
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

  // Ahora devuelve directamente el String de la zona (ej. 'AM', 'BL')
  String obtenerIdZonaDeCasilla(int x, int y) {
    return capa.obtenerIdZona(x, y);
  }

  List<int> obtenerNumerosEnZona(String idZona, {Coordenada? excluir}) {
    List<int> numerosActuales = [];

    for (int fila = 0; fila < tamano; fila++) {
      for (int col = 0; col < tamano; col++) {
        Casilla casilla = _cuadricula[fila][col];
        
        if (!casilla.estaVacia && casilla.coordenada != excluir) {
          String zonaActual = capa.obtenerIdZona(casilla.coordenada.x, casilla.coordenada.y);
          
          if (zonaActual == idZona) {
            numerosActuales.add(casilla.valor!);
          }
        }
      }
    }
    return numerosActuales;
  }

  bool intentarColocarNumero(int x, int y, int numero) {
    Casilla casillaTarget = obtenerCasilla(x, y);
    if (!casillaTarget.estaVacia) {
      return false; 
    }
    
    String idZonaTarget = capa.obtenerIdZona(x, y);
    List<int> actuales = obtenerNumerosEnZona(idZonaTarget, excluir: casillaTarget.coordenada);

    // Conectado con el nuevo Motor de Reglas
    bool esValido = MotorReglas.esJugadaValida(idZonaTarget, numero, actuales);

    if (esValido) {
      casillaTarget.valor = numero;
      return true; 
    } else {
      return false; 
    }
  }

  bool esValidoParaInicial(int numero) {
    if (numero < 1 || numero > 6) return false; 

    for (int fila = 0; fila < tamano; fila++) {
      for (int col = 0; col < tamano; col++) {
        Casilla casilla = _cuadricula[fila][col];
        if (casilla.esInicial && casilla.valor == numero) {
          return false; 
        }
      }
    }
    return true; 
  }

  Casilla? buscarCasillaInicialConValor(int numero) {
    int tamanoActual = _cuadricula.length; 

    for (int fila = 0; fila < tamanoActual; fila++) {
      for (int col = 0; col < tamanoActual; col++) {
        Casilla c = _cuadricula[fila][col];
        if (c.esInicial && c.valor == numero) {
          return c;
        }
      }
    }
    return null; 
  }

  int contarNumerosIniciales() {
    int contador = 0;
    int tamanoActual = _cuadricula.length; 

    for (int fila = 0; fila < tamanoActual; fila++) {
      for (int col = 0; col < tamanoActual; col++) {
        if (_cuadricula[fila][col].esInicial && _cuadricula[fila][col].valor != null) {
          contador++;
        }
      }
    }
    return contador;
  }

  bool esAdyacenteAValor(int x, int y, int valorBuscado) {
    final adyacentes = [
      Coordenada(x + 1, y), Coordenada(x - 1, y),
      Coordenada(x, y + 1), Coordenada(x, y - 1)
    ];
    
    for (var c in adyacentes) {
      if (c.x >= 0 && c.x < tamano && c.y >= 0 && c.y < tamano) {
        if (obtenerCasilla(c.x, c.y).valor == valorBuscado) return true;
      }
    }
    return false;
  }

  bool esColocacionValida(int x, int y, int numero) {
    Casilla casillaTarget = obtenerCasilla(x, y);
    String idZonaTarget = capa.obtenerIdZona(x, y);
    List<int> actuales = obtenerNumerosEnZona(idZonaTarget, excluir: casillaTarget.coordenada);
    
    // Conectado con el nuevo Motor de Reglas
    return MotorReglas.esJugadaValida(idZonaTarget, numero, actuales);
  }

  bool estaZonaLlena(String idZona) {
    for (int fila = 0; fila < tamano; fila++) {
      for (int col = 0; col < tamano; col++) {
        Casilla casilla = _cuadricula[fila][col];
        String zonaActual = capa.obtenerIdZona(casilla.coordenada.x, casilla.coordenada.y);
        
        if (zonaActual == idZona && casilla.estaVacia) {
          return false; 
        }
      }
    }
    return true; 
  }
}