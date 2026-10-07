import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/casilla.dart';
import 'package:jueguito/ui/dialogo_selector.dart';

class PantallaTablero extends StatefulWidget {
  const PantallaTablero({super.key});

  @override
  State<PantallaTablero> createState() => _PantallaTableroState();
}

class _PantallaTableroState extends State<PantallaTablero> with SingleTickerProviderStateMixin {
  
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      appBar: AppBar(title: const Text('Juego 7x7')),
      body: Center(
        child: BlocConsumer<JuegoBloc, JuegoState>(
          listener: (context, state) {
            if (state is JuegoEnProgreso && state.mensajeAlerta != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.mensajeAlerta!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.amber[800],
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                )
              );
            }
          },
          builder: (context, state) {
            
            bool estaListoParaIniciar = state is JuegoActivo;

            String textoCabecera;
            if (state is JuegoEnProgreso) {
              textoCabecera = 'Partida en curso';
            } else if (estaListoParaIniciar) {
              textoCabecera = '¡Tablero Desbloqueado! Presiona Iniciar.';
            } else {
              textoCabecera = 'Inserta los números (1-6). Llevas: ${(state as JuegoEsperandoIniciales).numerosColocados}/6';
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(textoCabecera, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (state is JuegoEnProgreso)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.blue[900], borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            'Puntos: ${state.puntuacion}', 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                        ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1, 
                    child: GridView.builder(
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

                            if (state is JuegoEnProgreso) {
                              if (state.anclaSeleccionada != null && !casilla.esInicial && casilla.estaVacia) {
                                bool esAdyacente = state.tablero.esAdyacenteAValor(x, y, state.anclaSeleccionada!);
                                bool esValida = state.tablero.esColocacionValida(x, y, state.numeroAColocar!);
                                esSugerencia = esAdyacente && esValida;
                              }
                            }

                            return GestureDetector(
                              onTap: () {
                                if (state is JuegoEnProgreso) {
                                  if (!casilla.esInicial && casilla.estaVacia) {
                                    
                                    if (state.anclaSeleccionada == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un ancla primero.')));
                                      return;
                                    }
                                    
                                    if (!state.tablero.esAdyacenteAValor(x, y, state.anclaSeleccionada!)) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Debes colocarlo pegado a un ${state.anclaSeleccionada}')));
                                      return;
                                    }

                                    if (!state.tablero.esColocacionValida(x, y, state.numeroAColocar!)) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jugada inválida: Rompe las reglas.')));
                                      return;
                                    }

                                    context.read<JuegoBloc>().add(ColocarJugada(x, y, state.numeroAColocar!));
                                    
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
                                animation: _animController,
                                builder: (context, child) {
                                  
                                  Color colorBorde = Colors.black26;
                                  double anchoBorde = 1.0;
                                  List<BoxShadow> sombras = [];

                                  if (mostrarBrilloInicial) {
                                    colorBorde = Colors.yellowAccent;
                                    anchoBorde = 3.0;
                                    sombras = [BoxShadow(color: Colors.yellowAccent.withOpacity(0.8), blurRadius: 10, spreadRadius: 2)];
                                  } else if (esSugerencia) {
                                    colorBorde = Color.lerp(Colors.greenAccent, Colors.green[900], _animController.value)!;
                                    anchoBorde = 3.0;
                                    sombras = [
                                      BoxShadow(
                                        color: Colors.greenAccent.withOpacity(0.8 * _animController.value),
                                        blurRadius: 15 * _animController.value,
                                        spreadRadius: 3 * _animController.value,
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
                    ),
                  ),
                ),
                
                if (state is JuegoEnProgreso)
                  Container(
                    height: 120, 
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Selecciona el Ancla:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _DadoBoton(
                              valor: state.dado1,
                              esAncla: state.anclaSeleccionada == state.dado1,
                              onTap: () => context.read<JuegoBloc>().add(SeleccionarAncla(state.dado1, state.dado2)),
                            ),
                            const SizedBox(width: 20),
                            _DadoBoton(
                              valor: state.dado2,
                              esAncla: state.anclaSeleccionada == state.dado2,
                              onTap: () => context.read<JuegoBloc>().add(SeleccionarAncla(state.dado2, state.dado1)),
                            ),
                            const SizedBox(width: 30),
                            TextButton(
                              onPressed: () => context.read<JuegoBloc>().add(PasarTurno()),
                              child: const Text('Pasar Turno', style: TextStyle(color: Colors.red)),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Visibility(
                    visible: state is! JuegoEnProgreso,
                    maintainSize: true, 
                    maintainAnimation: true,
                    maintainState: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: estaListoParaIniciar ? Colors.green : Colors.grey,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        onPressed: estaListoParaIniciar ? () => context.read<JuegoBloc>().add(ComenzarPartida()) : null,
                        child: Text(
                          'INICIAR',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: estaListoParaIniciar ? Colors.white : Colors.black38,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DadoBoton extends StatelessWidget {
  final int valor;
  final bool esAncla;
  final VoidCallback onTap;

  const _DadoBoton({required this.valor, required this.esAncla, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: esAncla ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: esAncla ? Colors.blue[900]! : Colors.black45, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))]
        ),
        child: Center(
          child: Text(
            valor.toString(), 
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: esAncla ? Colors.white : Colors.black87
            )
          ),
        ),
      ),
    );
  }
}