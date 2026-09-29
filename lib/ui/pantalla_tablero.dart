import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/casilla.dart';
import 'package:jueguito/ui/dialogo_selector.dart';

class PantallaTablero extends StatelessWidget {
  const PantallaTablero({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración Inicial')),
      body: Center(
        child: BlocBuilder<JuegoBloc, JuegoState>(
          builder: (context, state) {
            bool estaListoParaIniciar = state is JuegoActivo;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    estaListoParaIniciar
                        ? '¡Tablero Desbloqueado! Presiona Iniciar.'
                        : 'Inserta los números (1-6). Llevas: ${(state as JuegoEsperandoIniciales).numerosColocados}/6',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

                        // Agregamos un Builder para poder leer la posición en pantalla
                        return Builder(
                          builder: (celdaContext) {
                            return GestureDetector(
                              onTap: () {
                                if (casilla.esInicial) {
                                  // Calculamos el centro exacto de la casilla en coordenadas de pantalla
                                  final box = celdaContext.findRenderObject() as RenderBox;
                                  final centroGlobal = box.localToGlobal(box.size.center(Offset.zero));
                                  
                                  mostrarSelectorAbanico(context, x, y, state, centroGlobal);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300], 
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Stack(
                                  children: [
                                    if (casilla.valor != null)
                                      Center(
                                        child: Text(
                                          casilla.valor.toString(),
                                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    if (casilla.esInicial)
                                      const Positioned(
                                        bottom: 2,
                                        right: 2,
                                        child: Icon(Icons.star, size: 16, color: Colors.amber),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }
                        );
                      },
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: estaListoParaIniciar ? Colors.green : Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    onPressed: estaListoParaIniciar 
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('¡Comienza la partida!')),
                          );
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
              ],
            );
          },
        ),
      ),
    );
  }
}