import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/tablero.dart';
import 'juego_event.dart';
import 'juego_state.dart';
import 'package:jueguito/casilla.dart';

class JuegoBloc extends Bloc<JuegoEvent, JuegoState> {
  // Manejamos un contador interno para los números iniciales
  int _valoresInicialesInsertados = 0;
  final int _totalRequeridos = 6;

  JuegoBloc(Tablero tableroInicial) 
    : super(JuegoEsperandoIniciales(tableroInicial, numerosColocados: 0)) {
    
    on<InsertarValorInicial>(_onInsertarValorInicial);
    on<HacerJugada>(_onHacerJugada);
  }

  void _onInsertarValorInicial(InsertarValorInicial event, Emitter<JuegoState> emit) {
    if (state is JuegoActivo) return;

    Casilla casillaTarget = state.tablero.obtenerCasilla(event.x, event.y);

    // 1. Validar que el jugador esté tocando una casilla con estrellita
    if (!casillaTarget.esInicial) return; 

    // 2. Validar que el número sea del 1 al 6 y no se repita
    if (state.tablero.esValidoParaInicial(event.valor)) {
      
      // Si pasa la prueba, lo guardamos
      casillaTarget.valor = event.valor;
      _valoresInicialesInsertados++;

      if (_valoresInicialesInsertados >= _totalRequeridos) {
        emit(JuegoActivo(state.tablero)); // ¡Fase completada, a jugar!
      } else {
        emit(JuegoEsperandoIniciales(
          state.tablero, 
          numerosColocados: _valoresInicialesInsertados
      ));
    }
  }
 }

  void _onHacerJugada(HacerJugada event, Emitter<JuegoState> emit) {
    // EL BLOQUEO PRINCIPAL: Si no estamos en JuegoActivo, la jugada se rechaza automáticamente.
    if (state is! JuegoActivo) return;

    // Usamos la lógica de validación que ya programamos en tu Tablero
    bool esValido = state.tablero.intentarColocarNumero(event.x, event.y, event.valor);

    if (esValido) {
      // Emitimos un nuevo estado activo para que la interfaz se redibuje
      emit(JuegoActivo(state.tablero));
    } else {
      // Emitimos un error temporal si rompe una regla de la región
      emit(JugadaInvalida(state.tablero, 'Movimiento no permitido en esta zona'));
    }
  }
}