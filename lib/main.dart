import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/tablero.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/ui/pantalla_tablero.dart';

void main() {
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