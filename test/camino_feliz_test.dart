import 'dart:math';
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
      // Le agregamos TipoMapa.mapa1 a CapaZonas
      blocReal = JuegoBloc(
        Tablero(CapaZonas(TipoMapa.mapa1)), 
        generadorRandom: DadoTrucado()
      );
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
    // EL TEST PRINCIPAL
    // ==========================================
    testWidgets('Simulación de usuario real: De inicio a fin', (WidgetTester tester) async {
      await tester.pumpWidget(crearApp());
      await tester.pump(const Duration(milliseconds: 500));

      await _completarFasePreparacion(tester, blocReal);
      await _iniciarPartida(tester);
      await _jugarHastaPuntuar(tester, blocReal);
    });
  });
}

// =========================================================
// HACK DEFINITIVO: El generador que siempre devuelve lo mismo
// =========================================================
class DadoTrucado implements Random {
  @override
  int nextInt(int max) => 0; // Obliga a que los dados (nextInt(6)+1) sean 1
  @override
  bool nextBool() => true;
  @override
  double nextDouble() => 0.0;
}

// ==========================================
// FUNCIONES AUXILIARES (FASES DEL TEST)
// ==========================================

Future<void> _completarFasePreparacion(WidgetTester tester, JuegoBloc blocReal) async {
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

  for (int i = 0; i < 6; i++) {
    final casilla = casillasIniciales[i];
    final x = casilla.coordenada.x;
    final y = casilla.coordenada.y;
    final numeroAColocar = i + 1; 

    // Bypass casilla
    final celdaFinder = find.byKey(Key('casilla_${x}_${y}'));
    final celdaWidget = tester.widget<GestureDetector>(celdaFinder);
    celdaWidget.onTap!();
    
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500)); 

    // Bypass carta
    final cartaFinder = find.byKey(Key('carta_abanico_$numeroAColocar'));
    final cartaWidget = tester.widget<GestureDetector>(cartaFinder);
    cartaWidget.onTap!(); 
    
    await tester.pump(); 
    await tester.pump(const Duration(milliseconds: 600)); 
    await tester.pump(const Duration(milliseconds: 400)); 
    
    int numerosColocados = 0;
    if (blocReal.state is JuegoEsperandoIniciales) {
      numerosColocados = (blocReal.state as JuegoEsperandoIniciales).numerosColocados;
    }
    debugPrint('Jugada ${i + 1} completada. Números colocados: $numerosColocados | Estado: ${blocReal.state.runtimeType}');
  }

  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(milliseconds: 500)); 

  await tester.runAsync(() async {
    await Future.delayed(const Duration(milliseconds: 300));
  });

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100)); 

  final finderBotonIniciar = find.byKey(const Key('boton_iniciar_partida'));
  expect(finderBotonIniciar, findsOneWidget, reason: 'El botón Iniciar debe existir en la pantalla');

  final botonWidget = tester.widget<ElevatedButton>(finderBotonIniciar);
  expect(botonWidget.onPressed, isNotNull, reason: 'El botón INICIAR debe estar verde y habilitado');

  debugPrint('Fase de preparación completada con éxito. Botón INICIAR listo.');
}

Future<void> _iniciarPartida(WidgetTester tester) async {
  final botonIniciar = find.byKey(const Key('boton_iniciar_partida'));
  await tester.tap(botonIniciar);

  await tester.runAsync(() async {
    await Future.delayed(const Duration(milliseconds: 300));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  expect(find.textContaining('Selecciona el Ancla'), findsOneWidget, reason: 'Debe aparecer la instrucción del ancla');
  expect(find.byKey(const ValueKey('dado1')), findsOneWidget, reason: 'El dado 1 debe estar listo');
  expect(find.byKey(const ValueKey('dado2')), findsOneWidget, reason: 'El dado 2 debe estar listo');
  expect(find.byKey(const Key('boton_pasar_turno')), findsOneWidget, reason: 'El botón de pasar turno debe existir');

  debugPrint('Fase 2 completada: ¡Partida iniciada y dados en pantalla!');
}

Future<void> _jugarTurnoBot(WidgetTester tester, JuegoBloc blocReal) async {
  final estadoInicial = blocReal.state as JuegoEnProgreso;
  final idTiradaInicial = estadoInicial.idTirada;
  
  debugPrint('Turno iniciado. Dados rodaron: ${estadoInicial.dado1} y ${estadoInicial.dado2}');
  await tester.pump(const Duration(milliseconds: 500));

  // ==========================================
  // BYPASS DADO 1
  // ==========================================
  final dado1Finder = find.byKey(const ValueKey('dado1'));
  final inkWellFinder = find.descendant(of: dado1Finder, matching: find.byType(InkWell));
  final gestureFinder = find.descendant(of: dado1Finder, matching: find.byType(GestureDetector));
  
  if (tester.any(inkWellFinder)) {
    tester.widget<InkWell>(inkWellFinder.first).onTap!();
  } else if (tester.any(gestureFinder)) {
    tester.widget<GestureDetector>(gestureFinder.first).onTap!();
  } else {
    await tester.tap(dado1Finder, warnIfMissed: false);
  }
  
  await tester.runAsync(() async { await Future.delayed(const Duration(milliseconds: 200)); });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  final estadoConAncla = blocReal.state as JuegoEnProgreso;
  expect(estadoConAncla.anclaSeleccionada, estadoConAncla.dado1, reason: 'El dado 1 debió registrarse como ancla');

  bool jugadaCompletada = false;
  
  // ==========================================
  // BYPASS CASILLAS (BOT FUERZA BRUTA)
  // ==========================================
  for (int x = 0; x < 7 && !jugadaCompletada; x++) {
    for (int y = 0; y < 7 && !jugadaCompletada; y++) {
      final casillaFinder = find.byKey(Key('casilla_${x}_${y}'));
      if (tester.any(casillaFinder)) {
        final celdaWidget = tester.widget<GestureDetector>(casillaFinder);
        if (celdaWidget.onTap != null) {
          celdaWidget.onTap!();
          
          await tester.runAsync(() async { await Future.delayed(const Duration(milliseconds: 50)); });
          
          final estadoEvaluado = blocReal.state as JuegoEnProgreso;
          if (estadoEvaluado.idTirada != idTiradaInicial) {
            jugadaCompletada = true;
            debugPrint('✅ ÉXITO: Pieza colocada en la casilla ($x, $y)');
            await tester.pump(const Duration(milliseconds: 200));
          }
        }
      }
    }
  }

  // ==========================================
  // BYPASS BOTÓN PASAR TURNO
  // ==========================================
  if (!jugadaCompletada) {
    debugPrint('⚠️ Sin jugadas válidas. Pasando turno directamente (Bypass)...');
    
    final botonPasarFinder = find.byKey(const Key('boton_pasar_turno'));
    if (tester.any(botonPasarFinder)) {
      final textButton = tester.widget<TextButton>(botonPasarFinder);
      if (textButton.onPressed != null) {
        textButton.onPressed!(); // Ejecución directa
      }
      
      await tester.runAsync(() async { await Future.delayed(const Duration(milliseconds: 200)); });
      await tester.pump(const Duration(milliseconds: 500));
    }
  } else {
    await tester.pump(const Duration(milliseconds: 200)); 
  }
}

Future<void> _jugarHastaPuntuar(WidgetTester tester, JuegoBloc blocReal) async {
  debugPrint('Fase 4: Iniciando modo bot automático (Dado Trucado)');

  int turnosJugados = 0;
  
  while (blocReal.state is JuegoEnProgreso) {
    final estadoActual = blocReal.state as JuegoEnProgreso;
    
    if (estadoActual.puntuacion > 0) {
      debugPrint('🎉 ¡ZONA LLENADA! Puntuación final: ${estadoActual.puntuacion} lograda en $turnosJugados turnos.');
      break; 
    }

    await _jugarTurnoBot(tester, blocReal); 
    turnosJugados++;

    if (turnosJugados > 30) {
      debugPrint('⚠️ Límite de 30 turnos alcanzado. Abortando bot para prevenir ciclos infinitos.');
      break;
    }
  }

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  
  // -------------------------------------------------------------
  // VERIFICACIÓN FINAL
  // -------------------------------------------------------------
  final estadoFinal = blocReal.state as JuegoEnProgreso;
  expect(
    estadoFinal.puntuacion, 
    greaterThan(0), 
    reason: 'El test debe finalizar validando que el motor de reglas otorgó puntos al llenar la zona'
  );

  debugPrint('Fase 4 completada con éxito. 🏆 Sistema de puntuación validado al 100%.');
}