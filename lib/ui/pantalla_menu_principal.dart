import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/auth_bloc.dart';
import 'package:jueguito/auth_event.dart';
import 'package:jueguito/auth_state.dart';
import 'package:jueguito/servicios/servicio_auth.dart';
import 'package:jueguito/ui/pantalla_seleccion_mapas.dart';
import 'package:jueguito/ui/pantalla_lobby.dart';
import 'package:jueguito/ui/pantalla_reglas.dart';

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
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.amber),
            SizedBox(width: 8),
            Text('Modo Competitivo'),
          ],
        ),
        content: const Text(
          'Debes iniciar sesión con una cuenta registrada para jugar en Modo Competitivo y guardar tu rango.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0055A4),
              foregroundColor: Colors.white,
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
        title: const Text('¿Borrar cuenta?'),
        content: const Text('Esta acción es permanente y perderás todo tu progreso. ¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        return const Color(0xFFCD7F32); // Bronce
      case 1:
        return Colors.grey[300]!; // Plata
      case 2:
        return Colors.amber; // Oro
      case 3:
        return Colors.cyanAccent; // Platino
      case 4:
        return Colors.lightBlueAccent; // Diamante
      case 5:
        return Colors.purpleAccent; // Maestro
      case 6:
      default:
        return Colors.redAccent; // Gran Maestro
    }
  }

  Widget _buildTarjetaRango() {
    if (_cargandoPerfil) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 24.0),
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
    final int puntos = _perfil!['puntos'] ?? 0;
    final bool esGranMaestro = nivelIndex >= 6;
    final Color colorRango = _obtenerColorRango(nivelIndex);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorRango, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events, color: colorRango, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    nombreNivel.toUpperCase(),
                    style: TextStyle(
                      color: colorRango,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Text(
                esGranMaestro ? '$puntos pts' : '$puntos / 100 pts',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!esGranMaestro) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (puntos / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.black38,
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
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        elevation: 0,
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAutenticado) {
              return Text('Hola, ${state.usuario}', style: const TextStyle(fontWeight: FontWeight.bold));
            }
            return const Text('Modo Invitado', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey));
          },
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.person, color: Colors.white),
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
                          Icon(Icons.delete_forever, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Borrar Cuenta', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'cerrar_sesion',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.black54),
                        const SizedBox(width: 8),
                        Text(state is AuthInvitado ? 'Salir de Invitado' : 'Cerrar Sesión'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'BRILLIANT',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFF6B00),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (authState is AuthAutenticado) _buildTarjetaRango(),

                  _BotonMenu(
                    titulo: 'Jugar Solo',
                    icono: Icons.person,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PantallaSeleccionMapas(modoMultijugador: false)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _BotonMenu(
                    titulo: 'Multijugador',
                    icono: Icons.wifi,
                    color: const Color(0xFFE30059),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PantallaLobby(esCompetitivo: false)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _BotonMenu(
                    titulo: 'Modo Competitivo',
                    icono: Icons.emoji_events,
                    color: Colors.amber[800]!,
                    onTap: () async {
                      if (authState is AuthInvitado) {
                        _mostrarAvisoInvitado(context);
                        return;
                      }
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PantallaLobby(esCompetitivo: true)),
                      );
                      _cargarPerfil(); // Actualiza los puntos al regresar de jugar
                    },
                  ),
                  const SizedBox(height: 16),

                  _BotonMenu(
                    titulo: 'Reglas del Juego',
                    icono: Icons.menu_book,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaReglas()));
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BotonMenu extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  const _BotonMenu({
    required this.titulo,
    required this.icono,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 28),
          const SizedBox(width: 12),
          Text(titulo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}