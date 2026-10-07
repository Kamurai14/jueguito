import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/juego_state.dart';

class PanelControles extends StatelessWidget {
  final JuegoState state;
  const PanelControles({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is JuegoEnProgreso) {
      // Casteo local para acceder a dado1, dado2 y anclaSeleccionada sin errores
      final estadoJuego = state as JuegoEnProgreso;

      return Container(
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
                  valor: estadoJuego.dado1,
                  esAncla: estadoJuego.anclaSeleccionada == estadoJuego.dado1,
                  onTap: () => context.read<JuegoBloc>().add(SeleccionarAncla(estadoJuego.dado1, estadoJuego.dado2)),
                ),
                const SizedBox(width: 20),
                _DadoBoton(
                  valor: estadoJuego.dado2,
                  esAncla: estadoJuego.anclaSeleccionada == estadoJuego.dado2,
                  onTap: () => context.read<JuegoBloc>().add(SeleccionarAncla(estadoJuego.dado2, estadoJuego.dado1)),
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
      );
    } else {
      bool estaListoParaIniciar = state is JuegoActivo;
      return Visibility(
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
      );
    }
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