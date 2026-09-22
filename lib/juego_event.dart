abstract class JuegoEvent {}

// Evento para insertar los 6 valores iniciales
class InsertarValorInicial extends JuegoEvent {
  final int x;
  final int y;
  final int valor;

  InsertarValorInicial(this.x, this.y, this.valor);
}

// Evento para cuando el jugador intenta hacer un movimiento normal
class HacerJugada extends JuegoEvent {
  final int x;
  final int y;
  final int valor;

  HacerJugada(this.x, this.y, this.valor);
}