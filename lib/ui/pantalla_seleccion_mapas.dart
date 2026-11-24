import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/tablero.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/ui/pantalla_tablero.dart';
import 'package:jueguito/auth_bloc.dart';
import 'package:jueguito/auth_event.dart';
import 'package:jueguito/auth_state.dart';
import 'package:jueguito/servicios/servicio_auth.dart';

class DatosMapa {
  final String titulo;
  final String nivel;
  final String descripcion;
  final TipoMapa tipo;
  final String rutaImagen;

  DatosMapa(this.titulo, this.nivel, this.descripcion, this.tipo, this.rutaImagen);
}

class PantallaSeleccionMapas extends StatefulWidget {
  final bool modoMultijugador;
  const PantallaSeleccionMapas({super.key, this.modoMultijugador = false});

  @override
  State<PantallaSeleccionMapas> createState() => _PantallaSeleccionMapasState();
}

class _PantallaSeleccionMapasState extends State<PantallaSeleccionMapas>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  final List<DatosMapa> _mapas = [
    DatosMapa(
      'Mapa 1',
      'Nivel 1',
      'Tablero clásico equilibrado para dominar las reglas base.',
      TipoMapa.mapa1,
      'assets/mapas/mapa1.png',
    ),
    DatosMapa(
      'Mapa 2',
      'Nivel 2',
      'Introduce zonas blancas con números iguales.',
      TipoMapa.mapa2,
      'assets/mapas/mapa2.png',
    ),
    DatosMapa(
      'Mapa 3',
      'Nivel 3',
      'Zonas amplias y mayor recompensa en zonas blancas.',
      TipoMapa.mapa3,
      'assets/mapas/mapa3.png',
    ),
    DatosMapa(
      'Mapa 4',
      'Nivel 4',
      'Zonas naranjas con rangos estrictos (1-3 y 4-6).',
      TipoMapa.mapa4,
      'assets/mapas/mapa4.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _seleccionarMapa(BuildContext context, TipoMapa tipo) {
    final tableroSeleccionado = Tablero(CapaZonas(tipo));
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => JuegoBloc(tableroSeleccionado),
          child: const PantallaTablero(),
        ),
      ),
    );
  }

  void _cerrarSesion() {
    context.read<AuthBloc>().add(CerrarSesionEvent());
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _confirmarBorrarCuenta() {
    final authBloc = context.read<AuthBloc>();
    final navegador = Navigator.of(context);
    final mensajero = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF101C2C),
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
            child: const Text('Sí, borrar mi cuenta'),
          ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_rounded, color: Color(0xFF00A8E8), size: 22),
            SizedBox(width: 8),
            Text(
              'Seleccionar Mapa',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
                color: const Color(0xFF101C2C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                onSelected: (value) {
                  if (value == 'cerrar_sesion') {
                    _cerrarSesion();
                  } else if (value == 'borrar_cuenta') {
                    _confirmarBorrarCuenta();
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.4),
            radius: 1.3,
            colors: [
              Color(0xFF0D253F),
              Color(0xFF0A1526),
              Color(0xFF060A12),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                itemCount: _mapas.length,
                itemBuilder: (context, index) {
                  final mapa = _mapas[index];

                  final animacionEntrada = Tween<Offset>(
                    begin: const Offset(-0.5, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: Interval(
                        index * 0.15,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  );

                  return SlideTransition(
                    position: animacionEntrada,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _TarjetaMapa(
                        mapa: mapa,
                        onTap: () => _seleccionarMapa(context, mapa.tipo),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TarjetaMapa extends StatefulWidget {
  final DatosMapa mapa;
  final VoidCallback onTap;

  const _TarjetaMapa({required this.mapa, required this.onTap});

  @override
  State<_TarjetaMapa> createState() => _TarjetaMapaState();
}

class _TarjetaMapaState extends State<_TarjetaMapa> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hover ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 140),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: _hover ? 0.1 : 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _hover
                    ? const Color(0xFF00A8E8).withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.12),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _hover
                      ? const Color(0xFF00A8E8).withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.35),
                  blurRadius: _hover ? 18 : 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                  child: Image.asset(
                    widget.mapa.rutaImagen,
                    width: 115,
                    height: 115,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 115,
                      height: 115,
                      color: const Color(0xFF102A43),
                      child: const Icon(Icons.map_rounded, size: 40, color: Colors.white38),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.mapa.titulo,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00A8E8).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF00A8E8).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                widget.mapa.nivel.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF72EFDD),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.mapa.descripcion,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: _hover ? const Color(0xFF00A8E8) : Colors.white38,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}