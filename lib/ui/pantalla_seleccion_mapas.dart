import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/tablero.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/ui/pantalla_tablero.dart';

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

  final List<DatosMapa> _mapas = [
    DatosMapa('Mapa 1', 'Nivel 1', TipoMapa.mapa1, 'assets/mapas/mapa1.png'),
    DatosMapa('Mapa 2', 'Nivel 2', TipoMapa.mapa2, 'assets/mapas/mapa2.png'),
    DatosMapa('Mapa 3', 'Nivel 3', TipoMapa.mapa3, 'assets/mapas/mapa3.png'),
    DatosMapa('Mapa 4', 'Nivel 4', TipoMapa.mapa4, 'assets/mapas/mapa4.png'),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Iniciamos la animación en cuanto carga la pantalla
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _seleccionarMapa(BuildContext context, TipoMapa tipo) {
    // 1. Creamos el tablero con el mapa elegido
    final tableroSeleccionado = Tablero(CapaZonas(tipo));
    
    // 2. Navegamos a la pantalla del juego inyectando el nuevo BLoC
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => JuegoBloc(tableroSeleccionado),
          child: const PantallaTablero(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Aquí cambiamos el color de fondo de toda la pantalla
      backgroundColor: Colors.blueGrey[900], // Un tono oscuro muy elegante (puedes usar Colors.grey[900] también)
      
      appBar: AppBar(
        // 2. Hacemos que la barra superior combine con el fondo oscuro
        backgroundColor: Colors.blueGrey[900], 
        foregroundColor: Colors.white, // Hace que el texto y los íconos del AppBar sean blancos
        elevation: 0, // Quitamos la rayita de sombra para un look más limpio
        title: const Text('Selecciona un Mapa', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _mapas.length,
        itemBuilder: (context, index) {
          final mapa = _mapas[index];

          // Animación "Staggered" (en cascada). Cada elemento entra un poco más tarde que el anterior.
          final animacionEntrada = Tween<Offset>(begin: const Offset(-1.5, 0), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _animController,
              curve: Interval(
                index * 0.2, // Retraso progresivo: 0.0, 0.2, 0.4...
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
                    color: Colors.blueGrey[800], // <-- Tarjeta gris oscura (contrasta con el fondo 900)
                    borderRadius: BorderRadius.circular(16),
                    // Sombra más fuerte para que parezca que flota
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      // La imagen del mapa (esto se queda igual)
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
                            color: Colors.blueGrey[700], // <-- Comodín oscuro
                            child: const Icon(Icons.map, size: 40, color: Colors.white54),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Textos del botón
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mapa.titulo,
                              // <-- Título en blanco para que resalte
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mapa.descripcion,
                              // <-- Descripción en un blanco opaco
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