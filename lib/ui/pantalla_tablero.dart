import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/casilla.dart';
import 'package:jueguito/ui/dialogo_selector.dart';

class PantallaTablero extends StatelessWidget {
  const PantallaTablero({super.key});

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
        child: BlocBuilder<JuegoBloc, JuegoState>(
          builder: (context, state) {
            
            // Banderas para saber en qué etapa del juego estamos
            bool estaListoParaIniciar = state is JuegoActivo;
            bool estaEnProgreso = state is JuegoEnProgreso;

            // Mensaje dinámico de la cabecera
            String textoCabecera;
            if (estaEnProgreso) {
              textoCabecera = '¡Partida en curso! Completa el mapa.';
            } else if (estaListoParaIniciar) {
              textoCabecera = '¡Tablero Desbloqueado! Presiona Iniciar.';
            } else {
              textoCabecera = 'Inserta los números (1-6). Llevas: ${(state as JuegoEsperandoIniciales).numerosColocados}/6';
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    textoCabecera,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
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
                            
                            // El brillo solo se muestra si son iniciales y la partida AÚN NO empieza
                            bool mostrarBrillo = casilla.esInicial && !estaEnProgreso;

                            return GestureDetector(
                              onTap: () {
                                if (estaEnProgreso) {
                                  // --- LÓGICA DURANTE LA PARTIDA ---
                                  if (!casilla.esInicial) {
                                    // Tocaste una casilla normal (vacía)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Próximamente: Selector para jugar')),
                                    );
                                  } else {
                                    // Intentas tocar una casilla bloqueada
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Las casillas iniciales están bloqueadas.')),
                                    );
                                  }
                                } else {
                                  // --- LÓGICA DE FASE DE CONFIGURACIÓN ---
                                  if (casilla.esInicial) {
                                    final box = celdaContext.findRenderObject() as RenderBox;
                                    final centroGlobal = box.localToGlobal(box.size.center(Offset.zero));
                                    mostrarSelectorAbanico(context, x, y, state, centroGlobal);
                                  }
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: _obtenerColorZona(state.tablero.capa.obtenerZonaEn(casilla.coordenada).id), 
                                  border: Border.all(
                                    color: mostrarBrillo ? Colors.yellowAccent : Colors.black26, 
                                    width: mostrarBrillo ? 3.0 : 1.0
                                  ),
                                  boxShadow: mostrarBrillo ? [
                                    BoxShadow(
                                      color: Colors.yellowAccent.withOpacity(0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ] : [],
                                ),
                                child: Center(
                                  child: casilla.valor != null
                                      ? Text(
                                          casilla.valor.toString(),
                                          style: TextStyle(
                                            fontSize: 24, 
                                            fontWeight: FontWeight.bold,
                                            // Oscurecemos ligeramente el texto de los números iniciales para diferenciarlos
                                            color: casilla.esInicial ? Colors.black87 : Colors.blue[900],
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }
                        );
                      },
                    ),
                  ),
                ),
                
                // Ocultamos el botón por completo si la partida ya está en progreso
                // Usamos Visibility para ocultar el botón pero conservar su espacio exacto
                Visibility(
                  visible: !estaEnProgreso,
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
                      onPressed: estaListoParaIniciar 
                        ? () {
                            context.read<JuegoBloc>().add(ComenzarPartida());
                          } 
                        : null,
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