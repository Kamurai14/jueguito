import 'package:flutter/material.dart';
import 'package:jueguito/juego_state.dart';

class CabeceraJuego extends StatelessWidget {
  final JuegoState state;
  const CabeceraJuego({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    String textoCabecera = '';
    Color colorTexto = Colors.white;

    if (state is JuegoEnProgreso) {
      textoCabecera = 'Partida en curso';
    } else if (state is JuegoActivo) {
      textoCabecera = '¡Tablero Desbloqueado! Presiona Iniciar.';
    } else if (state is JuegoEsperandoIniciales) {
      final estadoInicial = state as JuegoEsperandoIniciales;
      
      // Si hay una alerta, la mostramos en rojo aquí arriba
      if (estadoInicial.mensajeAlerta != null) {
        textoCabecera = estadoInicial.mensajeAlerta!;
        colorTexto = Colors.redAccent;
      } else {
        textoCabecera = 'Inserta los números (1-6). Llevas: ${estadoInicial.numerosColocados}/6';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( // Envolvemos en Expanded por si el texto es muy largo
            child: Text(textoCabecera,
              key: const Key('texto_cabecera_estado'), 
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: colorTexto
              )
            ),
          ),
          
          if (state is JuegoEnProgreso)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.blue[900], 
                borderRadius: BorderRadius.circular(20)
              ),
              child: Text(
                'Puntos: ${(state as JuegoEnProgreso).puntuacion}', 
                key: const Key('texto_puntuacion'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
              ),
            ),
        ],
      ),
    );
  }
}