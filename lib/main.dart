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
      // AQUÍ ESTÁ EL BLOC PROVIDER ENVOLVIENDO LA PANTALLA PRINCIPAL
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
                            if (casilla.esInicial && state is JuegoEsperandoIniciales) {
                              _mostrarSelectorNumero(context, x, y);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300], // Pronto pondremos tus colores aquí
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
                
                // NUEVO: Botón de Iniciar en la parte inferior
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // Si está listo es verde, de lo contrario es gris
                      backgroundColor: estaListoParaIniciar ? Colors.green : Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    // Al asignarle 'null' al onPressed, Flutter desactiva el botón automáticamente
                    onPressed: estaListoParaIniciar 
                      ? () {
                          // Aquí irá la lógica de la siguiente pantalla o fase del juego
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

  void _mostrarSelectorNumero(BuildContext context, int x, int y) {
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
                  context.read<JuegoBloc>().add(InsertarValorInicial(x, y, numero));
                  Navigator.of(dialogContext).pop(); 
                },
                child: Text(numero.toString()),
              );
            }),
          ),
        );
      },
    );
  }
}

  // Ventana emergente para elegir un número del 1 al 6
  void _mostrarSelectorNumero(BuildContext context, int x, int y) {
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
                  // Enviamos el evento al BLoC
                  context.read<JuegoBloc>().add(InsertarValorInicial(x, y, numero));
                  Navigator.of(dialogContext).pop(); // Cerramos el diálogo
                },
                child: Text(numero.toString()),
              );
            }),
          ),
        );
      },
    );
  }