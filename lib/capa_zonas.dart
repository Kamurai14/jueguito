enum TipoMapa { mapa1, mapa2, mapa3, mapa4 }

class Punto {
  final int x;
  final int y;
  Punto(this.x, this.y);
}

class CapaZonas {
  late final List<List<String>> _mapaLimpiado;
  late final List<Punto> _posicionesIniciales;
  final TipoMapa tipoMapa;

  CapaZonas(this.tipoMapa) {
    _posicionesIniciales = [];
    _mapaLimpiado = _procesarMatriz(_generarMatriz(tipoMapa));
  }

  // Devuelve a qué zona pertenece la coordenada (el String limpio, sin asteriscos)
  String obtenerIdZona(int x, int y) {
    // La Y está invertida visualmente en la matriz (Y=6 es la fila 0)
    return _mapaLimpiado[6 - y][x]; 
  }

  // Te dice si esa coordenada X,Y era una de las que tenía el asterisco (*)
  bool esCasillaInicial(int x, int y) {
    return _posicionesIniciales.any((p) => p.x == x && p.y == y);
  }

  // Lógica inteligente: Lee la matriz, busca los '*', guarda sus coordenadas y limpia el texto
  List<List<String>> _procesarMatriz(List<List<String>> matrizOriginal) {
    List<List<String>> matrizLimpia = [];
    
    for (int filaIndex = 0; filaIndex < 7; filaIndex++) {
      List<String> filaLimpia = [];
      for (int colIndex = 0; colIndex < 7; colIndex++) {
        // Forzamos mayúsculas por seguridad (por si escribes Mo1 en lugar de MO1)
        String celda = matrizOriginal[filaIndex][colIndex].toUpperCase(); 
        
        if (celda.contains('*')) {
          // Guardamos la coordenada invirtiendo la Y para que coincida con tu lógica de tablero
          _posicionesIniciales.add(Punto(colIndex, 6 - filaIndex));
          celda = celda.replaceAll('*', ''); // Quitamos el asterisco para no romper tu lógica
        }
        filaLimpia.add(celda);
      }
      matrizLimpia.add(filaLimpia);
    }
    return matrizLimpia;
  }

  // Diseños de mapa 
  List<List<String>> _generarMatriz(TipoMapa tipo) {
    switch (tipo) {
      case TipoMapa.mapa1:
        return [
          ['AM', 'VE1', 'AZ1*', 'MO1', 'MO1', 'MO1', 'AM'], // Y = 6
          ['VE1', 'VE1', 'AZ1', 'AZ1', 'MO1', 'MO1*', 'VE2'], // Y = 5
          ['VE1', 'RO1', 'RO1', 'AZ1', 'MO1', 'VE2', 'VE2'], // Y = 4
          ['VE1', 'RO1*', 'MO2', 'AM', 'VE2*', 'VE2', 'VE2'], // Y = 3
          ['VE1', 'RO1', 'MO2', 'MO2', 'RO2', 'RO2', 'AZ2'], // Y = 2
          ['RO1', 'RO1', 'MO2*', 'RO2', 'RO2', 'AZ2', 'AZ2'], // Y = 1
          ['AM', 'MO2', 'MO2', 'RO2', 'RO2*', 'AZ2', 'AM'], // Y = 0
        ];

        
      case TipoMapa.mapa2:
        return [
          ['MO1', 'MO1', 'MO1', 'BL',  'VE1*', 'VE1', 'VE1'], // Y = 6
          ['MO1', 'AM',  'AZ1', 'AZ1', 'AZ1',  'AM',  'VE1'], // Y = 5
          ['MO1*', 'RO1', 'RO1', 'AZ1', 'AZ1',  'RO2', 'VE1'], // Y = 4
          ['RO1', 'RO1', 'RO1*', 'AM',  'RO2',  'RO2', 'RO2'], // Y = 3
          ['VE2', 'RO1', 'AZ2', 'AZ2', 'RO2',  'RO2*', 'MO2'], // Y = 2
          ['VE2', 'AM*', 'AZ2', 'AZ2', 'AZ2',  'AM',  'MO2'], // Y = 1
          ['VE2', 'VE2', 'VE2', 'BL',  'MO2*', 'MO2', 'MO2'], // Y = 0
        ];
        
      case TipoMapa.mapa3:
        return [
          ['AM',  'AM',  'MO1',  'BL',  'MO1', 'AM',  'AM'],  // Y = 6
          ['BL',  'AM',  'MO1*', 'MO1', 'MO1', 'AM*', 'BL'],  // Y = 5
          ['RO1', 'RO1', 'RO1',  'MO1', 'RO2', 'RO2', 'RO2'], // Y = 4
          ['RO1', 'RO1', 'RO1',  'BL*', 'RO2', 'RO2', 'RO2'], // Y = 3
          ['VE',  'AZ*', 'AZ',   'AZ',  'AZ',  'AZ',  'VE*'], // Y = 2
          ['VE',  'VE',  'VE',   'VE',  'VE',  'VE',  'VE'],  // Y = 1
          ['MO1', 'MO1', 'MO1*', 'BL',  'MO2', 'MO2', 'MO2'], // Y = 0
        ];
        
      case TipoMapa.mapa4:
        return [
          ['NA1', 'NA1',  'NA1', 'NA1', 'NA1*', 'NA1', 'NA1'], // Y = 6
          ['AM',  'RO1',  'AZ',  'VE',  'AZ',   'RO2', 'AM'],  // Y = 5
          ['RO1', 'RO1',  'MO*', 'MO',  'MO',   'RO2*', 'RO2'], // Y = 4
          ['AM*', 'VE',   'AZ',  'MO',  'AZ',   'VE',  'AM'],  // Y = 3
          ['RO1', 'RO1',  'MO',  'MO',  'MO',   'RO2', 'RO2'], // Y = 2
          ['AM',  'RO1',  'AZ',  'VE',  'AZ*',  'RO2', 'AM'],  // Y = 1
          ['NA2', 'NA2*', 'NA2', 'NA2', 'NA2',  'NA2', 'NA2'], // Y = 0
        ];
    }
  }
}