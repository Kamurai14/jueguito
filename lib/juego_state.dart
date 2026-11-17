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
  final Set<String> zonasCompletadas; 
  final Map<String, int> estadoZonasGlobal; 
  final String? mensajeAlerta;
  final bool turnoTerminado; 
  final int totalJugadores;
  
  // Nuevos campos
  final Map<String, dynamic> tablerosRivales;
  final Map<String, dynamic> puntuacionesRivales;

  JuegoEnProgreso(
    super.tablero, {
    required this.dado1,
    required this.dado2,
    required this.idTirada,
    this.anclaSeleccionada,
    this.numeroAColocar,
    this.puntuacion = 0,
    this.zonasCompletadas = const {},
    this.estadoZonasGlobal = const {}, 
    this.mensajeAlerta,
    this.turnoTerminado = false, 
    this.totalJugadores = 1, 
    this.tablerosRivales = const {},
    this.puntuacionesRivales = const {},
  });
}

class JuegoTerminado extends JuegoState {
  final String mensaje;
  final int puntuacionFinal;
  final bool esVictoria;
  final List<dynamic>? rankingFinal; // Nuevo campo

  JuegoTerminado(super.tablero, {
    required this.mensaje, 
    required this.puntuacionFinal, 
    required this.esVictoria,
    this.rankingFinal
  });
}