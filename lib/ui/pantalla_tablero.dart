import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_bloc.dart';
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
                            
                            // 1. Detectamos si seguimos en la fase de elegir números
                            bool esFaseInicial = state is JuegoEsperandoIniciales;
                            // 2. Evaluamos si esta casilla específica debe brillar
                            bool mostrarBrillo = casilla.esInicial && esFaseInicial;

                            return GestureDetector(
                              onTap: () {
                                if (casilla.esInicial) {
                                  // Calculamos el centro exacto de la casilla en coordenadas de pantalla
                                  final box = celdaContext.findRenderObject() as RenderBox;
                                  final centroGlobal = box.localToGlobal(box.size.center(Offset.zero));
                                  
                                  mostrarSelectorAbanico(context, x, y, state, centroGlobal);
                                }
                              },
                              
                              // AQUÍ INICIA EL CAMBIO: Reemplazamos Container por AnimatedContainer
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  color: _obtenerColorZona(state.tablero.capa.obtenerZonaEn(casilla.coordenada).id), 

                                  // Borde dinámico: grueso y brillante si está activo, delgado si no
                                  border: Border.all(
                                    color: mostrarBrillo ? Colors.yellowAccent : Colors.black26, 
                                    width: mostrarBrillo ? 3.0 : 1.0
                                  ),
                                  
                                  // Sombra resplandeciente
                                  boxShadow: mostrarBrillo ? [
                                    BoxShadow(
                                      color: Colors.yellowAccent.withOpacity(0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ] : [],
                                ),
                                
                                // Eliminamos el Stack y la estrellita, dejando solo el Center con el número
                                child: Center(
                                  child: casilla.valor != null
                                      ? Text(
                                          casilla.valor.toString(),
                                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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