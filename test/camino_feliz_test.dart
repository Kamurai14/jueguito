import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/tablero.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/ui/pantalla_tablero.dart'; 

void main() {
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
      await _jugarPrimerTurno(tester);
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
  final botonIniciar = find.byKey(const Key('boton_iniciar_partida'));
  expect(tester.widget<ElevatedButton>(botonIniciar).onPressed, isNotNull); 
  
  await tester.tap(botonIniciar);
  await tester.pump(const Duration(milliseconds: 500)); 

  expect(find.text('Partida en curso'), findsOneWidget);
  expect(find.byKey(const Key('texto_puntuacion')), findsOneWidget);
  expect(find.byKey(const ValueKey('dado1')), findsOneWidget);
}

Future<void> _jugarPrimerTurno(WidgetTester tester) async {
  // Tocamos el dado 1 para seleccionarlo como ancla
  await tester.tap(find.byKey(const ValueKey('dado1')));
  await tester.pump(const Duration(milliseconds: 100)); 

  // Tocamos el botón de pasar turno (ya que no sabemos qué números cayeron por el azar)
  await tester.tap(find.byKey(const Key('boton_pasar_turno')));
  await tester.pump(const Duration(milliseconds: 500)); 

  // Verificamos que seguimos vivos en la partida
  expect(find.text('Partida en curso'), findsOneWidget);
}