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
  final bool esAnfitrion;

  JuegoBloc(Tablero tablero, {Random? generadorRandom, this.servicioRed, this.esAnfitrion = false }) 
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
    final tipo = event.datos['tipo'];

    // 1. EL SERVIDOR NOS AVISA CUÁNTOS JUGADORES YA PUSIERON SUS PIEZAS
    if (tipo == 'actualizacion_listos' && state is JuegoActivo) {
      emit(JuegoActivo(
        state.tablero, 
        listos: event.datos['listos'], 
        total: event.datos['total']
      ));
    } 
    // 2. EL SERVIDOR NOS MANDA LOS MISMOS DADOS A TODOS
    else if (tipo == 'nuevos_dados') {
      int tiradaActual = (state is JuegoEnProgreso) ? (state as JuegoEnProgreso).idTirada : 0;
      int puntosActuales = (state is JuegoEnProgreso) ? (state as JuegoEnProgreso).puntuacion : 0;
      Set<String> completadas = (state is JuegoEnProgreso) ? (state as JuegoEnProgreso).zonasCompletadas : {};
      Map<String, int> global = (state is JuegoEnProgreso) ? (state as JuegoEnProgreso).estadoZonasGlobal : {};

      emit(JuegoEnProgreso(
        state.tablero,
        dado1: event.datos['dado1'],
        dado2: event.datos['dado2'],
        puntuacion: puntosActuales,
        zonasCompletadas: completadas,
        estadoZonasGlobal: global,
        idTirada: tiradaActual + 1,
      ));
    }
    // 3. EL SERVIDOR NOS AVISA QUE ALGUIEN MÁS (O NOSOTROS MISMOS) LLENÓ UNA ZONA
    else if (tipo == 'zona_reclamada' && state is JuegoEnProgreso) {
      final actual = state as JuegoEnProgreso;
      final idZona = event.datos['idZona'];
      final lugar = event.datos['lugar'];
      final usuario = event.datos['usuario'];

      final nuevoEstadoGlobal = Map<String, int>.from(actual.estadoZonasGlobal);
      nuevoEstadoGlobal[idZona] = lugar;

      int nuevaPuntuacion = actual.puntuacion;
      String alerta = '¡$usuario reclamó la zona $idZona en lugar #$lugar!';

      if (servicioRed != null && usuario == servicioRed!.usuarioActual) {
        int puntos = MotorReglas.obtenerPuntos(idZona, lugar, mapaActual: actual.tablero.capa.tipoMapa);
        nuevaPuntuacion += puntos;
        alerta = '¡Validado! Ganaste el lugar #$lugar en $idZona (+$puntos pts) 🏆';
      }
      
      emit(JuegoEnProgreso(
        actual.tablero,
        dado1: actual.dado1,                 
        dado2: actual.dado2,
        idTirada: actual.idTirada,           
        anclaSeleccionada: actual.anclaSeleccionada, 
        numeroAColocar: actual.numeroAColocar,
        puntuacion: nuevaPuntuacion,         
        zonasCompletadas: actual.zonasCompletadas,
        estadoZonasGlobal: nuevoEstadoGlobal, 
        turnoTerminado: actual.turnoTerminado, 
        mensajeAlerta: alerta
      ));
    }
    // 4. EL ANFITRIÓN CERRÓ LA SALA O NUESTRO INTERNET SE CAYÓ
    else if (tipo == 'sala_cerrada' || tipo == 'desconexion_local') {
      servicioRed?.desconectar();
      
      // Creamos un tablero completamente nuevo basado en la misma capa del mapa actual
      emit(JuegoEsperandoIniciales(
        Tablero(state.tablero.capa), 
        numerosColocados: 0,
        mensajeAlerta: event.datos['razon'] ?? 'Desconectado de la partida.'
      ));
    }
    // 5. UN INVITADO ABANDONÓ LA SALA
    else if (tipo == 'jugador_abandono') {
      if (state is JuegoActivo) {
        final actual = state as JuegoActivo;
        emit(JuegoActivo(
          actual.tablero,
          listos: actual.listos,
          total: event.datos['total'] ?? actual.total, 
        ));
      } else if (state is JuegoEnProgreso) {
        final actual = state as JuegoEnProgreso;
        emit(JuegoEnProgreso(
          actual.tablero,
          dado1: actual.dado1,
          dado2: actual.dado2,
          idTirada: actual.idTirada,
          anclaSeleccionada: actual.anclaSeleccionada,
          numeroAColocar: actual.numeroAColocar,
          puntuacion: actual.puntuacion,
          zonasCompletadas: actual.zonasCompletadas,
          estadoZonasGlobal: actual.estadoZonasGlobal,
          turnoTerminado: actual.turnoTerminado, 
          mensajeAlerta: '⚠️ ${event.datos['usuario']} abandonó la partida.'
        ));
      }
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
      if (servicioRed != null) servicioRed!.declararListo(); // <-- Le grita al servidor "¡Ya acabé!"
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
    if (servicioRed != null) {
      if (esAnfitrion) servicioRed!.tirarDadosGlobales();
    } else {
      emit(_generarNuevoTurno(state.tablero, 0, {})); // Solitario sigue normal
    }
  }

  void _onPasarTurno(PasarTurno event, Emitter<JuegoState> emit) {
    if (state is JuegoEnProgreso) {
      final actual = state as JuegoEnProgreso;
      
      if (servicioRed != null) {
        if (!actual.turnoTerminado) servicioRed!.terminarTurno(); // Solo avisa si no lo había hecho
        
        emit(JuegoEnProgreso(
          actual.tablero,
          dado1: actual.dado1,
          dado2: actual.dado2,
          puntuacion: actual.puntuacion,
          zonasCompletadas: actual.zonasCompletadas,
          estadoZonasGlobal: actual.estadoZonasGlobal,
          idTirada: actual.idTirada, 
          anclaSeleccionada: null,   
          numeroAColocar: null,      
          turnoTerminado: true, // <-- ¡NUEVO! BLOQUEO ACTIVADO
          mensajeAlerta: 'Turno terminado. Esperando a los demás...'
        ));
      } else {
        // Modo un jugador (Offline)
        emit(_generarNuevoTurno(actual.tablero, actual.puntuacion, actual.zonasCompletadas, estadoGlobal: actual.estadoZonasGlobal));
      }
    }
  }

  void _onSeleccionarAncla(SeleccionarAncla event, Emitter<JuegoState> emit) {
    if (state is JuegoEnProgreso) {
      final actual = state as JuegoEnProgreso;
      // EL FIX: Si ya jugó, lo ignoramos
      if (actual.turnoTerminado) return; 
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
        turnoTerminado: actual.turnoTerminado, 
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
            // MULTIJUGADOR: Mandamos nuestro turno para el desempate, pero NO nos sumamos puntos aún.
            servicioRed!.reclamarZona(idZona, actual.idTirada);
            alertaPersonalizada = 'Validando zona $idZona con el servidor...';
          } else {
            // UN JUGADOR: Asumimos 1er lugar directamente
            int puntos = MotorReglas.obtenerPuntos(idZona, 1, mapaActual: actual.tablero.capa.tipoMapa);
            nuevaPuntuacion += puntos;
            alertaPersonalizada = '¡Zona $idZona completada! +$puntos puntos 🏆';
          }
        }

        if (servicioRed != null) {
          servicioRed!.terminarTurno(); 

          emit(JuegoEnProgreso(
            actual.tablero,
            dado1: actual.dado1, 
            dado2: actual.dado2, 
            idTirada: actual.idTirada, 
            anclaSeleccionada: null, 
            numeroAColocar: null, 
            puntuacion: nuevaPuntuacion,
            zonasCompletadas: nuevasZonas,
            estadoZonasGlobal: actual.estadoZonasGlobal,
            turnoTerminado: true, // <-- ¡NUEVO! BLOQUEO ACTIVADO
            mensajeAlerta: alertaPersonalizada ?? 'Jugada lista. Esperando a los demás...'
          ));
        } else {
          // UN JUGADOR (OFFLINE): Avanza el turno automáticamente como antes
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
  }

}