import 'package:jueguito/tablero.dart';

abstract class JuegoState {
  final Tablero tablero;
  JuegoState(this.tablero);
}

// El candado está cerrado. El juego espera los 6 números.
class JuegoEsperandoIniciales extends JuegoState {
  final int numerosColocados;
  final int numerosRequeridos;
  final String? mensajeAlerta;

  JuegoEsperandoIniciales(
    super.tablero, {
    required this.numerosColocados,
    this.numerosRequeridos = 6,
    this.mensajeAlerta,
  });
}

// El candado está abierto. El jugador ya puede jugar.
class JuegoActivo extends JuegoState {
  final int listos;
  final int total;

  JuegoActivo(super.tablero, {this.listos = 0, this.total = 1});
}

// Opcional: Para mostrar un mensaje si la jugada fue inválida
class JugadaInvalida extends JuegoActivo {
  final String mensaje;
  JugadaInvalida(super.tablero, this.mensaje);
}

class JuegoEnProgreso extends JuegoState {
  final int dado1;
  final int dado2;
  final int? anclaSeleccionada;
  final int? numeroAColocar;
  final int idTirada;
  
  final int puntuacion;
  final Set<String> zonasCompletadas; // Zonas que TÚ ya llenaste
  final Map<String, int> estadoZonasGlobal; // NUEVO: Zonas reclamadas por TODOS { 'AM': 1, 'NA1': 3 }
  final String? mensajeAlerta;
  final bool turnoTerminado; // <-- NUEVO: Bandera de bloqueo

  JuegoEnProgreso(
    super.tablero, {
    required this.dado1,
    required this.dado2,
    required this.idTirada,
    this.anclaSeleccionada,
    this.numeroAColocar,
    this.puntuacion = 0,
    this.zonasCompletadas = const {},
    this.estadoZonasGlobal = const {}, // Inicia vacío
    this.mensajeAlerta,
    this.turnoTerminado = false, // Por defecto, el turno no está terminado
  });
}