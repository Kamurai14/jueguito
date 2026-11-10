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
      backgroundColor: Colors.blueGrey[900], 
      key: const Key('pantalla_tablero_scaffold'),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900], 
        foregroundColor: Colors.white, 
        elevation: 0,
        title: const Text('Juego 7x7'),
      ),
      body: Center(
        child: BlocBuilder<JuegoBloc, JuegoState>(
          builder: (context, state) {
            
            // ==========================================
            // PANTALLA DE RESULTADOS (GAME OVER)
            // ==========================================
            if (state is JuegoTerminado) {
              return _buildPantallaResultados(context, state);
            }

            // ==========================================
            // TABLERO NORMAL DE JUEGO
            // ==========================================
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

  // Diseño de la pantalla final
  Widget _buildPantallaResultados(BuildContext context, JuegoTerminado estado) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            estado.esVictoria ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            size: 120,
            color: estado.esVictoria ? Colors.amber : Colors.grey,
          ),
          const SizedBox(height: 20),
          Text(
            estado.esVictoria ? '¡VICTORIA!' : 'FIN DEL JUEGO',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: estado.esVictoria ? Colors.amber : Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            estado.mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, color: Colors.white70),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))]
            ),
            child: Text(
              'Puntuación Final: ${estado.puntuacionFinal}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton.icon(
            icon: const Icon(Icons.home),
            label: const Text('Volver al Menú', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00), // Naranja Brilliant
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              // Navegamos hacia atrás hasta llegar a la primera pantalla (Menú Principal)
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
    );
  }
}