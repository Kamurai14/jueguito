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
      capaPrueba = CapaZonas();
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
        zonasCompletadas: {},
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
        zonasCompletadas: {},
        idTirada: 1,
      ),
      act: (bloc) {
        // IMPORTANTE: Asegúrate de que poner un 2 en la coordenada (0, 0) 
        // sea una jugada VÁLIDA según las reglas reales de tu tablero inicial.
        bloc.add(ColocarJugada(0, 0, 2));
      },
      expect: () => [
        isA<JuegoEnProgreso>()
            .having((s) => s.puntuacion, 'puntuacion se mantiene igual', 10)
            .having((s) => s.idTirada, 'el turno avanza', 2), // El idTirada debe subir a 2
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
        zonasCompletadas: {}, 
        idTirada: 2, // Turno actual
      ),
      act: (bloc) {
        // 1. Trucamos el tablero llenando la casilla (0,0) con un 5 para que esté ocupada
        tableroPrueba.obtenerCasilla(0, 0).valor = 5; 
        
        // 2. Disparamos el evento intentando poner un 1 en esa misma casilla
        bloc.add(ColocarJugada(0, 0, 1)); 
      },
      // Cuando un evento es rechazado por la lógica (como un movimiento inválido), 
      // el BLoC no emite ningún estado nuevo. Esperamos una lista vacía [].
      expect: () => [], 
    );

    blocTest<JuegoBloc, JuegoState>(
      'El juego pasa a JuegoActivo solo cuando se colocan los 6 números iniciales',
      build: () => JuegoBloc(tableroPrueba),
      seed: () => JuegoEsperandoIniciales(tableroPrueba, numerosColocados: 5),
      act: (bloc) {
        // 1. Llenamos 5 casillas iniciales "a mano" en el tablero
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
        
        // 2. Buscamos la 6ta casilla (la única vacía que queda) y lanzamos el evento
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
      // 1. Busca una casilla y pon un número que sepas que restringirá la zona
      // (ej. si la zona no permite repetidos, pon un 4)
      tableroPrueba.intentarColocarNumero(1, 1, 4); 
      
      // 2. Intenta poner otro 4 en la misma zona pero en diferente casilla
      bool esValida = tableroPrueba.esColocacionValida(1, 2, 4); 
      
      // 3. Verificamos que tu CapaZonas haga bien su trabajo y lo rechace
      expect(esValida, isFalse);
    });

    blocTest<JuegoBloc, JuegoState>(
      'Completar la última casilla de una zona otorga los puntos correspondientes',
      build: () => JuegoBloc(tableroPrueba),
      seed: () => JuegoEnProgreso(
        tableroPrueba, dado1: 5, dado2: 2, anclaSeleccionada: 5, puntuacion: 0, zonasCompletadas: {}, idTirada: 1,
      ),
      setUp: () {
        // 1. Encontramos a qué zona pertenece la casilla (0,0)
        String idZona = tableroPrueba.obtenerZonaDeCasilla(0, 0).id;
        
        // 2. Llenamos TODAS las casillas de esa zona en el tablero
        for (int x = 0; x < Tablero.tamano; x++) {
          for (int y = 0; y < Tablero.tamano; y++) {
            if (tableroPrueba.obtenerZonaDeCasilla(x, y).id == idZona) {
              tableroPrueba.obtenerCasilla(x, y).valor = 1; 
            }
          }
        }
        // 3. Vaciamos ÚNICAMENTE la (0,0) para que nuestra jugada sea la que cierre la zona
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
        // Pre-llenamos 6 casillas iniciales en el tablero para simular que está listo
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
      // Hacemos que el bloc inicie creyendo que el juego ya está activo (botón verde encendido)
      seed: () => JuegoActivo(tableroPrueba),
      act: (bloc) {
        // Buscamos la primera casilla inicial ocupada y le disparamos el evento de quitar
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
        // Debe regresar al estado de espera con exactamente 5 números colocados
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
        anclaSeleccionada: null, // Inicia sin selección
        numeroAColocar: null,
        puntuacion: 10,
        zonasCompletadas: {},
        idTirada: 3, 
      ),
      act: (bloc) {
        // El jugador elige el dado 1 (valor 4) como ancla, 
        // lo que significa que el dado 2 (valor 2) es el que va a colocar
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