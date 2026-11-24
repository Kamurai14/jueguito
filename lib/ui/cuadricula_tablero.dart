import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/casilla.dart';
import 'package:jueguito/ui/dialogo_selector.dart';
import 'package:jueguito/ui/tema_juego.dart';

class CuadriculaTablero extends StatelessWidget {
  final JuegoState state;
  final AnimationController animController;

  const CuadriculaTablero({
    super.key,
    required this.state,
    required this.animController,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
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

            if (state is JuegoEnProgreso) {
              final estadoJuego = state as JuegoEnProgreso;

              if (estadoJuego.anclaSeleccionada != null &&
                  !casilla.esInicial &&
                  casilla.estaVacia) {
                bool esAdyacente = estadoJuego.tablero.esAdyacenteAValor(
                  x,
                  y,
                  estadoJuego.anclaSeleccionada!,
                );
                bool esValida = estadoJuego.tablero.esColocacionValida(
                  x,
                  y,
                  estadoJuego.numeroAColocar!,
                );
                esSugerencia = esAdyacente && esValida;
              }
            }

            return GestureDetector(
              key: Key('casilla_${x}_$y'),
              onTap: () {
                if (state is JuegoEnProgreso) {
                  final estadoJuego = state as JuegoEnProgreso;

                  if (!casilla.esInicial && casilla.estaVacia) {
                    if (estadoJuego.anclaSeleccionada == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecciona un ancla primero.')),
                      );
                      return;
                    }
                    if (!estadoJuego.tablero.esAdyacenteAValor(
                      x,
                      y,
                      estadoJuego.anclaSeleccionada!,
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Debes colocarlo pegado a un ${estadoJuego.anclaSeleccionada}',
                          ),
                        ),
                      );
                      return;
                    }
                    if (!estadoJuego.tablero.esColocacionValida(
                      x,
                      y,
                      estadoJuego.numeroAColocar!,
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Jugada inválida: Rompe las reglas.'),
                        ),
                      );
                      return;
                    }
                    context
                        .read<JuegoBloc>()
                        .add(ColocarJugada(x, y, estadoJuego.numeroAColocar!));
                  } else if (casilla.esInicial || !casilla.estaVacia) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Casilla no disponible.')),
                    );
                  }
                } else {
                  if (casilla.esInicial) {
                    final box = celdaContext.findRenderObject() as RenderBox;
                    final centroGlobal =
                        box.localToGlobal(box.size.center(Offset.zero));
                    mostrarSelectorAbanico(context, x, y, state, centroGlobal);
                  }
                }
              },
              child: AnimatedBuilder(
                animation: animController,
                builder: (context, child) {
                  Color colorBorde = Colors.black.withValues(alpha: 0.25);
                  double anchoBorde = 1.2;
                  List<BoxShadow> sombras = [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ];

                  if (mostrarBrilloInicial) {
                    colorBorde = Colors.white;
                    anchoBorde = 2.6;
                    sombras = [
                      BoxShadow(
                        color: Colors.amberAccent.withValues(alpha: 0.85),
                        blurRadius: 10,
                        spreadRadius: 1.5,
                      ),
                    ];
                  } else if (esSugerencia) {
                    // Alto contraste: borde blanco + resplandor cian/negro visible en cualquier color
                    colorBorde = Colors.white;
                    anchoBorde = 2.5 + (1.0 * animController.value);
                    sombras = [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.65),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.cyanAccent
                            .withValues(alpha: 0.45 + (0.45 * animController.value)),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ];
                  }

                  int vecesReclamada = 0;
                  String idZonaCasilla = state.tablero.obtenerIdZonaDeCasilla(x, y);

                  if (state is JuegoEnProgreso) {
                    vecesReclamada =
                        (state as JuegoEnProgreso).estadoZonasGlobal[idZonaCasilla] ?? 0;
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: TemaJuego.obtenerColorZona(idZonaCasilla, vecesReclamada),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorBorde, width: anchoBorde),
                      boxShadow: sombras,
                    ),
                    child: Center(
                      child: casilla.valor != null
                          ? Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: casilla.esInicial
                                  ? BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.16),
                                      shape: BoxShape.circle,
                                    )
                                  : null,
                              child: Text(
                                casilla.valor.toString(),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: casilla.esInicial
                                      ? (vecesReclamada >= 2
                                          ? Colors.black45
                                          : Colors.black87)
                                      : (vecesReclamada >= 2
                                          ? Colors.indigo[900]!.withValues(alpha: 0.5)
                                          : Colors.indigo[900]),
                                ),
                              ),
                            )
                          : esSugerencia
                              ? Transform.scale(
                                  scale: 0.85 + (0.25 * animController.value),
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.black87,
                                        width: 2.2,
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}