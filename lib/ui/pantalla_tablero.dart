import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_state.dart';

// Importamos nuestros nuevos widgets modulares
import 'package:jueguito/ui/cabecera_juego.dart';
import 'package:jueguito/ui/cuadricula_tablero.dart';
import 'package:jueguito/ui/panel_controles.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900], // <-- 1. Fondo oscuro para el juego
      key: const Key('pantalla_tablero_scaffold'),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900], // <-- 2. AppBar oscuro
        foregroundColor: Colors.white, // <-- 3. Flecha de retroceso y título en blanco
        elevation: 0,
        title: const Text('Juego 7x7'),
      ),
      body: Center(
        child: BlocBuilder<JuegoBloc, JuegoState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CabeceraJuego(state: state),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1, 
                    child: CuadriculaTablero(state: state, animController: _animController),
                  ),
                ),
                PanelControles(state: state),
              ],
            );
          },
        ),
      ),
    );
  }
}