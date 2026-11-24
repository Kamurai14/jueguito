import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/juego_state.dart';
import 'dart:math';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class PanelControles extends StatelessWidget {
  final JuegoState state;
  const PanelControles({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is JuegoEnProgreso) {
      final estadoJuego = state as JuegoEnProgreso;

      String textoInstruccion;
      Color colorTexto;
      Color colorBordeGuia;

      if (estadoJuego.mensajeAlerta != null) {
        textoInstruccion = estadoJuego.mensajeAlerta!;
        colorTexto = Colors.amberAccent;
        colorBordeGuia = Colors.amberAccent;
      } else if (estadoJuego.turnoTerminado) {
        textoInstruccion = 'Jugada lista. Esperando a los demás...';
        colorTexto = Colors.white70;
        colorBordeGuia = Colors.white24;
      } else if (estadoJuego.anclaSeleccionada == null) {
        textoInstruccion = 'Paso 1: Toca un dado para elegirlo como tu ancla';
        colorTexto = Colors.white;
        colorBordeGuia = const Color(0xFF00A8E8);
      } else {
        final numeroAColocar = estadoJuego.anclaSeleccionada == estadoJuego.dado1
            ? estadoJuego.dado2
            : estadoJuego.dado1;
        textoInstruccion =
            'Paso 2: Coloca el $numeroAColocar junto a un ${estadoJuego.anclaSeleccionada}';
        colorTexto = Colors.cyanAccent;
        colorBordeGuia = Colors.cyanAccent;
      }

      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 4, 12, 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF141B24).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorBordeGuia.withValues(alpha: 0.35),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                textoInstruccion,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: colorTexto,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DadoBoton(
                    key: const ValueKey('dado1'),
                    valor: estadoJuego.dado1,
                    esAncla: estadoJuego.anclaSeleccionada == estadoJuego.dado1,
                    idTirada: estadoJuego.idTirada,
                    onTap: estadoJuego.turnoTerminado
                        ? () {}
                        : () => context.read<JuegoBloc>().add(
                              SeleccionarAncla(estadoJuego.dado1, estadoJuego.dado2),
                            ),
                  ),
                  const SizedBox(width: 18),
                  _DadoBoton(
                    key: const ValueKey('dado2'),
                    valor: estadoJuego.dado2,
                    esAncla: estadoJuego.anclaSeleccionada == estadoJuego.dado2,
                    idTirada: estadoJuego.idTirada,
                    onTap: estadoJuego.turnoTerminado
                        ? () {}
                        : () => context.read<JuegoBloc>().add(
                              SeleccionarAncla(estadoJuego.dado2, estadoJuego.dado1),
                            ),
                  ),
                  const SizedBox(width: 24),
                  TextButton.icon(
                    key: const Key('boton_pasar_turno'),
                    style: TextButton.styleFrom(
                      backgroundColor: estadoJuego.turnoTerminado
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.redAccent.withValues(alpha: 0.14),
                      foregroundColor: estadoJuego.turnoTerminado
                          ? Colors.white38
                          : Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: estadoJuego.turnoTerminado
                              ? Colors.white12
                              : Colors.redAccent.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                    onPressed: estadoJuego.turnoTerminado
                        ? null
                        : () => context.read<JuegoBloc>().add(PasarTurno()),
                    icon: const Icon(Icons.skip_next_rounded, size: 20),
                    label: const Text(
                      'Pasar Turno',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (state is JuegoActivo) {
      final estado = state as JuegoActivo;
      final bloc = context.read<JuegoBloc>();
      final esMultiplayer = bloc.servicioRed != null;
      final esAnfitrion = bloc.esAnfitrion;

      String textoBoton = 'INICIAR PARTIDA';
      bool habilitado = true;

      if (esMultiplayer) {
        if (esAnfitrion) {
          textoBoton = 'INICIAR PARTIDA (${estado.listos}/${estado.total})';
          habilitado = (estado.listos == estado.total && estado.total > 0);
        } else {
          textoBoton = 'ESPERANDO JUGADORES (${estado.listos}/${estado.total})...';
          habilitado = false;
        }
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        child: ElevatedButton.icon(
          key: const Key('boton_iniciar_partida'),
          icon: Icon(habilitado ? Icons.play_arrow_rounded : Icons.hourglass_top_rounded),
          style: ElevatedButton.styleFrom(
            backgroundColor: habilitado ? Colors.green[600] : Colors.white12,
            foregroundColor: habilitado ? Colors.white : Colors.white60,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: habilitado ? 8 : 0,
          ),
          onPressed: habilitado
              ? () => context.read<JuegoBloc>().add(ComenzarPartida())
              : null,
          label: Text(
            textoBoton,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    } else if (state is JuegoEsperandoIniciales) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        child: ElevatedButton.icon(
          key: const Key('boton_iniciales_aleatorios'),
          icon: const Icon(Icons.shuffle_rounded),
          label: const Text(
            'COLOCAR AL AZAR',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B2CBF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.purpleAccent.withValues(alpha: 0.5)),
            ),
            elevation: 8,
          ),
          onPressed: () {
            context.read<JuegoBloc>().add(ColocarInicialesAleatorios());
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _DadoBoton extends StatefulWidget {
  final int valor;
  final bool esAncla;
  final int idTirada;
  final VoidCallback onTap;

  const _DadoBoton({
    super.key,
    required this.valor,
    required this.esAncla,
    required this.idTirada,
    required this.onTap,
  });

  @override
  State<_DadoBoton> createState() => _DadoBotonState();
}

class _DadoBotonState extends State<_DadoBoton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  AudioPlayer? _audioPlayer;

  bool esTest = false;

  @override
  void initState() {
    super.initState();

    try {
      esTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    } catch (e) {
      esTest = false;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    if (!esTest) {
      _audioPlayer = AudioPlayer();
    }

    _animController.forward();
    _reproducirSonido();
  }

  @override
  void didUpdateWidget(covariant _DadoBoton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.idTirada != widget.idTirada) {
      _animController.forward(from: 0.0);
      _reproducirSonido();
    }
  }

  void _reproducirSonido() async {
    if (esTest || _audioPlayer == null) return;

    try {
      await _audioPlayer!.play(AssetSource('sonidos/dados.mp3'));
    } catch (e) {
      debugPrint("Aún no has agregado el archivo de audio.");
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              double angulo = _animController.value * 2 * pi * 2;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(angulo)
                  ..rotateX(angulo / 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: widget.esAncla
                        ? const LinearGradient(
                            colors: [Color(0xFF00D2FF), Color(0xFF0066CC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Colors.white, Color(0xFFE2E8F0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: widget.esAncla ? Colors.white : Colors.black26,
                      width: widget.esAncla ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.esAncla
                            ? Colors.cyanAccent.withValues(alpha: 0.65)
                            : Colors.black.withValues(alpha: 0.4),
                        blurRadius: widget.esAncla ? 14 : 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _animController.isAnimating ? '?' : widget.valor.toString(),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: widget.esAncla ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: widget.esAncla ? 1.0 : 0.0,
            child: const Text(
              'ANCLA',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}