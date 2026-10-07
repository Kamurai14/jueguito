import 'package:jueguito/tablero.dart';

abstract class JuegoState {
  final Tablero tablero;
  JuegoState(this.tablero);
}

// El candado está cerrado. El juego espera los 6 números.
class JuegoEsperandoIniciales extends JuegoState {
  final int numerosColocados;
  final int numerosRequeridos;

  JuegoEsperandoIniciales(
    super.tablero, {
    required this.numerosColocados,
    this.numerosRequeridos = 6,
  });
}

// El candado está abierto. El jugador ya puede jugar.
class JuegoActivo extends JuegoState {
  JuegoActivo(super.tablero);
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
  
  // Novedades: Puntuación y zonas completadas
  final int puntuacion;
  final Set<String> zonasCompletadas;
  final String? mensajeAlerta; // Para mostrar el SnackBar

  JuegoEnProgreso(
    super.tablero, {
    required this.dado1,
    required this.dado2,
    this.anclaSeleccionada,
    this.numeroAColocar,
    this.puntuacion = 0, // Inicia en 0 por defecto
    this.zonasCompletadas = const {}, // Inicia vacío
    this.mensajeAlerta,
  });
}