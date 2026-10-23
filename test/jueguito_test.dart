import 'package:flutter_test/flutter_test.dart';
import 'package:jueguito/casilla.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/tablero.dart';

void main() {
  group('Pruebas de Tablero y Sistema de Coordenadas Cartesiano', () {
    late CapaZonas capa;
    late Tablero tablero;

    setUp(() {
      capa = CapaZonas(TipoMapa.mapa1); // FIX: Agregamos el mapa por defecto
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
      capa = CapaZonas(TipoMapa.mapa1); // FIX: Agregamos el mapa por defecto
      tablero = Tablero(capa);
    });

    // FIX: Actualizamos todos los llamados a obtenerIdZonaDeCasilla
    test('Las 4 esquinas y el centro deben ser zona Amarilla (AM)', () {
      expect(tablero.obtenerIdZonaDeCasilla(0, 0), 'AM'); // Abajo izquierda
      expect(tablero.obtenerIdZonaDeCasilla(6, 0), 'AM'); // Abajo derecha
      expect(tablero.obtenerIdZonaDeCasilla(0, 6), 'AM'); // Arriba izquierda
      expect(tablero.obtenerIdZonaDeCasilla(6, 6), 'AM'); // Arriba derecha
      expect(tablero.obtenerIdZonaDeCasilla(3, 3), 'AM'); // Centro exacto
    });

    test('Verificar distribución en el cuadrante superior (Y=5 y Y=6)', () {
      expect(tablero.obtenerIdZonaDeCasilla(1, 6), 'VE1'); // x=1, y=6
      expect(tablero.obtenerIdZonaDeCasilla(3, 6), 'MO1'); // x=3, y=6
      expect(tablero.obtenerIdZonaDeCasilla(2, 5), 'AZ1'); // x=2, y=5
      expect(tablero.obtenerIdZonaDeCasilla(6, 5), 'VE2'); // x=6, y=5
    });

    test('Verificar distribución en el centro (Y=3 y Y=4)', () {
      expect(tablero.obtenerIdZonaDeCasilla(0, 4), 'VE1'); // x=0, y=4
      expect(tablero.obtenerIdZonaDeCasilla(1, 4), 'RO1'); // x=1, y=4
      expect(tablero.obtenerIdZonaDeCasilla(2, 3), 'MO2'); // x=2, y=3
      expect(tablero.obtenerIdZonaDeCasilla(4, 3), 'VE2'); // x=4, y=3
    });

    test('Verificar distribución en el cuadrante inferior (Y=0 y Y=1)', () {
      expect(tablero.obtenerIdZonaDeCasilla(1, 0), 'MO2'); // x=1, y=0
      expect(tablero.obtenerIdZonaDeCasilla(3, 0), 'RO2'); // x=3, y=0
      expect(tablero.obtenerIdZonaDeCasilla(1, 1), 'RO1'); // x=1, y=1
      expect(tablero.obtenerIdZonaDeCasilla(5, 1), 'AZ2'); // x=5, y=1
    });

    test('Las zonas en memoria se comparan correctamente por su ID de texto', () {
      final zona1 = tablero.obtenerIdZonaDeCasilla(0, 0); // AM
      final zona2 = tablero.obtenerIdZonaDeCasilla(3, 3); // AM
      
      // Como ahora son Strings directos, se comparan así:
      expect(zona1 == zona2, isTrue);
    });
  });

  group('Pruebas de Inserción y Reglas de Tipos', () {
    late CapaZonas capa;
    late Tablero tablero;

    setUp(() {
      capa = CapaZonas(TipoMapa.mapa1); // FIX: Agregamos el mapa por defecto
      tablero = Tablero(capa);
    });

    test('Casilla estaVacia funciona correctamente', () {
      var casilla = tablero.obtenerCasilla(0, 0);
      expect(casilla.estaVacia, isTrue);
      
      tablero.intentarColocarNumero(0, 0, 5);
      expect(casilla.estaVacia, isFalse);
      expect(casilla.valor, 5);
    });

    test('Zona VE (Verde): Permite cualquier número repetido o distinto', () {
      // Coordenadas (0,4) y (0,3) son VE1 en el nuevo mapa
      expect(tablero.intentarColocarNumero(0, 4, 3), isTrue, reason: 'Debe permitir el primer número');
      expect(tablero.intentarColocarNumero(0, 3, 3), isTrue, reason: 'Debe permitir repetir número');
      expect(tablero.intentarColocarNumero(1, 6, 7), isTrue, reason: 'Debe permitir número distinto');
    });

    test('Zona RO (Rojo) y AM (Amarillo): Todos los números deben ser distintos', () {
      // Coordenadas (1,4) y (1,3) son RO1
      expect(tablero.intentarColocarNumero(1, 4, 3), isTrue);
      expect(tablero.intentarColocarNumero(1, 3, 3), isFalse, reason: 'No debe permitir repetir el 3 en zona Roja');
      expect(tablero.intentarColocarNumero(1, 3, 5), isTrue, reason: 'Debe permitir un número distinto (5)');

      // Coordenadas (0,0) y (6,6) son AM
      expect(tablero.intentarColocarNumero(0, 0, 9), isTrue);
      expect(tablero.intentarColocarNumero(6, 6, 9), isFalse, reason: 'No debe permitir repetir el 9 en el borde Amarillo');
    });

    test('Zona AZ (Azul): Todos los números deben ser iguales', () {
      // Coordenadas (2,5) y (3,5) son AZ1
      expect(tablero.intentarColocarNumero(2, 5, 4), isTrue);
      expect(tablero.intentarColocarNumero(3, 5, 7), isFalse, reason: 'No debe permitir un número distinto (7)');
      expect(tablero.intentarColocarNumero(3, 5, 4), isTrue, reason: 'Debe permitir repetir el 4');
    });

    test('Zona MO (Morado): Máximo dos números diferentes por zona', () {
      // Coordenadas (3,6) y (4,6) son MO1
      expect(tablero.intentarColocarNumero(3, 6, 1), isTrue, reason: 'Permite el primer número (1)');
      expect(tablero.intentarColocarNumero(4, 6, 2), isTrue, reason: 'Permite un segundo número diferente (2)');
      
      // Intentamos en otra coordenada de MO1 (por ejemplo 4,5)
      expect(tablero.intentarColocarNumero(4, 5, 3), isFalse, reason: 'No permite un tercer número diferente (3)');
      expect(tablero.intentarColocarNumero(4, 5, 1), isTrue, reason: 'Sí permite repetir uno de los ya existentes (1)');
    });
    
    test('Sobreescribir un número en la misma casilla se valida y falla correctamente', () {
      // (1,4) y (2,4) son RO1
      tablero.intentarColocarNumero(1, 4, 3);
      tablero.intentarColocarNumero(2, 4, 4);
      
      // Intento cambiar el 3 por un 4 (debería fallar porque ya hay un 4 en la zona y la casilla NO ESTÁ VACÍA)
      expect(tablero.intentarColocarNumero(1, 4, 4), isFalse);
      
      // Intento cambiar el 3 por un 5 (falla igual porque la casilla YA TIENE NÚMERO y no se puede sobreescribir así)
      expect(tablero.intentarColocarNumero(1, 4, 5), isFalse);
      expect(tablero.obtenerCasilla(1, 4).valor, 3);
    });
  });

  group('Pruebas de Casillas Iniciales y Fase de Preparación', () {
    late CapaZonas capa;
    late Tablero tablero;

    setUp(() {
      capa = CapaZonas(TipoMapa.mapa1); // FIX: Agregamos el mapa por defecto
      tablero = Tablero(capa);
    });

    test('Las casillas iniciales se marcan correctamente en el tablero', () {
      // Verificamos un par de coordenadas que sí deben ser iniciales
      expect(tablero.obtenerCasilla(2, 6).esInicial, isTrue);
      expect(tablero.obtenerCasilla(4, 0).esInicial, isTrue);

      // Verificamos una coordenada normal que NO debe ser inicial
      expect(tablero.obtenerCasilla(0, 0).esInicial, isFalse);
    });

    test('Validación permite solo números del 1 al 6', () {
      expect(tablero.esValidoParaInicial(3), isTrue, reason: 'El 3 es un número válido');
      expect(tablero.esValidoParaInicial(7), isFalse, reason: 'No debe permitir mayores a 6');
      expect(tablero.esValidoParaInicial(0), isFalse, reason: 'No debe permitir menores a 1');
    });

    test('Validación rechaza números repetidos en casillas iniciales', () {
      // Forzamos un 4 en la primera casilla inicial
      tablero.obtenerCasilla(2, 6).valor = 4;

      // Intentamos validar un 4 para otra jugada (debería fallar porque ya se usó)
      expect(tablero.esValidoParaInicial(4), isFalse, reason: 'El 4 ya está en el tablero');
      
      // Intentamos validar un 5 (debería pasar porque está libre)
      expect(tablero.esValidoParaInicial(5), isTrue, reason: 'El 5 no se ha usado');
    });
  });
}