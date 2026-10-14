import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/tablero.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/ui/pantalla_tablero.dart'; 
import 'package:flutter/services.dart';

void main() {

  // Aseguramos que el entorno de pruebas esté inicializado
  TestWidgetsFlutterBinding.ensureInitialized();

  // === TRUCO PARA PLUGINS NATIVOS ===
  // Interceptamos las llamadas de audioplayers y devolvemos "null" para que 
  // el test crea que el sonido se reprodujo con éxito sin buscar hardware real.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers.global'),
    (MethodCall methodCall) async => null,
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('xyz.luan/audioplayers'),
    (MethodCall methodCall) async => null,
  );
  group('Test de Integración - Camino Feliz del Juego', () {
    late JuegoBloc blocReal;

    setUp(() {
      blocReal = JuegoBloc(Tablero(CapaZonas()));
    });

    tearDown(() {
      blocReal.close();
    });

    Widget crearApp() {
      return MaterialApp(
        home: BlocProvider<JuegoBloc>.value(
          value: blocReal,
          child: const PantallaTablero(),
        ),
      );
    }

    // ==========================================
    // EL TEST PRINCIPAL (MUY LIMPIO Y FÁCIL DE LEER)
    // ==========================================
    testWidgets('Simulación de usuario real: De inicio a fin', (WidgetTester tester) async {
      await tester.pumpWidget(crearApp());
      await tester.pump(const Duration(milliseconds: 500));

      await _completarFasePreparacion(tester, blocReal);
      await _iniciarPartida(tester);
      await _jugarPrimerTurno(tester, blocReal);
    });
  });
}

// ==========================================
// FUNCIONES AUXILIARES (LAS PARTES SEPARADAS)
// ==========================================

Future<void> _completarFasePreparacion(WidgetTester tester, JuegoBloc blocReal) async {
  // 1. Buscamos 6 casillas iniciales vacías
  final casillasIniciales = [];
  for (int x = 0; x < 7; x++) {
    for (int y = 0; y < 7; y++) {
      final casilla = blocReal.state.tablero.obtenerCasilla(x, y);
      if (casilla.esInicial && casillasIniciales.length < 6) {
        casillasIniciales.add(casilla);
      }
    }
  }

  expect(casillasIniciales.length, 6, reason: 'Debe haber 6 casillas iniciales');

  // 2. Colocamos los números 1 al 6
  for (int i = 0; i < 6; i++) {
    final casilla = casillasIniciales[i];
    final x = casilla.coordenada.x;
    final y = casilla.coordenada.y;
    final numeroAColocar = i + 1; 

    // A. Extraemos el botón de la casilla y lo ejecutamos directo (Ignora barreras físicas)
    final celdaFinder = find.byKey(Key('casilla_${x}_${y}'));
    final celdaWidget = tester.widget<GestureDetector>(celdaFinder);
    celdaWidget.onTap!();
    
    // Dejamos que el diálogo (Abanico) aparezca en pantalla
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); 

    // B. Extraemos la carta del abanico y la ejecutamos directo
    final cartaFinder = find.byKey(Key('carta_abanico_$numeroAColocar'));
    final cartaWidget = tester.widget<GestureDetector>(cartaFinder);
    cartaWidget.onTap!(); // Esto dispara _seleccionarCarta y su Future.delayed(500)
    
    // C. Control del tiempo súper preciso para los delays y Navigator.pop
    await tester.pump(); 
    await tester.pump(const Duration(milliseconds: 600)); // Dispara el Navigator.pop(numero)
    await tester.pump(const Duration(milliseconds: 400)); // Espera a que el diálogo desaparezca de la pantalla
    
    // Verificamos visualmente en consola que los números ahora SÍ se están agregando
    int numerosColocados = 0;
    if (blocReal.state is JuegoEsperandoIniciales) {
      numerosColocados = (blocReal.state as JuegoEsperandoIniciales).numerosColocados;
    }
    debugPrint('Jugada ${i + 1} completada. Números colocados: $numerosColocados | Estado: ${blocReal.state.runtimeType}');
  }

  // Damos tiempo a que la UI lea el nuevo estado (JuegoActivo) y cambie los textos
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(milliseconds: 500)); // Un respiro extra para redibujar

// ==========================================
  // EL GRAN FINAL (La Vía Limpia - Ejecución Asíncrona Real)
  // ==========================================

  // 1. Escapamos del reloj simulado de Flutter por un instante.
  // Esto permite que el Event Loop de Dart procese el Stream del BLoC de forma natural.
  await tester.runAsync(() async {
    await Future.delayed(const Duration(milliseconds: 300));
  });

  // 2. Ahora que el BlocBuilder ya recibió el estado en la memoria, 
  // bombeamos un fotograma para que dibuje el botón verde.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100)); // Un respiro extra para redibujar

  // 3. Buscamos el botón en la pantalla
  final finderBotonIniciar = find.byKey(const Key('boton_iniciar_partida'));
  expect(finderBotonIniciar, findsOneWidget, reason: 'El botón Iniciar debe existir en la pantalla');

  final botonWidget = tester.widget<ElevatedButton>(finderBotonIniciar);
  
  // ¡Verificamos la reactividad natural!
  expect(botonWidget.onPressed, isNotNull, reason: 'El botón INICIAR debe estar verde y habilitado');

  debugPrint('Fase de preparación completada con éxito. Botón INICIAR listo.');
}

Future<void> _iniciarPartida(WidgetTester tester) async {
  // 1. Buscamos y tocamos el botón de iniciar
  final botonIniciar = find.byKey(const Key('boton_iniciar_partida'));
  await tester.tap(botonIniciar);

  // 2. Aplicamos la Vía Limpia para que el BLoC procese ComenzarPartida() 
  // y cambie el estado a JuegoEnProgreso con naturalidad
  await tester.runAsync(() async {
    await Future.delayed(const Duration(milliseconds: 300));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  // 3. Verificamos los textos y botones que REALMENTE existen en tu PanelControles
  expect(find.textContaining('Selecciona el Ancla'), findsOneWidget, reason: 'Debe aparecer la instrucción del ancla');
  expect(find.byKey(const ValueKey('dado1')), findsOneWidget, reason: 'El dado 1 debe estar listo');
  expect(find.byKey(const ValueKey('dado2')), findsOneWidget, reason: 'El dado 2 debe estar listo');
  expect(find.byKey(const Key('boton_pasar_turno')), findsOneWidget, reason: 'El botón de pasar turno debe existir');

  debugPrint('Fase 2 completada: ¡Partida iniciada y dados en pantalla!');
}

Future<void> _jugarPrimerTurno(WidgetTester tester, JuegoBloc blocReal) async {
  // 1. Leemos el estado para saber qué dados nos tocaron
  final estadoInicial = blocReal.state as JuegoEnProgreso;
  final idTiradaInicial = estadoInicial.idTirada;
  
  debugPrint('Fase 3: Turno iniciado. Dados rodaron: ${estadoInicial.dado1} y ${estadoInicial.dado2}');

  // 2. Seleccionamos el ancla (elegiremos siempre el dado 1 para la prueba)
  final dado1Finder = find.byKey(const ValueKey('dado1'));
  
  // Extraemos el widget y ejecutamos su onTap directo para evitar bloqueos por la animación de giro
  // Nota: Si tu widget _DadoBoton no expone la propiedad onTap públicamente, usa tester.tap(dado1Finder)
  await tester.tap(dado1Finder);
  
  // Damos tiempo a que el Bloc registre el ancla
  await tester.runAsync(() async {
    await Future.delayed(const Duration(milliseconds: 200));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  // Verificamos que el ancla se haya registrado en el estado
  final estadoConAncla = blocReal.state as JuegoEnProgreso;
  expect(estadoConAncla.anclaSeleccionada, estadoConAncla.dado1, reason: 'El dado 1 debió registrarse como ancla');
  debugPrint('Ancla seleccionada: ${estadoConAncla.anclaSeleccionada}. Buscando casilla válida...');

  // 3. El Bot de Fuerza Bruta: Iteramos por el tablero intentando colocar la pieza
  bool jugadaCompletada = false;
  
  for (int x = 0; x < 7 && !jugadaCompletada; x++) {
    for (int y = 0; y < 7 && !jugadaCompletada; y++) {
      final casillaFinder = find.byKey(Key('casilla_${x}_${y}'));
      
      if (tester.any(casillaFinder)) {
        // Ejecutamos el tap en la casilla evadiendo barreras visuales
        final celdaWidget = tester.widget<GestureDetector>(casillaFinder);
        if (celdaWidget.onTap != null) {
          celdaWidget.onTap!();
          
          // Dejamos que el Bloc evalúe si la jugada es válida según las reglas del juego
          await tester.runAsync(() async {
            await Future.delayed(const Duration(milliseconds: 50)); // Micro-pausa para procesar
          });
          
          // Verificamos si el turno avanzó (el Bloc cambió el idTirada)
          final estadoEvaluado = blocReal.state as JuegoEnProgreso;
          if (estadoEvaluado.idTirada != idTiradaInicial) {
            jugadaCompletada = true;
            debugPrint('✅ ÉXITO: El Bloc aceptó la jugada. Pieza colocada en la casilla ($x, $y)');
          }
        }
      }
    }
  }

  // 4. El Gran Final de la Fase 3
  // Redibujamos la pantalla para el nuevo turno
  await tester.pump(); 
  
  expect(
    jugadaCompletada, 
    isTrue, 
    reason: 'El test revisó todo el tablero y no encontró ninguna jugada válida para los dados ${estadoInicial.dado1} y ${estadoInicial.dado2}'
  );
}