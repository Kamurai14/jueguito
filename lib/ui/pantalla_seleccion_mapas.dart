import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/tablero.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/ui/pantalla_tablero.dart';
// Imports agregados para la seguridad
import 'package:jueguito/servicios/servicio_auth.dart';
import 'package:jueguito/ui/pantalla_login.dart';

class DatosMapa {
  final String titulo;
  final String descripcion;
  final TipoMapa tipo;
  final String rutaImagen;

  DatosMapa(this.titulo, this.descripcion, this.tipo, this.rutaImagen);
}

class PantallaSeleccionMapas extends StatefulWidget {
  const PantallaSeleccionMapas({super.key});

  @override
  State<PantallaSeleccionMapas> createState() => _PantallaSeleccionMapasState();
}

class _PantallaSeleccionMapasState extends State<PantallaSeleccionMapas> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _nombreUsuario = 'Jugador'; // <-- Variable para guardar el nombre

  final List<DatosMapa> _mapas = [
    DatosMapa('Mapa 1', 'Nivel 1', TipoMapa.mapa1, 'assets/mapas/mapa1.png'),
    DatosMapa('Mapa 2', 'Nivel 2', TipoMapa.mapa2, 'assets/mapas/mapa2.png'),
    DatosMapa('Mapa 3', 'Nivel 3', TipoMapa.mapa3, 'assets/mapas/mapa3.png'),
    DatosMapa('Mapa 4', 'Nivel 4', TipoMapa.mapa4, 'assets/mapas/mapa4.png'),
  ];

  @override
  void initState() {
    super.initState();
    _cargarUsuario(); // <-- Cargamos el usuario al entrar
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animController.forward();
  }

  // --- NUEVA FUNCIÓN PARA LEER EL USUARIO ---
  void _cargarUsuario() async {
    final usuario = await ServicioAuth().obtenerUsuarioActual();
    if (mounted && usuario != null) {
      setState(() => _nombreUsuario = usuario);
    }
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

  void _cerrarSesion() async {
    await ServicioAuth().cerrarSesion();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaLogin()),
      );
    }
  }

  void _confirmarBorrarCuenta() {
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
              
              if (mounted) {
                if (resultado['exito'] == true) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const PantallaLogin()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cuenta eliminada correctamente'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(resultado['mensaje']), backgroundColor: Colors.red),
                  );
                }
              }
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
      backgroundColor: Colors.blueGrey[900], 
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900], 
        foregroundColor: Colors.white, 
        elevation: 0, 
        // --- AQUÍ MOSTRAMOS EL NOMBRE DEL USUARIO ---
        title: Text('Hola, $_nombreUsuario', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.person, color: Colors.white), // Cambié el engranaje por un ícono de usuario
            onSelected: (value) {
              if (value == 'cerrar_sesion') _cerrarSesion();
              else if (value == 'borrar_cuenta') _confirmarBorrarCuenta();
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'cerrar_sesion',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
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
            ],
          ),
        ],
      ),
      body: ListView.builder(
        // ... (Tu código del ListView.builder se queda EXACTAMENTE igual)
        padding: const EdgeInsets.all(16.0),
        itemCount: _mapas.length,
        itemBuilder: (context, index) {
          final mapa = _mapas[index];

          final animacionEntrada = Tween<Offset>(begin: const Offset(-1.5, 0), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _animController,
              curve: Interval(
                index * 0.2, 
                1.0,
                curve: Curves.easeOutCubic,
              ),
            ),
          );

          return SlideTransition(
            position: animacionEntrada,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: () => _seleccionarMapa(context, mapa.tipo),
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[800], 
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                        child: Image.asset(
                          mapa.rutaImagen,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.blueGrey[700], 
                            child: const Icon(Icons.map, size: 40, color: Colors.white54),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mapa.titulo,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mapa.descripcion,
                              style: const TextStyle(fontSize: 14, color: Colors.white70), 
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white54, size: 32),
                      const SizedBox(width: 12),
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
}