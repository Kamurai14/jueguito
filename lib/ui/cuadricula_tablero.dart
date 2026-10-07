import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/casilla.dart';
import 'package:jueguito/ui/dialogo_selector.dart';

class CuadriculaTablero extends StatelessWidget {
  final JuegoState state;
  final AnimationController animController;
  
  const CuadriculaTablero({super.key, required this.state, required this.animController});

  Color _obtenerColorZona(String idZona) {
    if (idZona.startsWith('AM')) return Colors.amber[400]!;
    if (idZona.startsWith('AZ')) return Colors.blue[400]!;
    if (idZona.startsWith('VE')) return Colors.green[400]!;
    if (idZona.startsWith('MO')) return Colors.purple[400]!;
    if (idZona.startsWith('RO')) return Colors.red[400]!;
    return Colors.grey[400]!; 
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, 
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 49, 
      itemBuilder: (context, index) {
        int x = index % 7;
        int y = 6 - (index ~/ 7); 
        Casilla casilla = state.tablero.obtenerCasilla(x, y);

        return Builder(
          builder: (celdaContext) {
            bool mostrarBrilloInicial = casilla.esInicial && state is! JuegoEnProgreso;
            bool esSugerencia = false;

            // Casteo local para la lógica de sugerencias
            if (state is JuegoEnProgreso) {
              final estadoJuego = state as JuegoEnProgreso;
              
              if (estadoJuego.anclaSeleccionada != null && !casilla.esInicial && casilla.estaVacia) {
                bool esAdyacente = estadoJuego.tablero.esAdyacenteAValor(x, y, estadoJuego.anclaSeleccionada!);
                bool esValida = estadoJuego.tablero.esColocacionValida(x, y, estadoJuego.numeroAColocar!);
                esSugerencia = esAdyacente && esValida;
              }
            }

            return GestureDetector(
              onTap: () {
                if (state is JuegoEnProgreso) {
                  // Casteo local para la lógica de validación del clic
                  final estadoJuego = state as JuegoEnProgreso;

                  if (!casilla.esInicial && casilla.estaVacia) {
                    if (estadoJuego.anclaSeleccionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un ancla primero.')));
                      return;
                    }
                    if (!estadoJuego.tablero.esAdyacenteAValor(x, y, estadoJuego.anclaSeleccionada!)) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Debes colocarlo pegado a un ${estadoJuego.anclaSeleccionada}')));
                      return;
                    }
                    if (!estadoJuego.tablero.esColocacionValida(x, y, estadoJuego.numeroAColocar!)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jugada inválida: Rompe las reglas.')));
                      return;
                    }
                    context.read<JuegoBloc>().add(ColocarJugada(x, y, estadoJuego.numeroAColocar!));
                  } else if (casilla.esInicial || !casilla.estaVacia) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Casilla no disponible.')));
                  }
                } else {
                  if (casilla.esInicial) {
                    final box = celdaContext.findRenderObject() as RenderBox;
                    final centroGlobal = box.localToGlobal(box.size.center(Offset.zero));
                    mostrarSelectorAbanico(context, x, y, state, centroGlobal);
                  }
                }
              },
              child: AnimatedBuilder(
                animation: animController,
                builder: (context, child) {
                  Color colorBorde = Colors.black26;
                  double anchoBorde = 1.0;
                  List<BoxShadow> sombras = [];

                  if (mostrarBrilloInicial) {
                    colorBorde = Colors.yellowAccent;
                    anchoBorde = 3.0;
                    sombras = [BoxShadow(color: Colors.yellowAccent.withOpacity(0.8), blurRadius: 10, spreadRadius: 2)];
                  } else if (esSugerencia) {
                    colorBorde = Color.lerp(Colors.greenAccent, Colors.green[900], animController.value)!;
                    anchoBorde = 3.0;
                    sombras = [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.8 * animController.value),
                        blurRadius: 15 * animController.value,
                        spreadRadius: 3 * animController.value,
                      )
                    ];
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: _obtenerColorZona(state.tablero.capa.obtenerZonaEn(casilla.coordenada).id), 
                      border: Border.all(color: colorBorde, width: anchoBorde),
                      boxShadow: sombras,
                    ),
                    child: Center(
                      child: casilla.valor != null
                          ? Text(
                              casilla.valor.toString(),
                              style: TextStyle(
                                fontSize: 24, 
                                fontWeight: FontWeight.bold,
                                color: casilla.esInicial ? Colors.black87 : Colors.blue[900],
                              ),
                            )
                          : null,
                    ),
                  );
                }
              ),
            );
          }
        );
      },
    );
  }
}