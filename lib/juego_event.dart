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

class MoverValorInicial extends JuegoEvent {
  final int xOrigen;
  final int yOrigen;
  final int xDestino;
  final int yDestino;
  final int valor;

  MoverValorInicial(this.xOrigen, this.yOrigen, this.xDestino, this.yDestino, this.valor);
}

class QuitarValorInicial extends JuegoEvent {
  final int x;
  final int y;

  QuitarValorInicial(this.x, this.y);
}