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
  
  // VARIABLES MULTIJUGADOR
  bool _esAnfitrion = false;
  List<String> _jugadores = [];

  @override
  void initState() {
    super.initState();
    _iniciarConexion();
  }

  Future<void> _iniciarConexion() async {
    final exito = await _servicio.conectar();
    if (exito) {
      setState(() {
        _conectando = false;
        _estado = 'Conectado. ¿Qué deseas hacer?';
      });
      _escucharServidor();
    } else {
      setState(() {
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
            _esAnfitrion = true;
            _codigoGenerado = datos['codigo'];
            _jugadores = List<String>.from(datos['jugadores']);
            break;
            
          case 'unido_exitosamente':
            _esAnfitrion = false;
            _codigoGenerado = datos['codigo'];
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
           Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => JuegoBloc(Tablero(CapaZonas(TipoMapa.mapa1)), servicioRed: _servicio),
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
    _servicio.desconectar();
    _codigoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EE),
      appBar: AppBar(
        title: const Text('Lobby Multijugador'),
        backgroundColor: const Color(0xFF0055A4),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _conectando 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFFFF6B00)),
                const SizedBox(height: 20),
                Text(_estado, style: const TextStyle(fontSize: 18)),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: _codigoGenerado == null 
                  ? _buildMenuInicial() 
                  : _buildSalaDeEspera(),
            ),
      ),
    );
  }

  // WIDGET: Menú para crear o unirse a sala
  Widget _buildMenuInicial() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Crear Sala Nueva', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0055A4),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
          ),
          onPressed: () => _servicio.crearSala(),
        ),
        const SizedBox(height: 40),
        const Text('O únete a una existente:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        TextField(
          controller: _codigoController,
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 5),
          decoration: const InputDecoration(
            labelText: 'CÓDIGO DE SALA',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.meeting_room),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B00),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
          ),
          onPressed: () {
            if (_codigoController.text.trim().isNotEmpty) {
              _servicio.unirseSala(_codigoController.text.trim());
            }
          },
          child: const Text('Unirse a Partida', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  // WIDGET: Vista cuando ya estás dentro de una sala
  Widget _buildSalaDeEspera() {
    return Column(
      children: [
        const Text('Código de Invitación:', style: TextStyle(fontSize: 18, color: Colors.grey)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF0055A4), width: 2),
          ),
          child: Text(
            _codigoGenerado!,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 5),
          ),
        ),
        const SizedBox(height: 20),
        
        // Lista de Jugadores
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Botón de Acción dependiendo del Rol
        if (_esAnfitrion)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _jugadores.length >= 2 ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
            ),
            onPressed: _jugadores.length >= 2 ? () => _servicio.iniciarPartida() : null,
            child: Text(
              _jugadores.length >= 2 ? 'Iniciar Partida' : 'Esperando más jugadores...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        else
          Column(
            children: const [
              CircularProgressIndicator(color: Color(0xFFE30059)),
              SizedBox(height: 15),
              Text('Esperando a que el anfitrión inicie...', style: TextStyle(fontSize: 16)),
            ],
          ),
      ],
    );
  }
}