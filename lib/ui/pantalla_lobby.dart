import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/servicios/servicio_multiplayer.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/tablero.dart';
import 'package:jueguito/juego_bloc.dart';
import 'package:jueguito/ui/pantalla_tablero.dart';
import 'package:jueguito/auth_bloc.dart';
import 'package:jueguito/auth_state.dart';

class PantallaLobby extends StatefulWidget {
  final bool esCompetitivo;
  const PantallaLobby({super.key, this.esCompetitivo = false});

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
  String _mapaSeleccionado = 'mapa1';
  bool _esSalaCompetitiva = false;

  Color get _colorAcento =>
      (widget.esCompetitivo || _esSalaCompetitiva)
          ? const Color(0xFFFFB703)
          : const Color(0xFFE30059);

  Color get _colorAcentoSecundario =>
      (widget.esCompetitivo || _esSalaCompetitiva)
          ? const Color(0xFFE07A00)
          : const Color(0xFFFF6B00);

  @override
  void initState() {
    super.initState();
    _esSalaCompetitiva = widget.esCompetitivo;
    _iniciarConexion();
  }

  Future<void> _iniciarConexion() async {
    final authState = context.read<AuthBloc>().state;
    String? nombreInvitado;

    if (authState is AuthInvitado) {
      nombreInvitado = authState.usuario;
    }

    final exito = await _servicio.conectar(nombreInvitado: nombreInvitado);

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
    _servicio.streamMensajes?.listen(
      (mensaje) {
        final datos = jsonDecode(mensaje);
        if (!mounted) return;

        setState(() {
          switch (datos['tipo']) {
            case 'sala_creada':
            case 'unido_exitosamente':
              _esAnfitrion = datos['tipo'] == 'sala_creada';
              _codigoGenerado = datos['codigo'];
              _mapaSeleccionado = datos['mapa'] ?? 'mapa1';
              _esSalaCompetitiva = datos['esCompetitiva'] ?? widget.esCompetitivo;
              _jugadores = List<String>.from(datos['jugadores']);
              break;

            case 'lobby_actualizado':
            case 'jugador_desconectado':
              _jugadores = List<String>.from(datos['jugadores']);
              if (datos['mensaje'] != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(datos['mensaje']),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
              break;

            case 'sala_cerrada':
              _saliendoVoluntariamente = true;
              _servicio.desconectar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(datos['razon'] ?? 'El anfitrión cerró la sala.'),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.pop(context);
              break;

            case 'error':
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(datos['mensaje']),
                  backgroundColor: Colors.red,
                ),
              );
              break;

            case 'partida_lista':
              _saliendoVoluntariamente = true;

              final nombreMapa = datos['mapa'] ?? 'mapa1';
              TipoMapa mapaElegido = TipoMapa.values.firstWhere(
                (m) => m.name == nombreMapa,
                orElse: () => TipoMapa.mapa1,
              );

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => JuegoBloc(
                      Tablero(CapaZonas(mapaElegido)),
                      servicioRed: _servicio,
                      esAnfitrion: _esAnfitrion,
                    ),
                    child: const PantallaTablero(),
                  ),
                ),
              );
              break;
          }
        });
      },
      onDone: () {
        if (mounted) setState(() => _estado = 'Desconectado del servidor.');
      },
    );
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

  void _mostrarSelectorDeMapasParaCrear() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181A24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _colorAcento.withValues(alpha: 0.4)),
          ),
          title: Row(
            children: [
              Icon(Icons.map_rounded, color: _colorAcento),
              const SizedBox(width: 10),
              const Text(
                'Elige el Mapa',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 360,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: TipoMapa.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tipo = TipoMapa.values[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.pop(context);
                    _servicio.crearSala(
                      tipo.name,
                      esCompetitiva: widget.esCompetitivo,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _colorAcento.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.grid_on_rounded, color: _colorAcento, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mapa ${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Text(
                                'Toca para crear la sala',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white54),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool modoComp = widget.esCompetitivo || _esSalaCompetitiva;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _saliendoVoluntariamente = true;
        _servicio.desconectar();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                modoComp ? Icons.emoji_events : Icons.wifi,
                color: _colorAcento,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                modoComp ? 'Modo Competitivo' : 'Multijugador',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              _saliendoVoluntariamente = true;
              _servicio.desconectar();
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.0, -0.4),
              radius: 1.3,
              colors: modoComp
                  ? const [Color(0xFF2B200B), Color(0xFF14110C), Color(0xFF0A0908)]
                  : const [Color(0xFF281224), Color(0xFF130E1A), Color(0xFF0A080F)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: _conectando
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: _colorAcento),
                          const SizedBox(height: 20),
                          Text(
                            _estado,
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _codigoGenerado == null
                            ? _buildMenuInicial()
                            : _buildSalaDeEspera(),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuInicial() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tarjeta 1: Crear sala
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CREAR PARTIDA',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.esCompetitivo
                      ? 'Crea una sala clasificatoria (+10 / -4 pts)'
                      : 'Elige un mapa y comparte el código con tus amigos',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_colorAcento, _colorAcentoSecundario],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _colorAcento.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_box_rounded, size: 24),
                    label: const Text(
                      'CREAR NUEVA SALA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _mostrarSelectorDeMapasParaCrear,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tarjeta 2: Unirse con código
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UNIRSE A UNA SALA',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _codigoController,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  maxLength: 4,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.35),
                    hintText: 'CÓDIGO',
                    hintStyle: const TextStyle(
                      color: Colors.white24,
                      letterSpacing: 4,
                      fontSize: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: _colorAcento, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login_rounded),
                    label: const Text(
                      'ENTRAR A LA SALA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0055A4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (_codigoController.text.trim().isNotEmpty) {
                        _servicio.unirseSala(_codigoController.text.trim());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaDeEspera() {
    String numeroMapa = _mapaSeleccionado.replaceAll(RegExp(r'[^0-9]'), '');

    return Column(
      children: [
        // Póster de la sala
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _colorAcento.withValues(alpha: 0.7), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _colorAcento.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              if (_esSalaCompetitiva)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: const Text(
                    'SALA COMPETITIVA',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              const Text(
                'MAPA SELECCIONADO',
                style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2),
              ),
              const SizedBox(height: 4),
              Text(
                'MAPA $numeroMapa',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'CÓDIGO: ',
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                    Text(
                      _codigoGenerado!,
                      style: TextStyle(
                        color: _colorAcento,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Encabezado de lista
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'JUGADORES EN SALA',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '${_jugadores.length} / 6',
              style: TextStyle(
                color: _colorAcento,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Lista de jugadores
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: _jugadores.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.white.withValues(alpha: 0.06),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final bool esHost = index == 0;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: esHost
                        ? Colors.amber.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    child: Icon(
                      esHost ? Icons.star_rounded : Icons.person,
                      color: esHost ? Colors.amber : Colors.white70,
                    ),
                  ),
                  title: Text(
                    _jugadores[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: esHost
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ANFITRIÓN',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Botón de arranque
        if (_esAnfitrion)
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _jugadores.length >= 2 ? Colors.green[600] : Colors.white12,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed:
                  _jugadores.length >= 2 ? () => _servicio.iniciarPartida() : null,
              child: Text(
                _jugadores.length >= 2
                    ? 'EMPEZAR PARTIDA'
                    : 'Esperando al menos 2 jugadores...',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _colorAcento,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Esperando a que el anfitrión inicie...',
                  style: TextStyle(fontSize: 15, color: Colors.white70),
                ),
              ],
            ),
          ),
      ],
    );
  }
}