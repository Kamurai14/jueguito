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
      backgroundColor: const Color(0xFF141B24),
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'GUÍA DE PUNTUACIONES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
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
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorBase,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white54, width: 2),
            boxShadow: [
              BoxShadow(
                color: colorBase.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            simbolo,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: (colorBase == Colors.white ||
                      colorBase == Colors.yellowAccent[400])
                  ? Colors.black87
                  : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: puntos
              .map(
                (p) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorBase.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colorBase, width: 1.3),
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
        Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
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
        backgroundColor: const Color(0xFF141B24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
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
                            fontWeight: FontWeight.w900,
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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MiniTablero(
                  valores: tableroRival,
                  capa: capa,
                  tamanoCasilla: tamanoCasilla,
                ),
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
      height: 124,
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
            padding: const EdgeInsets.only(right: 12.0),
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MiniTablero(
                        valores: tableroRival,
                        capa: estado.tablero.capa,
                        tamanoCasilla: 8.5,
                      ),
                      const SizedBox(height: 5),
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
            backgroundColor: const Color(0xFF141B24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.35)),
            ),
            title: const Text(
              '¿Abandonar partida?',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Si te sales ahora perderás la partida y se le dará la victoria a tus rivales.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
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
        extendBodyBehindAppBar: true,
        key: const Key('pantalla_tablero_scaffold'),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'BRILLIANT',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
              fontSize: 20,
            ),
          ),
          actions: [
            BlocBuilder<JuegoBloc, JuegoState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.help_outline_rounded),
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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.2),
              radius: 1.3,
              colors: [
                Color(0xFF1B2430),
                Color(0xFF10151C),
                Color(0xFF080B0F),
              ],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<JuegoBloc, JuegoState>(
              builder: (context, state) {
                if (state is JuegoTerminado) {
                  return _buildPantallaResultados(context, state);
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: CabeceraJuego(state: state),
                    ),
                    if (state is JuegoEnProgreso) _buildPanelRivales(context, state),
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0,
                            ),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CuadriculaTablero(
                              state: state,
                              animController: _animController,
                            ),
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
      ),
    );
  }

  // ==========================================
  // PANTALLA FINAL (PODIO CON MINIMAPAS Y RANGOS)
  // ==========================================
  Widget _buildPantallaResultados(BuildContext context, JuegoTerminado estado) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: estado.esVictoria
                      ? const [Color(0xFFFFD166), Color(0xFFFFB703), Color(0xFFFF6B00)]
                      : const [Colors.white, Colors.white70],
                ).createShader(bounds),
                child: Text(
                  estado.esVictoria ? '¡VICTORIA!' : 'FIN DEL JUEGO',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                estado.mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
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

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 7),
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: esPrimero
                              ? Colors.amber.withValues(alpha: 0.14)
                              : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: esPrimero
                                ? Colors.amber.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.1),
                            width: esPrimero ? 2 : 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '#${index + 1}',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: esPrimero ? Colors.amber : Colors.white54,
                              ),
                            ),
                            const SizedBox(width: 14),
                            MiniTablero(
                              valores: jugador['tablero'] ?? [],
                              capa: estado.tablero.capa,
                              tamanoCasilla: 9.0,
                            ),
                            const SizedBox(width: 14),
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
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
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
                                Icons.emoji_events_rounded,
                                color: Colors.amber,
                                size: 38,
                              ),
                          ],
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
                            ? Icons.emoji_events_rounded
                            : Icons.sentiment_dissatisfied_rounded,
                        size: 96,
                        color: estado.esVictoria ? Colors.amber : Colors.white38,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          'Puntuación Final: ${estado.puntuacionFinal}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (estado.cambioRangoPropio != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
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

              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B00), Color(0xFFE30059)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B00).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home_rounded),
                  label: const Text(
                    'VOLVER AL MENÚ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}