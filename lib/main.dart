import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/tablero.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/casilla.dart';

void main() {
  // Inicializamos la lógica base antes de arrancar la app
  CapaZonas nivel1 = CapaZonas();
  Tablero tableroInicial = Tablero(nivel1);

  runApp(MiJuegoApp(tablero: tableroInicial));
}

class MiJuegoApp extends StatelessWidget {
  final Tablero tablero;

  const MiJuegoApp({super.key, required this.tablero});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jueguito 7x7',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: BlocProvider(
        create: (context) => JuegoBloc(tablero),
        child: const PantallaTablero(),
      ),
    );
  }
}

class PantallaTablero extends StatelessWidget {
  const PantallaTablero({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración Inicial')),
      body: Center(
        child: BlocBuilder<JuegoBloc, JuegoState>(
          builder: (context, state) {
            
            // Evaluamos si el juego ya está activo (se pusieron los 6 números)
            bool estaListoParaIniciar = state is JuegoActivo;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mensaje de estado superior
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    estaListoParaIniciar
                        ? '¡Tablero Desbloqueado! Presiona Iniciar.'
                        : 'Inserta los números (1-6). Llevas: ${(state as JuegoEsperandoIniciales).numerosColocados}/6',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                
                // Tablero 7x7
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

                        return GestureDetector(
                          onTap: () {
                            // Ya no lo limitamos, permitimos editar aunque el botón esté en verde
                            if (casilla.esInicial) {
                              _mostrarSelectorNumero(context, x, y, state);
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
                      },
                    ),
                  ),
                ),
                
                // Botón de Iniciar en la parte inferior
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

  // Método actualizado que recibe el state para buscar si el número ya existe
  void _mostrarSelectorNumero(BuildContext context, int x, int y, JuegoState state) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Elige un número'),
          content: Wrap(
            spacing: 10,
            children: List.generate(6, (index) {
              int numero = index + 1;
              return ElevatedButton(
                onPressed: () {
                  // 1. Revisamos si el número ya existe en el tablero
                  Casilla? existente = state.tablero.buscarCasillaInicialConValor(numero);
                  
                  // Cerramos la ventana de selección
                  Navigator.of(dialogContext).pop(); 

                  if (existente != null && (existente.coordenada.x != x || existente.coordenada.y != y)) {
                    // 2. Si existe en otro lado, mostramos la alerta de confirmación
                    _mostrarConfirmacionReemplazo(
                      context, existente.coordenada.x, existente.coordenada.y, x, y, numero
                    );
                  } else {
                    // 3. Si no existe, lo insertamos normal
                    context.read<JuegoBloc>().add(InsertarValorInicial(x, y, numero));
                  }
                },
                child: Text(numero.toString()),
              );
            }),
          ),
        );
      },
    );
  }

  // Método para confirmar si se quiere mover el número
  void _mostrarConfirmacionReemplazo(BuildContext context, int xOrigen, int yOrigen, int xDestino, int yDestino, int numero) {
    showDialog(
      context: context,
      builder: (BuildContext confirmContext) {
        return AlertDialog(
          title: const Text('Número ya utilizado'),
          content: Text('El número $numero ya está en otra casilla. ¿Deseas moverlo a esta nueva posición?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(confirmContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Enviamos el evento para moverlo
                context.read<JuegoBloc>().add(
                  MoverValorInicial(xOrigen, yOrigen, xDestino, yDestino, numero)
                );
                Navigator.of(confirmContext).pop();
              },
              child: const Text('Sí, mover'),
            ),
          ],
        );
      }
    );
  }
}