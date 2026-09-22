import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/tablero.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_state.dart';
// import 'package:jueguito/juego_event.dart'; 

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
      appBar: AppBar(title: const Text('Tablero')),
      body: Center(
        // BLOC BUILDER: Reacciona a los cambios de estado (bloqueado vs activo)
        child: BlocBuilder<JuegoBloc, JuegoState>(
          builder: (context, state) {
            if (state is JuegoEsperandoIniciales) {
              return Text(
                'Faltan números iniciales. Llevas: ${state.numerosColocados} / 6',
                style: const TextStyle(fontSize: 20),
              );
            }
            
            if (state is JuegoActivo) {
              return const Text(
                '¡Tablero Desbloqueado! Listo para jugar.',
                style: TextStyle(fontSize: 20, color: Colors.green),
              );
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}