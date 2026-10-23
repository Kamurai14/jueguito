import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/tablero.dart'; 
import 'package:jueguito/capa_zonas.dart';

void main() {
  group('JuegoBloc - Pruebas de Dados y Puntuación', () {
    late Tablero tableroPrueba;
    late CapaZonas capaPrueba;

    setUp(() {
      // FIX 1: Le decimos al test que use el Mapa 1 por defecto
      capaPrueba = CapaZonas(TipoMapa.mapa1);
      tableroPrueba = Tablero(capaPrueba);
    });

    // 1. PRUEBA DE DADOS: Validar rangos
    blocTest<JuegoBloc, JuegoState>(
      'PasarTurno genera números aleatorios válidos entre 1 y 6 para ambos dados',
      build: () => JuegoBloc(tableroPrueba), 
      seed: () => JuegoEnProgreso(
        tableroPrueba,
        dado1: 0, 
        dado2: 0, 
        puntuacion: 0,
        zonasCompletadas: const {},
        idTirada: 1,
      ),
      act: (bloc) => bloc.add(PasarTurno()),
      expect: () => [
        isA<JuegoEnProgreso>()
            .having((s) => s.dado1, 'dado 1', inInclusiveRange(1, 6))
            .having((s) => s.dado2, 'dado 2', inInclusiveRange(1, 6)),
      ],
    );

    // 2. PRUEBA DE JUGADA NORMAL: Avanza turno pero no da puntos (la zona no está llena)
    blocTest<JuegoBloc, JuegoState>(
      'ColocarJugada válida avanza el turno (idTirada) pero mantiene la puntuación',
      build: () => JuegoBloc(tableroPrueba),
      seed: () => JuegoEnProgreso(
        tableroPrueba,
        dado1: 4,
        dado2: 2,
        anclaSeleccionada: 4, 
        puntuacion: 10, 
        zonasCompletadas: const {},
        idTirada: 1,
      ),
      act: (bloc) {
        bloc.add(ColocarJugada(0, 0, 2));
      },
      expect: () => [
        isA<JuegoEnProgreso>()
            .having((s) => s.puntuacion, 'puntuacion se mantiene igual', 10)
            .having((s) => s.idTirada, 'el turno avanza', 2), 
      ],
    );

    // 3. PRUEBA DE JUGADA INVÁLIDA: No avanza turno, no da puntos, rechaza el movimiento
    blocTest<JuegoBloc, JuegoState>(
      'ColocarJugada en una casilla ya ocupada (inválida) es ignorada por el BLoC',
      build: () => JuegoBloc(tableroPrueba),
      seed: () => JuegoEnProgreso(
        tableroPrueba,
        dado1: 3,
        dado2: 1,
        anclaSeleccionada: 3,
        puntuacion: 20,
        zonasCompletadas: const {}, 
        idTirada: 2, 
      ),
      act: (bloc) {
        tableroPrueba.obtenerCasilla(0, 0).valor = 5; 
        bloc.add(ColocarJugada(0, 0, 1)); 
      },
      expect: () => [], 
    );

    blocTest<JuegoBloc, JuegoState>(
      'El juego pasa a JuegoActivo solo cuando se colocan los 6 números iniciales',
      build: () => JuegoBloc(tableroPrueba),
      seed: () => JuegoEsperandoIniciales(tableroPrueba, numerosColocados: 5),
      act: (bloc) {
        int llenadas = 0;
        for (int x = 0; x < Tablero.tamano; x++) {
          for (int y = 0; y < Tablero.tamano; y++) {
            final c = tableroPrueba.obtenerCasilla(x, y);
            if (c.esInicial && c.estaVacia && llenadas < 5) {
              c.valor = 1; 
              llenadas++;
            }
          }
        }
        
        for (int x = 0; x < Tablero.tamano; x++) {
          for (int y = 0; y < Tablero.tamano; y++) {
            final c = tableroPrueba.obtenerCasilla(x, y);
            if (c.esInicial && c.estaVacia) {
              bloc.add(InsertarValorInicial(x, y, 6));
              return; 
            }
          }
        }
      },
      expect: () => [isA<JuegoActivo>()],
    );

    test('esColocacionValida devuelve false si la regla de la zona no permite el número', () {
      // 1. Ponemos un 4 en la coordenada (1,1)
      tableroPrueba.intentarColocarNumero(1, 1, 4); 
      
      // 2. Intentamos poner otro 4 en la misma zona
      bool esValida = tableroPrueba.esColocacionValida(1, 2, 4); 
      
      // 3. ¡AQUÍ ESTÁ LA LÍNEA QUE FALTABA! Le decimos al test que verifique el resultado
      expect(esValida, isFalse);
    });

    blocTest<JuegoBloc, JuegoState>(
      'Completar la última casilla de una zona otorga los puntos correspondientes',
      build: () => JuegoBloc(tableroPrueba),
      seed: () => JuegoEnProgreso(
        tableroPrueba, dado1: 5, dado2: 2, anclaSeleccionada: 5, puntuacion: 0, zonasCompletadas: const {}, idTirada: 1,
      ),
      setUp: () {
        // FIX 2: Usamos el método correcto que devuelve el String directamente
        String idZona = tableroPrueba.obtenerIdZonaDeCasilla(0, 0);
        
        for (int x = 0; x < Tablero.tamano; x++) {
          for (int y = 0; y < Tablero.tamano; y++) {
            // FIX 3: Comparamos usando el método actualizado
            if (tableroPrueba.obtenerIdZonaDeCasilla(x, y) == idZona) {
              tableroPrueba.obtenerCasilla(x, y).valor = 1; 
            }
          }
        }
        tableroPrueba.obtenerCasilla(0, 0).valor = null;
      },
      act: (bloc) {
        bloc.add(ColocarJugada(0, 0, 5));
      },
      expect: () => [
        isA<JuegoEnProgreso>()
            .having((s) => s.puntuacion, 'suma puntos', greaterThan(0))
            .having((s) => s.zonasCompletadas.length, 'registra la zona', 1),
      ],
    );

    blocTest<JuegoBloc, JuegoState>(
      'QuitarValorInicial regresa el estado a JuegoEsperandoIniciales si los números bajan de 6',
      build: () => JuegoBloc(tableroPrueba),
      setUp: () {
        int llenadas = 0;
        for (int x = 0; x < Tablero.tamano; x++) {
          for (int y = 0; y < Tablero.tamano; y++) {
            final c = tableroPrueba.obtenerCasilla(x, y);
            if (c.esInicial && llenadas < 6) {
              c.valor = llenadas + 1; 
              llenadas++;
            }
          }
        }
      },
      seed: () => JuegoActivo(tableroPrueba),
      act: (bloc) {
        for (int x = 0; x < Tablero.tamano; x++) {
          for (int y = 0; y < Tablero.tamano; y++) {
            final c = tableroPrueba.obtenerCasilla(x, y);
            if (c.esInicial && !c.estaVacia) {
              bloc.add(QuitarValorInicial(x, y));
              return;
            }
          }
        }
      },
      expect: () => [
        isA<JuegoEsperandoIniciales>()
            .having((s) => s.numerosColocados, 'contador baja a 5', 5),
      ],
    );

    blocTest<JuegoBloc, JuegoState>(
      'SeleccionarAncla guarda el ancla y el número a colocar sin avanzar el turno',
      build: () => JuegoBloc(tableroPrueba),
      seed: () => JuegoEnProgreso(
        tableroPrueba,
        dado1: 4,
        dado2: 2,
        anclaSeleccionada: null, 
        numeroAColocar: null,
        puntuacion: 10,
        zonasCompletadas: const {},
        idTirada: 3, 
      ),
      act: (bloc) {
        bloc.add(SeleccionarAncla(4, 2));
      },
      expect: () => [
        isA<JuegoEnProgreso>()
            .having((s) => s.anclaSeleccionada, 'guarda el ancla', 4)
            .having((s) => s.numeroAColocar, 'guarda el número a colocar', 2)
            .having((s) => s.idTirada, 'no avanza el turno', 3)
            .having((s) => s.puntuacion, 'no altera los puntos', 10),
      ],
    );
  });
}