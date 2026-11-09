import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/auth_bloc.dart';
import 'package:jueguito/auth_event.dart';
import 'package:jueguito/auth_state.dart';
import 'package:jueguito/servicios/servicio_auth.dart';
import 'package:jueguito/ui/pantalla_seleccion_mapas.dart';
import 'package:jueguito/ui/pantalla_lobby.dart';

class PantallaMenuPrincipal extends StatelessWidget {
  const PantallaMenuPrincipal({super.key});

  void _cerrarSesion(BuildContext context) {
    context.read<AuthBloc>().add(CerrarSesionEvent());
  }

  void _confirmarBorrarCuenta(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar cuenta?'),
        content: const Text('Esta acción es permanente y perderás todo tu progreso. ¿Estás seguro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); 
              final resultado = await ServicioAuth().borrarCuenta();
              if (context.mounted) {
                if (resultado['exito'] == true) {
                  context.read<AuthBloc>().add(CerrarSesionEvent());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cuenta eliminada'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(resultado['mensaje']), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Sí, borrar'),
          ),
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
                      child: Row(children: [Icon(Icons.delete_forever, color: Colors.red), SizedBox(width: 8), Text('Borrar Cuenta', style: TextStyle(color: Colors.red))]),
                    ),
                  PopupMenuItem(
                    value: 'cerrar_sesion',
                    child: Row(children: [const Icon(Icons.logout, color: Colors.black54), SizedBox(width: 8), Text(state is AuthInvitado ? 'Salir de Invitado' : 'Cerrar Sesión')]),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'BRILLIANT',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFFFF6B00), letterSpacing: 4),
              ),
              const SizedBox(height: 60),
              
              _BotonMenu(
                titulo: 'Jugar Solo',
                icono: Icons.person,
                color: Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaSeleccionMapas(modoMultijugador: false))),
              ),
              const SizedBox(height: 20),
              
              _BotonMenu(
                titulo: 'Multijugador',
                icono: Icons.wifi,
                color: const Color(0xFFE30059),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaLobby())),
              ),
              const SizedBox(height: 20),

              _BotonMenu(
                titulo: 'Reglas del Juego',
                icono: Icons.menu_book,
                color: Colors.green,
                onTap: () {
                  // TODO: Aquí conectaremos tu pantalla de reglas en el futuro
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pantalla de reglas en construcción...')));
                },
              ),
            ],
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

  const _BotonMenu({required this.titulo, required this.icono, required this.color, required this.onTap});

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