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
    // 2. EL SERVIDOR NOS MANDA LOS PRIMEROS DADOS (Al iniciar la partida)
    else if (tipo == 'nuevos_dados') {
      int tiradaActual = (state is JuegoEnProgreso) ? (state as JuegoEnProgreso).idTirada : 0;
      int puntosActuales = (state is JuegoEnProgreso) ? (state as JuegoEnProgreso).puntuacion : 0;
      Set<String> completadas = (state is JuegoEnProgreso) ? (state as JuegoEnProgreso).zonasCompletadas : {};
      Map<String, int> global = (state is JuegoEnProgreso) ? (state as JuegoEnProgreso).estadoZonasGlobal : {};
      int totalJugadores = (state is JuegoActivo) ? (state as JuegoActivo).total : (state is JuegoEnProgreso ? (state as JuegoEnProgreso).totalJugadores : 1);

      emit(JuegoEnProgreso(
        state.tablero,
        dado1: event.datos['dado1'],
        dado2: event.datos['dado2'],
        puntuacion: puntosActuales,
        zonasCompletadas: completadas,
        estadoZonasGlobal: global,
        idTirada: tiradaActual + 1,
        totalJugadores: totalJugadores,
      ));
    }
    // 3. EL SERVIDOR NOS MANDA EL RESUMEN DEL TURNO COMPLETO
    else if (tipo == 'resumen_turno' && state is JuegoEnProgreso) {
      final actual = state as JuegoEnProgreso;
      int tiradaActual = actual.idTirada;
      
      Map<String, int> nuevoEstadoGlobal = Map<String, int>.from(actual.estadoZonasGlobal);
      String alertasGlobales = '';

      // Procesar los avisos acumulados en el turno
      List avisos = event.datos['avisos_zonas'] ?? [];
      for (var aviso in avisos) {
        String idZona = aviso['idZona'];
        int lugar = aviso['lugar'];
        String usuario = aviso['usuario'];

        nuevoEstadoGlobal[idZona] = lugar;

        // Solo generamos aviso visual para los rivales, el nuestro ya nos lo dio al instante
        if (servicioRed != null && usuario != servicioRed!.usuarioActual) {
          alertasGlobales += 'Aviso: $usuario llenó $idZona ocupando el lugar $lugar.\n';
        }
      }

      // Separar la información de los rivales (Mapas dinámicos de Dart)
      Map<String, dynamic> tRivales = Map<String, dynamic>.from(event.datos['tableros']);
      Map<String, dynamic> pRivales = Map<String, dynamic>.from(event.datos['puntuaciones']);
      
      if (servicioRed != null) {
        // Quitamos nuestros propios datos para no vernos en la sección de rivales
        tRivales.remove(servicioRed!.usuarioActual);
        pRivales.remove(servicioRed!.usuarioActual);
      }

      // Evaluamos victoria aquí si alguien alcanzó el límite
      _verificarFinDePartida(actual, actual.puntuacion, emit, esOffline: false);
      
      if (state is! JuegoTerminado) {
        emit(JuegoEnProgreso(
          actual.tablero,
          dado1: event.datos['dado1'],
          dado2: event.datos['dado2'],
          puntuacion: actual.puntuacion,
          zonasCompletadas: actual.zonasCompletadas,
          estadoZonasGlobal: nuevoEstadoGlobal,
          idTirada: tiradaActual + 1,
          totalJugadores: actual.totalJugadores,
          tablerosRivales: tRivales,
          puntuacionesRivales: pRivales,
          mensajeAlerta: alertasGlobales.isNotEmpty ? alertasGlobales.trim() : 'Turno nuevo disponible.',
        ));
      }
    }
    // 4. EL ANFITRIÓN CERRÓ LA SALA O NUESTRO INTERNET SE CAYÓ
    else if (tipo == 'sala_cerrada' || tipo == 'desconexion_local') {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!isClosed && state is! JuegoTerminado) {
          servicioRed?.desconectar();
          emit(JuegoEsperandoIniciales(
            Tablero(state.tablero.capa), 
            numerosColocados: 0,
            mensajeAlerta: event.datos['razon'] ?? 'Desconectado de la partida.'
          ));
        }
      });
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
          totalJugadores: actual.totalJugadores,
          tablerosRivales: actual.tablerosRivales,
          puntuacionesRivales: actual.puntuacionesRivales,
          mensajeAlerta: 'Aviso: ${event.datos['usuario']} abandonó la partida.'
        ));
      }
    }
    // 6. VICTORIA POR ABANDONO
    else if (tipo == 'victoria_por_abandono') {
      int puntos = (state is JuegoEnProgreso) ? (state as JuegoEnProgreso).puntuacion : 0;
      emit(
        JuegoTerminado(
          state.tablero,
          mensaje: event.datos['mensaje'],
          puntuacionFinal: puntos,
          esVictoria: true,
        ),
      );
      servicioRed?.desconectar();
    }
    // 7. FIN DE PARTIDA GLOBAL (ONLINE)
    else if (tipo == 'fin_de_partida') {
      servicioRed?.desconectar();
      List ranking = event.datos['ranking'];
      bool ganaste = ranking.isNotEmpty && ranking[0]['usuario'] == servicioRed?.usuarioActual;
      
      emit(JuegoTerminado(
        state.tablero, 
        mensaje: ganaste ? '¡Eres el ganador indiscutible!' : '${ranking[0]['usuario']} ha ganado con ${ranking[0]['puntuacion']} puntos.', 
        puntuacionFinal: (state is JuegoEnProgreso) ? (state as JuegoEnProgreso).puntuacion : 0, 
        esVictoria: ganaste,
        rankingFinal: ranking,
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
      if (servicioRed != null) servicioRed!.declararListo();
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
    {Map<String, int>? estadoGlobal, String? mensajeAlerta, int? totalJugadores}
  ) {
    final rand = _random; 
    final siguienteId = (state is JuegoEnProgreso) ? (state as JuegoEnProgreso).idTirada + 1 : 1;
    final global = estadoGlobal ?? (state is JuegoEnProgreso ? (state as JuegoEnProgreso).estadoZonasGlobal : <String, int>{});
    final total = totalJugadores ?? (state is JuegoEnProgreso ? (state as JuegoEnProgreso).totalJugadores : 1);

    return JuegoEnProgreso(
      tablero,
      dado1: rand.nextInt(6) + 1,
      dado2: rand.nextInt(6) + 1,
      puntuacion: puntuacionActual,
      zonasCompletadas: zonasCompletadas,
      estadoZonasGlobal: global,
      mensajeAlerta: mensajeAlerta,
      idTirada: siguienteId,
      totalJugadores: total,
    );
  }

  void _onComenzarPartida(ComenzarPartida event, Emitter<JuegoState> emit) {
    int total = (state is JuegoActivo) ? (state as JuegoActivo).total : 1;
    
    if (servicioRed != null) {
      if (esAnfitrion) servicioRed!.tirarDadosGlobales();
    } else {
      emit(_generarNuevoTurno(state.tablero, 0, {}, totalJugadores: total)); 
    }
  }

  void _onPasarTurno(PasarTurno event, Emitter<JuegoState> emit) {
    if (state is JuegoEnProgreso) {
      final actual = state as JuegoEnProgreso;
      
      if (servicioRed != null) {
        if (!actual.turnoTerminado) {
          // Exportamos el tablero y la puntuación
          servicioRed!.terminarTurno(actual.tablero.exportarTableroSimple(), actual.puntuacion);
        }
        
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
          turnoTerminado: true,
          totalJugadores: actual.totalJugadores,
          tablerosRivales: actual.tablerosRivales,
          puntuacionesRivales: actual.puntuacionesRivales,
          mensajeAlerta: 'Turno terminado. Esperando a los demás...'
        ));
      } else {
        // Modo un jugador (Offline)
        if (actual.idTirada >= 22) {
          emit(JuegoTerminado(actual.tablero, mensaje: '¡Juego Solitario Terminado! Has sobrevivido 22 turnos.', puntuacionFinal: actual.puntuacion, esVictoria: true));
        } else {
          emit(_generarNuevoTurno(actual.tablero, actual.puntuacion, actual.zonasCompletadas, estadoGlobal: actual.estadoZonasGlobal));
        }
      }
    }
  }

  void _onSeleccionarAncla(SeleccionarAncla event, Emitter<JuegoState> emit) {
    if (state is JuegoEnProgreso) {
      final actual = state as JuegoEnProgreso;
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
        totalJugadores: actual.totalJugadores,
        tablerosRivales: actual.tablerosRivales,
        puntuacionesRivales: actual.puntuacionesRivales,
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

        // Comprobamos si la zona se acaba de llenar con esta jugada
        if (!nuevasZonas.contains(idZona) && actual.tablero.estaZonaLlena(idZona)) {
          nuevasZonas.add(idZona); 

          if (servicioRed != null) {
            // Mandamos el aviso al servidor de que la llenamos
            servicioRed!.reclamarZona(idZona, actual.idTirada);
            
            // Calculamos nuestra recompensa de forma local para dar el feedback instantáneo
            int lugarLocal = (actual.estadoZonasGlobal[idZona] ?? 0) + 1;
            int puntos = MotorReglas.obtenerPuntos(idZona, lugarLocal, mapaActual: actual.tablero.capa.tipoMapa);
            nuevaPuntuacion += puntos;
            alertaPersonalizada = 'Has llenado la zona $idZona. +$puntos puntos obtenidos.';
          } else {
            // Un jugador
            int puntos = MotorReglas.obtenerPuntos(idZona, 1, mapaActual: actual.tablero.capa.tipoMapa);
            nuevaPuntuacion += puntos;
            alertaPersonalizada = 'Has llenado la zona $idZona. +$puntos puntos obtenidos.';
          }
        }

        if (servicioRed != null) {
          // Exportamos el tablero y cerramos el turno
          servicioRed!.terminarTurno(actual.tablero.exportarTableroSimple(), nuevaPuntuacion); 

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
            turnoTerminado: true,
            totalJugadores: actual.totalJugadores,
            tablerosRivales: actual.tablerosRivales,
            puntuacionesRivales: actual.puntuacionesRivales,
            mensajeAlerta: alertaPersonalizada ?? 'Jugada registrada. Esperando a los demás jugadores.'
          ));
        } else {
          // UN JUGADOR (OFFLINE)
          _verificarFinDePartida(actual, nuevaPuntuacion, emit, esOffline: true);
          if (state is! JuegoTerminado) {
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

  // ==========================================================
  // EVALUADOR DE FIN DE PARTIDA
  // ==========================================================
  void _verificarFinDePartida(JuegoEnProgreso actual, int nuevaPuntuacion, Emitter<JuegoState> emit, {bool esOffline = false}) {
    int limite = 26;
    if (actual.totalJugadores == 3) limite = 24;
    else if (actual.totalJugadores == 4) limite = 22;
    else if (actual.totalJugadores >= 5) limite = 20;

    if (esOffline) {
      if (actual.idTirada >= 22) {
        emit(JuegoTerminado(actual.tablero, mensaje: '¡Juego Solitario Terminado! Has sobrevivido 22 turnos.', puntuacionFinal: nuevaPuntuacion, esVictoria: true));
      }
    } else {
      if (nuevaPuntuacion >= limite) {
        servicioRed!.declararVictoria(nuevaPuntuacion);
      }
    }
  }
}