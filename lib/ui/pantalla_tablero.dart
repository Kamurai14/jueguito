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
import 'package:jueguito/ui/mini_tablero.dart';

class PantallaTablero extends StatefulWidget {
  const PantallaTablero({super.key});

  @override
  State<PantallaTablero> createState() => _PantallaTableroState();
}

class _PantallaTableroState extends State<PantallaTablero>
    with SingleTickerProviderStateMixin {
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        List<Widget> reglas = [];

        void agregar(String idZona, String simbolo, String desc) {
          int p1 = MotorReglas.obtenerPuntos(idZona, 1, mapaActual: mapa);
          int p2 = MotorReglas.obtenerPuntos(idZona, 2, mapaActual: mapa);
          int p3 = MotorReglas.obtenerPuntos(idZona, 3, mapaActual: mapa);

          if (p1 > 0) {
            Color color = TemaJuego.obtenerColorZona(idZona, 0);
            reglas.add(_buildReglaItem(simbolo, color, [p1, p2, p3], desc));
          }
        }

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
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'GUÍA DE PUNTUACIONES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
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

  Widget _buildReglaItem(
    String simbolo,
    Color colorBase,
    List<int> puntos,
    String desc,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: colorBase,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white54, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 3)),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            simbolo,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: (colorBase == Colors.white ||
                      colorBase == Colors.yellowAccent[400])
                  ? Colors.black87
                  : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: puntos
              .map(
                (p) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorBase.withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                      bottom: Radius.circular(4),
                    ),
                    border: Border.all(color: colorBase, width: 1.5),
                  ),
                  child: Text(
                    p.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  void _mostrarZoomTablero(
    BuildContext context,
    String nombreRival,
    List<dynamic> tableroRival,
    int puntosRival,
    CapaZonas capa,
  ) {
    final double anchoDisponible = MediaQuery.of(context).size.width * 0.75;
    final double tamanoCasilla = (anchoDisponible / 7).clamp(24.0, 42.0);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.blueGrey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white24, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombreRival,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$puntosRival pts',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MiniTablero(
                valores: tableroRival,
                capa: capa,
                tamanoCasilla: tamanoCasilla,
              ),
              const SizedBox(height: 12),
              const Text(
                'Toca afuera para cerrar',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // PANEL SUPERIOR: MAPAS DE LOS RIVALES
  // ==========================================
  Widget _buildPanelRivales(BuildContext context, JuegoEnProgreso estado) {
    if (estado.tablerosRivales.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 115,
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: estado.tablerosRivales.length,
        itemBuilder: (context, index) {
          String rival = estado.tablerosRivales.keys.elementAt(index);
          List<dynamic> tableroRival = estado.tablerosRivales[rival] ?? [];
          int puntosRival = estado.puntuacionesRivales[rival] ?? 0;

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _mostrarZoomTablero(
                  context,
                  rival,
                  tableroRival,
                  puntosRival,
                  estado.tablero.capa,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MiniTablero(
                      valores: tableroRival,
                      capa: estado.tablero.capa,
                      tamanoCasilla: 9.0,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rival,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$puntosRival pts',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
            content: const Text(
              'Si te sales ahora perderás la partida y se le dará la victoria a tus rivales.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sí, rendirme'),
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
            BlocBuilder<JuegoBloc, JuegoState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.help_outline),
                  tooltip: 'Ver reglas y puntos',
                  onPressed: () {
                    _mostrarMenuReglas(context, state.tablero.capa.tipoMapa);
                  },
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<JuegoBloc, JuegoState>(
            builder: (context, state) {
              if (state is JuegoTerminado) {
                return _buildPantallaResultados(context, state);
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CabeceraJuego(state: state),
                  if (state is JuegoEnProgreso) _buildPanelRivales(context, state),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CuadriculaTablero(
                          state: state,
                          animController: _animController,
                        ),
                      ),
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

  // ==========================================
  // PANTALLA FINAL (PODIO CON MINIMAPAS Y RANGOS)
  // ==========================================
  Widget _buildPantallaResultados(BuildContext context, JuegoTerminado estado) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            estado.esVictoria ? '¡VICTORIA!' : 'FIN DEL JUEGO',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: estado.esVictoria ? Colors.amber : Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            estado.mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 20),

          // PODIO MULTIJUGADOR
          if (estado.rankingFinal != null && estado.rankingFinal!.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: estado.rankingFinal!.length,
                itemBuilder: (context, index) {
                  final jugador = estado.rankingFinal![index];
                  bool esPrimero = index == 0;

                  return Card(
                    color: esPrimero
                        ? Colors.amber.withValues(alpha: 0.2)
                        : Colors.blueGrey[800],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: esPrimero ? Colors.amber : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: esPrimero ? Colors.amber : Colors.white54,
                            ),
                          ),
                          const SizedBox(width: 16),
                          MiniTablero(
                            valores: jugador['tablero'] ?? [],
                            capa: estado.tablero.capa,
                            tamanoCasilla: 9.0,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  jugador['usuario'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${jugador['puntuacion']} pts',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.amber,
                                  ),
                                ),
                                if (jugador['rango'] != null) ...[
                                  const SizedBox(height: 4),
                                  Builder(
                                    builder: (context) {
                                      final rango = jugador['rango'] as Map;
                                      final int cambio = rango['cambioPuntos'] ?? 0;
                                      final String textoCambio =
                                          cambio >= 0 ? '+$cambio pts' : '$cambio pts';
                                      final bool subio = rango['subioDeNivel'] == true;

                                      return Wrap(
                                        spacing: 6,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            '${rango['nombreNivel']} (${rango['puntos']} pts)',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          Text(
                                            textoCambio,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: cambio >= 0
                                                  ? Colors.greenAccent
                                                  : Colors.redAccent,
                                            ),
                                          ),
                                          if (subio)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                '¡ASCENSO!',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (esPrimero)
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 40,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else ...[
            // MODO UN JUGADOR (OFFLINE) O VICTORIA POR ABANDONO
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    estado.esVictoria
                        ? Icons.emoji_events
                        : Icons.sentiment_dissatisfied,
                    size: 100,
                    color: estado.esVictoria ? Colors.amber : Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Puntuación Final: ${estado.puntuacionFinal}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (estado.cambioRangoPropio != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[800],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.amber, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${estado.cambioRangoPropio!['nombreNivel']} (${estado.cambioRangoPropio!['puntos']} pts)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '+${estado.cambioRangoPropio!['cambioPuntos']} pts competitivos',
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (estado.cambioRangoPropio!['subioDeNivel'] == true)
                            const Padding(
                              padding: EdgeInsets.only(top: 6.0),
                              child: Text(
                                '¡SUBISTE DE RANGO!',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.home),
            label: const Text(
              'Volver al Menú',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}