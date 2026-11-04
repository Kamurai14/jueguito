import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jueguito/servicios/servicio_multiplayer.dart';

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
      
      switch (datos['tipo']) {
        case 'sala_creada':
          setState(() => _codigoGenerado = datos['codigo']);
          break;
        case 'error':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(datos['mensaje']), backgroundColor: Colors.red),
          );
          break;
        case 'partida_lista':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('¡Partida encontrada contra ${datos['rival']}!'), backgroundColor: Colors.green),
          );
          // TODO: Fase 4 - Aquí navegaremos al Tablero Multijugador inyectando el servicio de red
          break;
      }
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
        backgroundColor: const Color(0xFF0055A4), // Azul del tema
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_codigoGenerado == null) ...[
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
                        backgroundColor: const Color(0xFFFF6B00), // Naranja brillante
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
                  ] else ...[
                    const Text('Código de Invitación:', style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF0055A4), width: 2),
                      ),
                      child: Text(
                        _codigoGenerado!,
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 5),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const CircularProgressIndicator(color: Color(0xFFE30059)),
                    const SizedBox(height: 20),
                    const Text('Esperando a que se una el rival...', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ]
                ],
              ),
            ),
      ),
    );
  }
}