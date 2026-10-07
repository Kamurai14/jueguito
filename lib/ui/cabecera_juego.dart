import 'package:flutter/material.dart';
import 'package:jueguito/juego_state.dart';

class CabeceraJuego extends StatelessWidget {
  final JuegoState state;
  const CabeceraJuego({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    String textoCabecera = '';

    // Validamos el tipo de estado de forma segura antes de asignar el texto
    if (state is JuegoEnProgreso) {
      textoCabecera = 'Partida en curso';
    } else if (state is JuegoActivo) {
      textoCabecera = '¡Tablero Desbloqueado! Presiona Iniciar.';
    } else if (state is JuegoEsperandoIniciales) {
      // Hacemos el casteo explícito aquí
      final estadoInicial = state as JuegoEsperandoIniciales;
      textoCabecera = 'Inserta los números (1-6). Llevas: ${estadoInicial.numerosColocados}/6';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(textoCabecera, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          
          if (state is JuegoEnProgreso)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[900], 
                borderRadius: BorderRadius.circular(20)
              ),
              child: Text(
                // Aquí el casteo es seguro porque está dentro del if(state is JuegoEnProgreso)
                'Puntos: ${(state as JuegoEnProgreso).puntuacion}', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
              ),
            ),
        ],
      ),
    );
  }
}