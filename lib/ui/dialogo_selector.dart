import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/casilla.dart';

Future<void> mostrarSelectorAbanico(BuildContext context, int x, int y, JuegoState state, Offset posicionDestino) async {
  Casilla casillaActual = state.tablero.obtenerCasilla(x, y);

  final resultado = await showGeneralDialog<dynamic>(
    context: context,
    barrierColor: Colors.black87, 
    barrierDismissible: true,
    barrierLabel: 'Cerrar',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return PantallaAbanico(
        posicionDestino: posicionDestino,
        valorActual: casillaActual.valor,
      );
    },
  );

  if (resultado == 'borrar') {
    if (context.mounted) context.read<JuegoBloc>().add(QuitarValorInicial(x, y));
  } else if (resultado is int) {
    int numero = resultado;
    Casilla? existente = state.tablero.buscarCasillaInicialConValor(numero);
    
    if (existente != null && (existente.coordenada.x != x || existente.coordenada.y != y)) {
      if (context.mounted) {
        _mostrarConfirmacionReemplazo(context, existente.coordenada.x, existente.coordenada.y, x, y, numero, casillaActual.valor);
      }
    } else {
      if (context.mounted) context.read<JuegoBloc>().add(InsertarValorInicial(x, y, numero));
    }
  }
}

// ==========================================
// WIDGET DEL ABANICO (VERSIÓN RESPONSIVE / ESCRITORIO)
// ==========================================
class PantallaAbanico extends StatefulWidget {
  final Offset posicionDestino;
  final int? valorActual;

  const PantallaAbanico({super.key, required this.posicionDestino, this.valorActual});

  @override
  State<PantallaAbanico> createState() => _PantallaAbanicoState();
}

class _PantallaAbanicoState extends State<PantallaAbanico> {
  bool _abierto = false;
  bool _volando = false;
  int? _numeroElegido;

  // Ángulos ligeramente más cerrados para que quepan perfecto en cualquier pantalla
  final List<double> angulos = [-50.0, -30.0, -10.0, 10.0, 30.0, 50.0];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _abierto = true);
    });
  }

  void _seleccionarCarta(int numero) {
    if (numero == widget.valorActual) return; 

    setState(() {
      _numeroElegido = numero;
      _volando = true; 
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.of(context).pop(numero);
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    
    // Medidas base de nuestra carta
    const double anchoCarta = 80.0;
    const double altoCarta = 120.0;
    
    // Calculamos el centro inferior de la pantalla
    final double centroX = media.width / 2;

    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Stack(
        children: [
          // Botones de acción ubicados justo encima del abanico
          Positioned(
            bottom: 240, // Los subimos un poco para que no choquen con las cartas
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (widget.valorActual != null && !_volando)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Borrar número'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, 
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                    ),
                    onPressed: () => Navigator.of(context).pop('borrar'),
                  ),
                const SizedBox(height: 16),
                if (!_volando)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(foregroundColor: Colors.white70),
                    child: const Text('Cancelar', style: TextStyle(fontSize: 18)),
                  )
              ],
            ),
          ),
          
          // Generamos las 6 cartas
          ...List.generate(6, (index) {
            int numero = index + 1;
            bool esElElegido = _numeroElegido == numero;
            bool esElMismoDeLaCasilla = numero == widget.valorActual;

            // Variables de posición absoluta
            double left;
            double top;
            double rotacion = 0;
            double opacidad = 1.0;
            double escala = 1.0;

            double anguloRad = angulos[index] * math.pi / 180;

            if (!_abierto) {
              // ESTADO INICIAL: Escondidas debajo de la pantalla
              left = centroX - (anchoCarta / 2);
              top = media.height + 50; 
            } else if (_volando) {
              if (esElElegido) {
                // FÓRMULA DE VUELO: Calculamos la coordenada exacta del cuadrito en la pantalla
                left = widget.posicionDestino.dx - (anchoCarta / 2);
                top = widget.posicionDestino.dy - (altoCarta / 2);
                rotacion = 0;
                escala = 0.4; // Se encoge para caber en la casilla
              } else {
                // Las cartas no elegidas se quedan en su lugar del abanico pero se hacen invisibles
                left = centroX - (anchoCarta / 2) + math.sin(anguloRad) * 180;
                top = (media.height - 180) + (1 - math.cos(anguloRad)) * 60;
                rotacion = anguloRad;
                escala = 0.8;
                opacidad = 0.0;
              }
            } else {
              // ESTADO ABANICO: Abierto desde el fondo de la pantalla
              left = centroX - (anchoCarta / 2) + math.sin(anguloRad) * 180; // Expansión horizontal
              top = (media.height - 180) + (1 - math.cos(anguloRad)) * 60; // Caída curva (arco)
              rotacion = anguloRad;
              
              if (esElMismoDeLaCasilla) opacidad = 0.5; // Apagamos el número que ya está puesto
            }

            // Usamos AnimatedPositioned para la traslación (X, Y) y AnimatedContainer para rotación y escala
            return AnimatedPositioned(
              duration: Duration(milliseconds: _volando ? 500 : 400),
              curve: _volando ? Curves.easeInOutCubic : Curves.easeOutBack,
              left: left,
              top: top,
              child: AnimatedContainer(
                duration: Duration(milliseconds: _volando ? 500 : 400),
                curve: Curves.easeInOut,
                transformAlignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(rotacion)
                  ..scale(escala),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: opacidad,
                  child: GestureDetector(
                    onTap: esElMismoDeLaCasilla || _volando ? null : () => _seleccionarCarta(numero),
                    child: Container(
                      width: anchoCarta,
                      height: altoCarta,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: esElMismoDeLaCasilla ? Colors.grey : Colors.blue, width: 3),
                        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))]
                      ),
                      child: Center(
                        child: Text(
                          numero.toString(),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: esElMismoDeLaCasilla ? Colors.grey : Colors.blue
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ==========================================
// ALERTA DE REEMPLAZO 
// ==========================================
void _mostrarConfirmacionReemplazo(BuildContext context, int xOrigen, int yOrigen, int xDestino, int yDestino, int numero, int? valorDestino) {
  String mensaje = valorDestino != null 
      ? 'El número $numero ya está en otra casilla. ¿Deseas intercambiarlo por el $valorDestino?'
      : 'El número $numero ya está en otra casilla. ¿Deseas moverlo a esta nueva posición?';

  showDialog(
    context: context,
    builder: (BuildContext confirmContext) {
      return AlertDialog(
        title: Text(valorDestino != null ? 'Intercambiar números' : 'Número ya utilizado'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(confirmContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<JuegoBloc>().add(MoverValorInicial(xOrigen, yOrigen, xDestino, yDestino, numero));
              Navigator.of(confirmContext).pop();
            },
            child: Text(valorDestino != null ? 'Sí, intercambiar' : 'Sí, mover'),
          ),
        ],
      );
    }
  );
}