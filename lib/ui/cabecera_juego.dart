import 'package:flutter/material.dart';
import 'package:jueguito/juego_state.dart';

class CabeceraJuego extends StatelessWidget {
  final JuegoState state;
  const CabeceraJuego({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    String textoCabecera = '';
    Color colorTexto = Colors.white;
    Color colorAcento = const Color(0xFF00A8E8);
    IconData icono = Icons.sports_esports_rounded;

    if (state is JuegoEnProgreso) {
      textoCabecera = 'Partida en curso';
      colorAcento = const Color(0xFF4CAF50);
      icono = Icons.play_circle_fill_rounded;
    } else if (state is JuegoActivo) {
      textoCabecera = '¡Tablero listo! Presiona Iniciar.';
      colorAcento = Colors.amber;
      icono = Icons.check_circle_rounded;
    } else if (state is JuegoEsperandoIniciales) {
      final estadoInicial = state as JuegoEsperandoIniciales;

      if (estadoInicial.mensajeAlerta != null) {
        textoCabecera = estadoInicial.mensajeAlerta!;
        colorTexto = Colors.redAccent;
        colorAcento = Colors.redAccent;
        icono = Icons.warning_amber_rounded;
      } else {
        textoCabecera =
            'Coloca tus iniciales (1-6): ${estadoInicial.numerosColocados}/6';
        colorAcento = const Color(0xFFFFB703);
        icono = Icons.auto_awesome_rounded;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorAcento.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icono, color: colorAcento, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                textoCabecera,
                key: const Key('texto_cabecera_estado'),
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: colorTexto,
                ),
              ),
            ),
            if (state is JuegoEnProgreso)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB703), Color(0xFFE07A00)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB703).withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.black87, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'Puntos: ${(state as JuegoEnProgreso).puntuacion}',
                      key: const Key('texto_puntuacion'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}