import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/auth_bloc.dart';
import 'package:jueguito/auth_event.dart';
import 'package:jueguito/auth_state.dart';
import 'package:jueguito/servicios/servicio_auth.dart';
import 'package:jueguito/ui/pantalla_seleccion_mapas.dart';
import 'package:jueguito/ui/pantalla_lobby.dart';
import 'package:jueguito/ui/pantalla_reglas.dart';
import 'package:jueguito/ui/fondo_animado_brilliant.dart';

class PantallaMenuPrincipal extends StatefulWidget {
  const PantallaMenuPrincipal({super.key});

  @override
  State<PantallaMenuPrincipal> createState() => _PantallaMenuPrincipalState();
}

class _PantallaMenuPrincipalState extends State<PantallaMenuPrincipal> {
  Map? _perfil;
  bool _cargandoPerfil = false;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAutenticado) return;

    setState(() => _cargandoPerfil = true);
    final datos = await ServicioAuth().obtenerPerfil();
    if (!mounted) return;

    setState(() {
      _perfil = datos;
      _cargandoPerfil = false;
    });
  }

  void _cerrarSesion(BuildContext context) {
    context.read<AuthBloc>().add(CerrarSesionEvent());
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _mostrarAvisoInvitado(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1836),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.amber.withValues(alpha: 0.4)),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.amber),
            SizedBox(width: 8),
            Text('Modo Competitivo', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Debes iniciar sesión con una cuenta registrada para jugar en Modo Competitivo y guardar tu rango.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _cerrarSesion(context);
            },
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  void _confirmarBorrarCuenta(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final navegador = Navigator.of(context);
    final mensajero = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1836),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Borrar cuenta?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Esta acción es permanente y perderás todo tu progreso. ¿Estás seguro?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ServicioAuth().borrarCuenta();

              authBloc.add(CerrarSesionEvent());
              navegador.popUntil((route) => route.isFirst);
              mensajero.showSnackBar(
                const SnackBar(content: Text('Cuenta eliminada'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Sí, borrar'),
          ),
        ],
      ),
    );
  }

  Color _obtenerColorRango(int nivelIndex) {
    switch (nivelIndex) {
      case 0:
        return const Color(0xFFCD7F32);
      case 1:
        return Colors.grey[300]!;
      case 2:
        return Colors.amber;
      case 3:
        return Colors.cyanAccent;
      case 4:
        return Colors.lightBlueAccent;
      case 5:
        return Colors.purpleAccent;
      case 6:
      default:
        return Colors.redAccent;
    }
  }

  Widget _buildEncabezadoHub() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MENÚ PRINCIPAL',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFFB703), Color(0xFFFF6B00), Color(0xFFE30059)],
              ).createShader(bounds),
              child: const Text(
                'BRILLIANT',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
            ),
          ],
        ),
        const Icon(Icons.grid_view_rounded, color: Colors.white24, size: 42),
      ],
    );
  }

  Widget _buildTarjetaRango() {
    if (_cargandoPerfil) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 20.0),
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
        ),
      );
    }

    if (_perfil == null) return const SizedBox.shrink();

    final int nivelIndex = _perfil!['nivelIndex'] ?? 0;
    final String nombreNivel = _perfil!['nombreNivel'] ?? 'Bronce';
    final int elo = _perfil!['elo'] ?? _perfil!['puntos'] ?? 1000;
    final int eloMin = _perfil!['eloMinimoNivel'] ?? 1000;
    final int eloSig = _perfil!['eloSiguienteNivel'] ?? 1150;
    final bool esGranMaestro = nivelIndex >= 6;
    final Color colorRango = _obtenerColorRango(nivelIndex);

    final double progreso = esGranMaestro
        ? 1.0
        : ((elo - eloMin) / (eloSig - eloMin)).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1B3D).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorRango.withValues(alpha: 0.75), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colorRango.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorRango.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.emoji_events, color: colorRango, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RANGO ACTUAL',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        nombreNivel.toUpperCase(),
                        style: TextStyle(
                          color: colorRango,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                esGranMaestro ? '$elo ELO' : '$elo / $eloSig ELO',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!esGranMaestro) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progreso,
                minHeight: 8,
                backgroundColor: Colors.black45,
                valueColor: AlwaysStoppedAnimation<Color>(colorRango),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAutenticado) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user, size: 16, color: Color(0xFFFFB703)),
                    const SizedBox(width: 6),
                    Text(
                      state.usuario,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Modo Invitado',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white60),
              ),
            );
          },
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
                color: const Color(0xFF1F1B3D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (value) {
                  if (value == 'cerrar_sesion') {
                    _cerrarSesion(context);
                  } else if (value == 'borrar_cuenta') {
                    _confirmarBorrarCuenta(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  if (state is AuthAutenticado)
                    const PopupMenuItem(
                      value: 'borrar_cuenta',
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Borrar Cuenta', style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'cerrar_sesion',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text(
                          state is AuthInvitado ? 'Salir de Invitado' : 'Cerrar Sesión',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FondoAnimadoBrilliant(
        // Paleta índigo/morado distinta al Login
        coloresFondo: const [
          Color(0xFF2B235A),
          Color(0xFF161230),
          Color(0xFF0A0818),
        ],
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEncabezadoHub(),
                        const SizedBox(height: 20),

                        if (authState is AuthAutenticado) _buildTarjetaRango(),

                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.95,
                          children: [
                            _TarjetaModoJuego(
                              titulo: 'Jugar Solo',
                              subtitulo: 'Practica y supera tu récord',
                              icono: Icons.person,
                              colorInicio: const Color(0xFF0096C7),
                              colorFin: const Color(0xFF0055A4),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PantallaSeleccionMapas(modoMultijugador: false),
                                ),
                              ),
                            ),
                            _TarjetaModoJuego(
                              titulo: 'Multijugador',
                              subtitulo: 'Salas casuales con amigos',
                              icono: Icons.wifi,
                              colorInicio: const Color(0xFFFF2A7A),
                              colorFin: const Color(0xFFC2004B),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PantallaLobby(esCompetitivo: false),
                                ),
                              ),
                            ),
                            _TarjetaModoJuego(
                              titulo: 'Competitivo',
                              subtitulo: authState is AuthInvitado
                                  ? 'Inicia sesión'
                                  : 'Sube de rango',
                              icono: authState is AuthInvitado ? Icons.lock : Icons.emoji_events,
                              colorInicio: const Color(0xFFFFB703),
                              colorFin: const Color(0xFFE07A00),
                              onTap: () async {
                                if (authState is AuthInvitado) {
                                  _mostrarAvisoInvitado(context);
                                  return;
                                }
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PantallaLobby(esCompetitivo: true),
                                  ),
                                );
                                _cargarPerfil();
                              },
                            ),
                            _TarjetaModoJuego(
                              titulo: 'Reglas',
                              subtitulo: 'Zonas y puntos',
                              icono: Icons.menu_book,
                              colorInicio: const Color(0xFF4CAF50),
                              colorFin: const Color(0xFF2E7D32),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PantallaReglas()),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaModoJuego extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color colorInicio;
  final Color colorFin;
  final VoidCallback onTap;

  const _TarjetaModoJuego({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.colorInicio,
    required this.colorFin,
    required this.onTap,
  });

  @override
  State<_TarjetaModoJuego> createState() => _TarjetaModoJuegoState();
}

class _TarjetaModoJuegoState extends State<_TarjetaModoJuego> {
  bool _hover = false;
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final double escala = _presionado ? 0.95 : (_hover ? 1.03 : 1.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _presionado = true),
        onTapUp: (_) {
          setState(() => _presionado = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _presionado = false),
        child: AnimatedScale(
          scale: escala,
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.colorInicio, widget.colorFin],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: _hover ? 0.45 : 0.18),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.colorFin.withValues(alpha: _hover ? 0.55 : 0.35),
                  blurRadius: _hover ? 20 : 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icono, size: 32, color: Colors.white),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.titulo,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitulo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}