import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/casilla.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/tablero.dart';
import 'package:jueguito/motor_reglas.dart';
import 'package:jueguito/servicios/servicio_multiplayer.dart';
import 'dart:convert';

class JuegoBloc extends Bloc<JuegoEvent, JuegoState> {
  final Random _random;
  final ServicioMultiplayer? servicioRed; // El túnel hacia el servidor
  StreamSubscription? _suscripcionRed;    // Para escuchar en tiempo real

  JuegoBloc(Tablero tablero, {Random? generadorRandom, this.servicioRed}) 
      : _random = generadorRandom ?? Random(), 
        super(JuegoEsperandoIniciales(tablero, numerosColocados: 0)) {
    
    // Si estamos en multijugador, conectamos el oído del BLoC al servidor
    if (servicioRed != null && servicioRed!.streamMensajes != null) {
      _suscripcionRed = servicioRed!.streamMensajes!.listen((mensajeStr) {
        add(RecibirMensajeServidor(jsonDecode(mensajeStr)));
      });
    }

    on<InsertarValorInicial>(_onInsertarValorInicial);
    on<MoverValorInicial>(_onMoverValorInicial);
    on<QuitarValorInicial>(_onQuitarValorInicial);
    on<ComenzarPartida>(_onComenzarPartida);
    on<SeleccionarAncla>(_onSeleccionarAncla);
    on<ColocarJugada>(_onColocarJugada);
    on<PasarTurno>(_onPasarTurno);
    on<RecibirMensajeServidor>(_onRecibirMensajeServidor);
  }

  @override
  Future<void> close() {
    _suscripcionRed?.cancel(); // Apagamos el oído al cerrar la pantalla
    return super.close();
  }

  // ==========================================================
  // LÓGICA DE RED (ESCUCHAR AL SERVIDOR)
  // ==========================================================
  void _onRecibirMensajeServidor(RecibirMensajeServidor event, Emitter<JuegoState> emit) {
    if (state is! JuegoEnProgreso) return;
    final actual = state as JuegoEnProgreso;
    final tipo = event.datos['tipo'];

    if (tipo == 'zona_reclamada') {
      final idZona = event.datos['idZona'];
      final lugar = event.datos['lugar']; // 1, 2 o 3

      // Actualizamos cómo va el mundo
      final nuevoEstadoGlobal = Map<String, int>.from(actual.estadoZonasGlobal);
      nuevoEstadoGlobal[idZona] = lugar;

      emit(_generarNuevoTurno(
        actual.tablero, 
        actual.puntuacion, 
        actual.zonasCompletadas,
        estadoGlobal: nuevoEstadoGlobal,
        // Si no fui yo quien lo reclamó, muestro una alerta avisando que alguien me ganó
        mensajeAlerta: '¡Alguien reclamó la zona $idZona en lugar #$lugar!'
      ));
    }
  }

  // ==========================================================
  // EVENTOS DE PREPARACIÓN DE TABLERO
  // ==========================================================
  void _onQuitarValorInicial(QuitarValorInicial event, Emitter<JuegoState> emit) {
    Casilla target = state.tablero.obtenerCasilla(event.x, event.y);
    if (target.esInicial) {
      target.valor = null;
      _actualizarEstadoInicial(emit);
    }
  }

  void _onInsertarValorInicial(InsertarValorInicial event, Emitter<JuegoState> emit) {
    String? error = state.tablero.validarColocacionInicial(event.x, event.y, event.valor);
    if (error != null) {
      emit(JuegoEsperandoIniciales(state.tablero, numerosColocados: state.tablero.contarNumerosIniciales(), mensajeAlerta: error));
      return; 
    }
    Casilla target = state.tablero.obtenerCasilla(event.x, event.y);
    if (target.esInicial) {
      target.valor = event.valor;
      _actualizarEstadoInicial(emit);
    }
  }

  void _onMoverValorInicial(MoverValorInicial event, Emitter<JuegoState> emit) {
    String? error = state.tablero.validarColocacionInicial(event.xDestino, event.yDestino, event.valor);
    if (error != null) {
      emit(JuegoEsperandoIniciales(state.tablero, numerosColocados: state.tablero.contarNumerosIniciales(), mensajeAlerta: error));
      return;
    }
    Casilla origen = state.tablero.obtenerCasilla(event.xOrigen, event.yOrigen);
    Casilla destino = state.tablero.obtenerCasilla(event.xDestino, event.yDestino);
    int? valorEnDestino = destino.valor; 
    destino.valor = event.valor;
    origen.valor = valorEnDestino;
    _actualizarEstadoInicial(emit);
  }

  void _actualizarEstadoInicial(Emitter<JuegoState> emit) {
    int colocados = state.tablero.contarNumerosIniciales();
    if (colocados >= 6) { 
      emit(JuegoActivo(state.tablero));
    } else {
      emit(JuegoEsperandoIniciales(state.tablero, numerosColocados: colocados));
    }
  }

  // ==========================================================
  // EVENTOS DE LA PARTIDA
  // ==========================================================
  JuegoEnProgreso _generarNuevoTurno(
    Tablero tablero, 
    int puntuacionActual, 
    Set<String> zonasCompletadas,
    {Map<String, int>? estadoGlobal, String? mensajeAlerta}
  ) {
    final rand = _random; 
    final siguienteId = (state is JuegoEnProgreso) ? (state as JuegoEnProgreso).idTirada + 1 : 1;
    final global = estadoGlobal ?? (state is JuegoEnProgreso ? (state as JuegoEnProgreso).estadoZonasGlobal : <String, int>{});

    return JuegoEnProgreso(
      tablero,
      dado1: rand.nextInt(6) + 1,
      dado2: rand.nextInt(6) + 1,
      puntuacion: puntuacionActual,
      zonasCompletadas: zonasCompletadas,
      estadoZonasGlobal: global,
      mensajeAlerta: mensajeAlerta,
      idTirada: siguienteId,
    );
  }

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
        estadoZonasGlobal: actual.estadoZonasGlobal,
      ));
    }
  }

  void _onColocarJugada(ColocarJugada event, Emitter<JuegoState> emit) {
    if (state is JuegoEnProgreso) {
      final actual = state as JuegoEnProgreso;
      bool colocado = actual.tablero.intentarColocarNumero(event.x, event.y, event.numero);
      
      if (colocado) {
        String idZona = actual.tablero.obtenerIdZonaDeCasilla(event.x, event.y);
        int nuevaPuntuacion = actual.puntuacion;
        Set<String> nuevasZonas = Set.from(actual.zonasCompletadas);
        String? alertaPersonalizada;

        // ¿Llenamos la zona y no la habíamos marcado antes?
        if (!nuevasZonas.contains(idZona) && actual.tablero.estaZonaLlena(idZona)) {
          nuevasZonas.add(idZona); 

          if (servicioRed != null) {
            // MULTIJUGADOR: Avisamos al servidor para que nos asigne un lugar (1ero, 2do o 3ro)
            servicioRed!.enviarJugada({
              'accion': 'reclamar_zona',
              'idZona': idZona
            });
            alertaPersonalizada = 'Validando zona $idZona con el servidor...';
          } else {
            // UN JUGADOR (OFFLINE): Nos damos los puntos máximos directo
            int puntos = MotorReglas.obtenerPuntosPrimeraVez(idZona);
            nuevaPuntuacion += puntos;
            alertaPersonalizada = '¡Zona $idZona completada! +$puntos puntos 🏆';
          }
        }

        emit(_generarNuevoTurno(
          actual.tablero, 
          nuevaPuntuacion, 
          nuevasZonas,
          estadoGlobal: actual.estadoZonasGlobal,
          mensajeAlerta: alertaPersonalizada
        ));
      }
    }
  }

  void _onPasarTurno(PasarTurno event, Emitter<JuegoState> emit) {
    if (state is JuegoEnProgreso) {
      final actual = state as JuegoEnProgreso;
      emit(_generarNuevoTurno(actual.tablero, actual.puntuacion, actual.zonasCompletadas, estadoGlobal: actual.estadoZonasGlobal));
    }
  }
}