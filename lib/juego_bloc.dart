import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/casilla.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/tablero.dart';
import 'dart:math';
import 'package:jueguito/motor_reglas.dart';

class JuegoBloc extends Bloc<JuegoEvent, JuegoState> {
  // 1. AÑADIMOS EL GENERADOR ALEATORIO
  final Random _random;

  // 2. MODIFICAMOS EL CONSTRUCTOR PARA ACEPTAR EL GENERADOR COMO PARÁMETRO OPCIONAL
  JuegoBloc(Tablero tablero, {Random? generadorRandom}) 
      : _random = generadorRandom ?? Random(), 
        super(JuegoEsperandoIniciales(tablero, numerosColocados: 0)) {
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
      target.valor = null;
      _actualizarEstadoInicial(emit);
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
    
    int? valorEnDestino = destino.valor; 
    
    destino.valor = event.valor;
    origen.valor = valorEnDestino;
    _actualizarEstadoInicial(emit);
  }

  void _onHacerJugada(HacerJugada event, Emitter<JuegoState> emit) {
    // Lógica pendiente
  }

  void _actualizarEstadoInicial(Emitter<JuegoState> emit) {
    int colocados = state.tablero.contarNumerosIniciales();
    
    if (colocados >= 6) { 
      emit(JuegoActivo(state.tablero));
    } else {
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
    
    // 3. ¡EL CAMBIO MAESTRO! Usamos _random en lugar de crear un Random() nuevo.
    final rand = _random; 
    
    final siguienteId = (state is JuegoEnProgreso) 
        ? (state as JuegoEnProgreso).idTirada + 1 
        : 1;

    return JuegoEnProgreso(
      tablero,
      dado1: rand.nextInt(6) + 1,
      dado2: rand.nextInt(6) + 1,
      puntuacion: puntuacionActual,
      zonasCompletadas: zonasCompletadas,
      mensajeAlerta: mensajeAlerta,
      idTirada: siguienteId,
    );
  }

  // --- EVENTOS ---
  void _onComenzarPartida(ComenzarPartida event, Emitter<JuegoState> emit) {
    emit(_generarNuevoTurno(state.tablero, 0, {})); 
  }

  void _onSeleccionarAncla(SeleccionarAncla event, Emitter<JuegoState> emit) {
    if (state is JuegoEnProgreso) {
      final actual = state as JuegoEnProgreso;
      emit(JuegoEnProgreso(
        actual.tablero,
        dado1: actual.dado1,
        dado2: actual.dado2,
        idTirada: actual.idTirada, 
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

        if (!nuevasZonas.contains(idZona) && actual.tablero.estaZonaLlena(idZona)) {
          int puntos = MotorReglas.obtenerPuntosPrimeraVez(idZona);
          nuevaPuntuacion += puntos;
          nuevasZonas.add(idZona); 
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