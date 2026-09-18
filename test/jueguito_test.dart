import 'package:test/test.dart';
import 'package:jueguito/casilla.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/tablero.dart';

void main() {
  group('Pruebas de Tablero y Sistema de Coordenadas Cartesiano', () {
    late CapaZonas capa;
    late Tablero tablero;

    setUp(() {
      capa = CapaZonas();
      tablero = Tablero(capa);
    });

    test('El origen (0,0) debe estar en la esquina inferior izquierda', () {
      Casilla casilla = tablero.obtenerCasilla(0, 0);
      expect(casilla.coordenada.x, 0);
      expect(casilla.coordenada.y, 0);
    });

    test('La coordenada (6,6) debe estar en la esquina superior derecha', () {
      Casilla casilla = tablero.obtenerCasilla(6, 6);
      expect(casilla.coordenada.x, 6);
      expect(casilla.coordenada.y, 6);
    });

    test('Fuera de límites lanza excepción', () {
      expect(() => tablero.obtenerCasilla(7, 7), throwsException);
      expect(() => tablero.obtenerCasilla(-1, 0), throwsException);
    });
  });

  group('Pruebas de Capa de Zonas (Nuevo Mapa Personalizado)', () {
    late CapaZonas capa;
    late Tablero tablero;

    setUp(() {
      capa = CapaZonas();
      tablero = Tablero(capa);
    });

    test('Las 4 esquinas y el centro deben ser zona Amarilla (AM)', () {
      expect(tablero.obtenerZonaDeCasilla(0, 0).id, 'AM'); // Abajo izquierda
      expect(tablero.obtenerZonaDeCasilla(6, 0).id, 'AM'); // Abajo derecha
      expect(tablero.obtenerZonaDeCasilla(0, 6).id, 'AM'); // Arriba izquierda
      expect(tablero.obtenerZonaDeCasilla(6, 6).id, 'AM'); // Arriba derecha
      expect(tablero.obtenerZonaDeCasilla(3, 3).id, 'AM'); // Centro exacto
    });

    test('Verificar distribución en el cuadrante superior (Y=5 y Y=6)', () {
      expect(tablero.obtenerZonaDeCasilla(1, 6).id, 'VE1'); // x=1, y=6
      expect(tablero.obtenerZonaDeCasilla(3, 6).id, 'MO1'); // x=3, y=6
      expect(tablero.obtenerZonaDeCasilla(2, 5).id, 'AZ1'); // x=2, y=5
      expect(tablero.obtenerZonaDeCasilla(6, 5).id, 'VE2'); // x=6, y=5
    });

    test('Verificar distribución en el centro (Y=3 y Y=4)', () {
      expect(tablero.obtenerZonaDeCasilla(0, 4).id, 'VE1'); // x=0, y=4
      expect(tablero.obtenerZonaDeCasilla(1, 4).id, 'RO1'); // x=1, y=4
      expect(tablero.obtenerZonaDeCasilla(2, 3).id, 'MO2'); // x=2, y=3
      expect(tablero.obtenerZonaDeCasilla(4, 3).id, 'VE2'); // x=4, y=3
    });

    test('Verificar distribución en el cuadrante inferior (Y=0 y Y=1)', () {
      expect(tablero.obtenerZonaDeCasilla(1, 0).id, 'MO2'); // x=1, y=0
      expect(tablero.obtenerZonaDeCasilla(3, 0).id, 'RO2'); // x=3, y=0
      expect(tablero.obtenerZonaDeCasilla(1, 1).id, 'RO1'); // x=1, y=1
      expect(tablero.obtenerZonaDeCasilla(5, 1).id, 'AZ2'); // x=5, y=1
    });

    test('Las zonas en memoria deben ser las mismas instancias', () {
      final zona1 = tablero.obtenerZonaDeCasilla(0, 0); // AM
      final zona2 = tablero.obtenerZonaDeCasilla(3, 3); // AM
      
      // Ambas casillas apuntan a la misma regla en memoria
      expect(identical(zona1, zona2), isTrue);
    });
  });
}