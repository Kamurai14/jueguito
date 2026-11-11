// lib/ui/pantalla_tablero.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/juego_state.dart';

// Imports de la estructura del tablero
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/motor_reglas.dart';
import 'package:jueguito/ui/tema_juego.dart';

// Imports de nuestros widgets modulares
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

  // ==========================================
  // MENÚ OCULTO: REGLAS Y PUNTUACIONES DINÁMICAS
  // ==========================================
  void _mostrarMenuReglas(BuildContext context, TipoMapa mapa) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.blueGrey[900],
      isScrollControlled: true, // Para que se adapte si hay muchas reglas
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        List<Widget> reglas = [];

        // Función ayudante que consulta tu MotorReglas en vivo
        void agregar(String idZona, String simbolo, String desc) {
          int p1 = MotorReglas.obtenerPuntos(idZona, 1, mapaActual: mapa);
          int p2 = MotorReglas.obtenerPuntos(idZona, 2, mapaActual: mapa);
          int p3 = MotorReglas.obtenerPuntos(idZona, 3, mapaActual: mapa);
          
          if (p1 > 0) { // Solo dibujamos la regla si la zona da puntos en este mapa
            Color color = TemaJuego.obtenerColorZona(idZona, 0); // Color vivo (sin atenuar)
            reglas.add(_buildReglaItem(simbolo, color, [p1, p2, p3], desc));
          }
        }

        // Mapeo automático basado en los 4 mapas disponibles
        if (mapa == TipoMapa.mapa1) {
          agregar('AZ1', '=', 'Iguales');
          agregar('MO1', 'XO', 'Máx 2');
          agregar('VE1', '?', 'Libre');
          agregar('AM', '≠', 'Diferentes');
          agregar('RO1', '≠', 'Diferentes');
        } else if (mapa == TipoMapa.mapa2) {
          agregar('AZ1', '=', 'Iguales');
          agregar('MO1', 'XO', 'Máx 2');
          agregar('VE1', '?', 'Libre');
          agregar('AM', '≠', 'Diferentes');
          agregar('RO1', '≠', 'Diferentes');
          agregar('BL', '=', 'Iguales');
        } else if (mapa == TipoMapa.mapa3) {
          agregar('AZ1', '=', 'Iguales');
          agregar('MO1', 'XO', 'Máx 2');
          agregar('VE1', '?', 'Libre');
          agregar('AM', '≠', 'Diferentes');
          agregar('RO1', '≠', 'Diferentes');
          agregar('BL', '=', 'Iguales');
        } else if (mapa == TipoMapa.mapa4) {
          agregar('AZ1', '=', 'Iguales');
          agregar('MO1', 'XO', 'Máx 2');
          agregar('VE1', '?', 'Libre');
          agregar('AM', '≠', 'Diferentes');
          agregar('RO1', '≠', 'Diferentes');
          agregar('NA1', '4-6', 'Solo 4,5,6');
          agregar('NA2', '1-3', 'Solo 1,2,3');
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Barrita gris superior clásica de los BottomSheet
                Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 20),
                const Text('GUÍA DE PUNTUACIONES', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 25),
                Wrap(
                  spacing: 25,
                  runSpacing: 25,
                  alignment: WrapAlignment.center,
                  children: reglas,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Diseño idéntico a las fotos que enviaste (Gema + 3 Fichas de puntos debajo)
  Widget _buildReglaItem(String simbolo, Color colorBase, List<int> puntos, String desc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. El icono principal (El Dado/Gema)
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: colorBase,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white54, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 3))]
          ),
          alignment: Alignment.center,
          child: Text(
            simbolo,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              // Si el fondo es muy claro (blanco o amarillo), oscurecemos el texto
              color: (colorBase == Colors.white || colorBase == Colors.yellowAccent[400]) ? Colors.black87 : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // 2. Los tres valores de puntuación anidados
        Row(
          mainAxisSize: MainAxisSize.min,
          children: puntos.map((p) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: colorBase.withValues(alpha: 0.3),
              // Forma ligeramente puntiaguda en la base, imitando la imagen
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(4)), 
              border: Border.all(color: colorBase, width: 1.5)
            ),
            child: Text(
              p.toString(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          )).toList(),
        ),
        const SizedBox(height: 6),
        // 3. Descripción corta
        Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final salir = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('¿Abandonar partida?'),
            content: const Text('Si te sales ahora perderás la partida y se le dará la victoria a tus rivales.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), 
                child: const Text('Cancelar')
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true), 
                child: const Text('Sí, rendirme')
              ),
            ],
          ),
        );

        if (salir == true && context.mounted) {
          context.read<JuegoBloc>().servicioRed?.rendirse();
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blueGrey[900], 
        key: const Key('pantalla_tablero_scaffold'),
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900], 
          foregroundColor: Colors.white, 
          elevation: 0,
          title: const Text('Juego 7x7'),
          actions: [
            // AQUÍ ESTÁ EL MENÚ OCULTO: 
            // Un sutil ícono de ayuda que despliega las puntuaciones
            BlocBuilder<JuegoBloc, JuegoState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.help_outline),
                  tooltip: 'Ver reglas y puntos',
                  onPressed: () {
                    // Extraemos el tipo de mapa actual y se lo pasamos al menú
                    _mostrarMenuReglas(context, state.tablero.capa.tipoMapa);
                  },
                );
              },
            ),
            const SizedBox(width: 8), // Margen derecho
          ],
        ),
        body: Center(
          child: BlocBuilder<JuegoBloc, JuegoState>(
            builder: (context, state) {
              
              if (state is JuegoTerminado) {
                return _buildPantallaResultados(context, state);
              }

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
      ),
    );
  }

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
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
    );
  }
}