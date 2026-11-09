import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/servicios/servicio_multiplayer.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/tablero.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/ui/pantalla_tablero.dart';

class PantallaLobby extends StatefulWidget {
  const PantallaLobby({super.key});

  @override
  State<PantallaLobby> createState() => _PantallaLobbyState();
}

class _PantallaLobbyState extends State<PantallaLobby> {
  final ServicioMultiplayer _servicio = ServicioMultiplayer();
  final TextEditingController _codigoController = TextEditingController();
  
  bool _conectando = true;
  String? _codigoGenerado;
  String _estado = 'Conectando al servidor...';
  
  bool _esAnfitrion = false;
  List<String> _jugadores = [];
  bool _saliendoVoluntariamente = false;
  String _mapaSeleccionado = 'mapa1'; // <-- Guardamos qué mapa se va a jugar

  @override
  void initState() {
    super.initState();
    _iniciarConexion();
  }

  Future<void> _iniciarConexion() async {
    final exito = await _servicio.conectar();
    if (!mounted) return; 

    if (exito) {
      setState(() {
        _conectando = false;
        _estado = 'Conectado. ¿Qué deseas hacer?';
      });
      _escucharServidor();
    } else {
      setState(() {
        _conectando = false; 
        _estado = 'Error de conexión. Verifica tu internet o servidor.';
      });
    }
  }

  void _escucharServidor() {
    _servicio.streamMensajes?.listen((mensaje) {
      final datos = jsonDecode(mensaje);
      if (!mounted) return;

      setState(() {
        switch (datos['tipo']) {
          case 'sala_creada':
          case 'unido_exitosamente':
            _esAnfitrion = datos['tipo'] == 'sala_creada';
            _codigoGenerado = datos['codigo'];
            _mapaSeleccionado = datos['mapa'] ?? 'mapa1'; // Guardamos el mapa de la sala
            _jugadores = List<String>.from(datos['jugadores']);
            break;
            
          case 'lobby_actualizado':
          case 'jugador_desconectado':
            _jugadores = List<String>.from(datos['jugadores']);
            if (datos['mensaje'] != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(datos['mensaje']), backgroundColor: Colors.orange),
              );
            }
            break;
            
          case 'error':
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(datos['mensaje']), backgroundColor: Colors.red),
            );
            break;
            
          case 'partida_lista':
            _saliendoVoluntariamente = true; 
            
            final nombreMapa = datos['mapa'] ?? 'mapa1';
            TipoMapa mapaElegido = TipoMapa.values.firstWhere(
              (m) => m.name == nombreMapa, 
              orElse: () => TipoMapa.mapa1
            );
            
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => JuegoBloc(
                    Tablero(CapaZonas(mapaElegido)),servicioRed: _servicio, esAnfitrion: _esAnfitrion), 
                  child: const PantallaTablero(),
                ),
              ),
            );
            break;
        }
      });
    }, onDone: () {
      if (mounted) setState(() => _estado = 'Desconectado del servidor.');
    });
  }

  @override
  void dispose() {
    if (!_saliendoVoluntariamente) {
      try {
        _servicio.desconectar();
      } catch (_) {}
    }
    _codigoController.dispose();
    super.dispose();
  }

  // DIÁLOGO PREVIO: Elige el mapa antes de crear la sala
  void _mostrarSelectorDeMapasParaCrear() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Elige la Campaña (Mapa)'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: TipoMapa.values.length,
              itemBuilder: (context, index) {
                final tipo = TipoMapa.values[index];
                return ListTile(
                  leading: const Icon(Icons.map, color: Color(0xFFFF6B00), size: 40),
                  title: Text('Mapa ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Toca para crear la sala'),
                  onTap: () {
                    Navigator.pop(context); 
                    _servicio.crearSala(tipo.name); // Crea la sala con este mapa
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _saliendoVoluntariamente = true;
        _servicio.desconectar();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E1E), // Fondo oscuro más gamer
        appBar: AppBar(
          title: const Text('Multijugador'),
          backgroundColor: const Color(0xFF000000),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _saliendoVoluntariamente = true;
              _servicio.desconectar();
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: _conectando 
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFFF6B00)),
                  const SizedBox(height: 20),
                  Text(_estado, style: const TextStyle(fontSize: 18, color: Colors.white)),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: _codigoGenerado == null 
                    ? _buildMenuInicial() 
                    : _buildSalaDeEspera(), // El lobby estilo L4D
              ),
        ),
      ),
    );
  }

  Widget _buildMenuInicial() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_box),
          label: const Text('Crear Nueva Sala', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B00),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
          ),
          onPressed: _mostrarSelectorDeMapasParaCrear, // Abre el selector primero
        ),
        const SizedBox(height: 40),
        const Text('UNIRSE A UNA PARTIDA', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: _codigoController,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 5, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[800],
            hintText: 'CÓDIGO',
            hintStyle: const TextStyle(color: Colors.white38),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.meeting_room, color: Colors.white54),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0055A4),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
          ),
          onPressed: () {
            if (_codigoController.text.trim().isNotEmpty) {
              _servicio.unirseSala(_codigoController.text.trim());
            }
          },
          child: const Text('Entrar a la Sala', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildSalaDeEspera() {
    // Extraemos el número del mapa (ej. de "mapa1" a "1") para mostrarlo bonito
    String numeroMapa = _mapaSeleccionado.replaceAll(RegExp(r'[^0-9]'), '');

    return Column(
      children: [
        // EL PÓSTER DE LA CAMPAÑA (Al estilo Left 4 Dead)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blueGrey[900],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFFF6B00), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 5))
            ]
          ),
          child: Column(
            children: [
              const Text('CAMPAÑA SELECCIONADA', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
              const SizedBox(height: 5),
              Text(
                'MAPA $numeroMapa',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('CÓDIGO DE SALA: ', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  Text(
                    _codigoGenerado!,
                    style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 3),
                  ),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // LA LISTA DE JUGADORES
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              itemCount: _jugadores.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index == 0 ? Colors.amber : Colors.blueGrey,
                    child: Icon(
                      index == 0 ? Icons.star : Icons.person, 
                      color: Colors.white
                    ),
                  ),
                  title: Text(
                    _jugadores[index] + (index == 0 ? ' (Anfitrión)' : ''),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        // EL BOTÓN DE ARRANQUE
        if (_esAnfitrion)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _jugadores.length >= 2 ? Colors.green : Colors.grey[700],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
            ),
            onPressed: _jugadores.length >= 2 ? () => _servicio.iniciarPartida() : null,
            child: Text(
              _jugadores.length >= 2 ? 'EMPEZAR PARTIDA' : 'Esperando jugadores...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
          )
        else
          Column(
            children: const [
              CircularProgressIndicator(color: Color(0xFFFF6B00)),
              SizedBox(height: 15),
              Text('Esperando a que el anfitrión inicie...', style: TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
      ],
    );
  }
}