import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/juego_state.dart';
import 'package:jueguito/casilla.dart';

void mostrarSelectorNumero(BuildContext context, int x, int y, JuegoState state) {
  Casilla casillaActual = state.tablero.obtenerCasilla(x, y);
  bool tieneNumero = casillaActual.valor != null;

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Elige un número'),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(6, (index) {
            int numero = index + 1;
            bool esElMismo = numero == casillaActual.valor;

            return ElevatedButton(
              onPressed: esElMismo ? null : () {
                Casilla? existente = state.tablero.buscarCasillaInicialConValor(numero);
                Navigator.of(dialogContext).pop(); 

                if (existente != null && (existente.coordenada.x != x || existente.coordenada.y != y)) {
                  _mostrarConfirmacionReemplazo(
                    context, existente.coordenada.x, existente.coordenada.y, x, y, numero, casillaActual.valor
                  );
                } else {
                  context.read<JuegoBloc>().add(InsertarValorInicial(x, y, numero));
                }
              },
              child: Text(numero.toString()),
            );
          }),
        ),
        actions: [
          if (tieneNumero)
            TextButton(
              onPressed: () {
                context.read<JuegoBloc>().add(QuitarValorInicial(x, y));
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Borrar número'),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      );
    },
  );
}

void _mostrarConfirmacionReemplazo(BuildContext context, int xOrigen, int yOrigen, int xDestino, int yDestino, int numero, int? valorDestino) {
  String mensaje = valorDestino != null 
      ? 'El número $numero ya está en otra casilla. ¿Deseas intercambiarlo por el $valorDestino?'
      : 'El número $numero ya está en otra casilla. ¿Deseas moverlo a esta nueva posición?';

  showDialog(
    context: context,
    builder: (BuildContext confirmContext) {
      return AlertDialog(
        title: Text(valorDestino != null ? 'Intercambiar números' : 'Número ya utilizado'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(confirmContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<JuegoBloc>().add(
                MoverValorInicial(xOrigen, yOrigen, xDestino, yDestino, numero)
              );
              Navigator.of(confirmContext).pop();
            },
            child: Text(valorDestino != null ? 'Sí, intercambiar' : 'Sí, mover'),
          ),
        ],
      );
    }
  );
}