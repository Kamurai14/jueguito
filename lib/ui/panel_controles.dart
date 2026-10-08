import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_event.dart';
import 'package:jueguito/juego_state.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

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
                  key: const ValueKey('dado1'),
                  valor: estadoJuego.dado1,
                  esAncla: estadoJuego.anclaSeleccionada == estadoJuego.dado1,
                  idTirada: estadoJuego.idTirada,
                  onTap: () => context.read<JuegoBloc>().add(SeleccionarAncla(estadoJuego.dado1, estadoJuego.dado2)),
                ),
                const SizedBox(width: 20),
                _DadoBoton(
                  key: const ValueKey('dado2'),
                  valor: estadoJuego.dado2,
                  esAncla: estadoJuego.anclaSeleccionada == estadoJuego.dado2,
                  idTirada: estadoJuego.idTirada,
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

// Convertimos el botón en un StatefulWidget para manejar su propia animación
class _DadoBoton extends StatefulWidget {
  final int valor;
  final bool esAncla;
  final int idTirada;
  final VoidCallback onTap;

  const _DadoBoton({super.key, required this.valor, required this.esAncla, required this.idTirada, required this.onTap});

  @override
  State<_DadoBoton> createState() => _DadoBotonState();
}

class _DadoBotonState extends State<_DadoBoton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // La animación durará medio segundo
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animController.forward();
    _reproducirSonido();
  }

  // Este método mágico de Flutter detecta cuando el BLoC nos manda nuevos números
  @override
  void didUpdateWidget(covariant _DadoBoton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Si el valor del dado es diferente al que teníamos, significa que "tiramos" los dados
    if (oldWidget.idTirada != widget.idTirada) {
      _animController.forward(from: 0.0);
      _reproducirSonido();
    }
  }

  void _reproducirSonido() async {
    try {
      // AudioPlayers asume automáticamente que estás dentro de la carpeta "assets/"
      await _audioPlayer.play(AssetSource('sonidos/dados.mp3'));
    } catch (e) {
      debugPrint("Aún no has agregado el archivo de audio.");
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          // Hacemos que el dado dé dos vueltas completas (2 * pi * 2)
          double angulo = _animController.value * 2 * pi * 2;
          
          return Transform(
            alignment: Alignment.center,
            // rotateZ lo hace girar, rotateX le da el efecto de "voltereta" 3D
            transform: Matrix4.identity()..rotateZ(angulo)..rotateX(angulo / 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: widget.esAncla ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: widget.esAncla ? Colors.blue[900]! : Colors.black45, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))]
              ),
              child: Center(
                child: Text(
                  // Un toque genial: Mientras se anima (rueda), ocultamos el número y ponemos un "?"
                  _animController.isAnimating ? '?' : widget.valor.toString(), 
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    color: widget.esAncla ? Colors.white : Colors.black87
                  )
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}