import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/tablero.dart';

void main() {
  print('--- INICIANDO JUEGO EN CONSOLA ---');

  CapaZonas nivel1 = CapaZonas();
  Tablero tablero = Tablero(nivel1);

  print('\nEstado inicial de las casillas:');

  for (int y = 6; y >= 0; y--) {
    String filaImprimible = 'Y=$y  | ';
    
    for (int x = 0; x < 7; x++) {
      var casilla = tablero.obtenerCasilla(x, y);
      var zona = nivel1.obtenerZonaEn(casilla.coordenada);
      
      String valorCasilla = casilla.estaVacia ? '_' : casilla.valor.toString();
      
      filaImprimible += '[${zona.id}:$valorCasilla] ';
    }
    print(filaImprimible);
  }
}