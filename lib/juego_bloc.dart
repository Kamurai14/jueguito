import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/casilla.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/tablero.dart';
import 'dart:math';
import 'package:jueguito/motor_reglas.dart';

class JuegoBloc extends Bloc<JuegoEvent, JuegoState> {
  JuegoBloc(Tablero tablero) : super(JuegoEsperandoIniciales(tablero, numerosColocados: 0)) {
    on<InsertarValorInicial>(_onInsertarValorInicial);
    on<MoverValorInicial>(_onMoverValorInicial);
    on<HacerJugada>(_onHacerJugada); 
    on<QuitarValorInicial>(_onQuitarValorInicial);
    on<ComenzarPartida>(_onComenzarPartida);
    on<SeleccionarAncla>(_onSeleccionarAncla);
    on<ColocarJugada>(_onColocarJugada);
    on<PasarTurno>(_onPasarTurno);
  }

  void _onQuitarValorInicial(QuitarValorInicial event, Emitter<JuegoState> emit) {
    Casilla target = state.tablero.obtenerCasilla(event.x, event.y);
    
    if (target.esInicial) {
      target.valor = null; // Vaciamos la casilla
      _actualizarEstadoInicial(emit); // Recalculamos si el botón verde debe apagarse
    }
  }

  void _onInsertarValorInicial(InsertarValorInicial event, Emitter<JuegoState> emit) {
    Casilla target = state.tablero.obtenerCasilla(event.x, event.y);
    
    if (target.esInicial) {
      target.valor = event.valor;
      _actualizarEstadoInicial(emit);
    }
  }

  void _onMoverValorInicial(MoverValorInicial event, Emitter<JuegoState> emit) {
    Casilla origen = state.tablero.obtenerCasilla(event.xOrigen, event.yOrigen);
    Casilla destino = state.tablero.obtenerCasilla(event.xDestino, event.yDestino);
    
    // Guardamos el valor que está en la casilla destino (puede ser un número o null)
    int? valorEnDestino = destino.valor; 
    
    // Hacemos el intercambio mágico
    destino.valor = event.valor; // Ponemos el nuevo número en el destino
    origen.valor = valorEnDestino; // Pasamos el valor viejo a donde estaba el otro
    _actualizarEstadoInicial(emit);
  }

  void _onHacerJugada(HacerJugada event, Emitter<JuegoState> emit) {
    // Aquí irá la lógica de las jugadas normales una vez que se presione "INICIAR"
  }

  // Función interna para recalcular cuántos números llevamos y cambiar de estado
  void _actualizarEstadoInicial(Emitter<JuegoState> emit) {
    int colocados = state.tablero.contarNumerosIniciales();
    
    if (colocados >= 6) { 
      // Si ya están los 6, desbloqueamos el tablero
      emit(JuegoActivo(state.tablero));
    } else {
      // Si faltan, actualizamos la UI con el nuevo contador
      emit(JuegoEsperandoIniciales(state.tablero, numerosColocados: colocados));
    }
  }

  // --- HELPER AUTOMATIZADO ---
  JuegoEnProgreso _generarNuevoTurno(
    Tablero tablero, 
    int puntuacionActual, 
    Set<String> zonasCompletadas,
    {String? mensajeAlerta}
  ) {
    final rand = Random();
    return JuegoEnProgreso(
      tablero,
      dado1: rand.nextInt(6) + 1,
      dado2: rand.nextInt(6) + 1,
      puntuacion: puntuacionActual,
      zonasCompletadas: zonasCompletadas,
      mensajeAlerta: mensajeAlerta,
    );
  }

  // --- EVENTOS ---
  void _onComenzarPartida(ComenzarPartida event, Emitter<JuegoState> emit) {
    emit(_generarNuevoTurno(state.tablero, 0, {})); // Iniciamos con 0 puntos
  }

  void _onSeleccionarAncla(SeleccionarAncla event, Emitter<JuegoState> emit) {
    if (state is JuegoEnProgreso) {
      final actual = state as JuegoEnProgreso;
      emit(JuegoEnProgreso(
        actual.tablero,
        dado1: actual.dado1,
        dado2: actual.dado2,
        anclaSeleccionada: event.ancla,
        numeroAColocar: event.numeroAColocar,
        puntuacion: actual.puntuacion,
        zonasCompletadas: actual.zonasCompletadas,
      ));
    }
  }

  void _onColocarJugada(ColocarJugada event, Emitter<JuegoState> emit) {
    if (state is JuegoEnProgreso) {
      final actual = state as JuegoEnProgreso;
      bool colocado = actual.tablero.intentarColocarNumero(event.x, event.y, event.numero);
      
      if (colocado) {
        String idZona = actual.tablero.obtenerZonaDeCasilla(event.x, event.y).id;
        
        int nuevaPuntuacion = actual.puntuacion;
        Set<String> nuevasZonas = Set.from(actual.zonasCompletadas);
        String? alertaPersonalizada;

        // Si esta zona no la habíamos cobrado y ahora resulta que está llena...
        if (!nuevasZonas.contains(idZona) && actual.tablero.estaZonaLlena(idZona)) {
          int puntos = MotorReglas.obtenerPuntosPrimeraVez(idZona);
          nuevaPuntuacion += puntos;
          nuevasZonas.add(idZona); // La marcamos para no cobrarla de nuevo
          alertaPersonalizada = '¡Zona $idZona completada! +$puntos puntos 🏆';
        }

        emit(_generarNuevoTurno(
          actual.tablero, 
          nuevaPuntuacion, 
          nuevasZonas,
          mensajeAlerta: alertaPersonalizada
        ));
      }
    }
  }

  void _onPasarTurno(PasarTurno event, Emitter<JuegoState> emit) {
    if (state is JuegoEnProgreso) {
      final actual = state as JuegoEnProgreso;
      emit(_generarNuevoTurno(actual.tablero, actual.puntuacion, actual.zonasCompletadas));
    }
  }
}