import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/casilla.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/tablero.dart';

class JuegoBloc extends Bloc<JuegoEvent, JuegoState> {
  JuegoBloc(Tablero tablero) : super(JuegoEsperandoIniciales(tablero, numerosColocados: 0)) {
    on<InsertarValorInicial>(_onInsertarValorInicial);
    on<MoverValorInicial>(_onMoverValorInicial);
    on<HacerJugada>(_onHacerJugada); 
    on<QuitarValorInicial>(_onQuitarValorInicial);
    on<ComenzarPartida>(_onComenzarPartida);
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

  void _onComenzarPartida(ComenzarPartida event, Emitter<JuegoState> emit) {
    // Simplemente emitimos el nuevo estado pasando el tablero tal como quedó
    emit(JuegoEnProgreso(state.tablero));
  }
}