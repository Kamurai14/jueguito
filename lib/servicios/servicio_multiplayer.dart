import 'dart:async'; // Necesario para el StreamController
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServicioMultiplayer {
  WebSocketChannel? _canal;
  String? usuarioActual;
  
  // Usamos un StreamController en lugar de un asBroadcastStream directo
  // Esto nos permite "inyectar" mensajes artificiales cuando se cae el internet
  StreamController<dynamic>? _controladorStream; 
  
  final bool _esProduccion = false;
  final _almacenamientoSeguro = const FlutterSecureStorage();

  String get _wsUrl {
    if (_esProduccion) return 'wss://api.tujuego.com/ws';
    if (!kIsWeb && Platform.isAndroid) return 'ws://10.0.2.2:8080/ws';
    return 'ws://127.0.0.1:8080/ws';
  }

  // Exponemos el stream del controlador
  Stream<dynamic>? get streamMensajes => _controladorStream?.stream;

  Future<bool> conectar() async {
    try {
      final token = await _almacenamientoSeguro.read(key: 'jwt_token');
      if (token == null) return false;

      final urlFinal = Uri.parse('$_wsUrl?token=$token');
      usuarioActual = await _almacenamientoSeguro.read(key: 'usuario_actual');
      _canal = WebSocketChannel.connect(urlFinal);
      
      // Inicializamos el controlador como Broadcast
      _controladorStream = StreamController<dynamic>.broadcast();
      
      // Escuchamos el socket y pasamos los mensajes al controlador
      _canal!.stream.listen(
        (mensaje) {
          _controladorStream?.add(mensaje);
        },
        onDone: () {
          // SI SE CORTA EL INTERNET O EL SERVIDOR SE APAGA:
          _controladorStream?.add(jsonEncode({
            'tipo': 'desconexion_local', 
            'razon': 'Se perdió la conexión con el servidor.'
          }));
        },
        onError: (error) {
          // SI HAY UN ERROR DE RED BRUSCO:
          _controladorStream?.add(jsonEncode({
            'tipo': 'desconexion_local', 
            'razon': 'Error de red inesperado.'
          }));
        }
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  void crearSala(String mapa) {
    _enviar({'accion': 'crear_sala', 'mapa': mapa});
  }

  void unirseSala(String codigo) {
    _enviar({'accion': 'unirse_sala', 'codigo': codigo});
  }

  void iniciarPartida() {
    _enviar({'accion': 'iniciar_partida'});
  }

  void enviarJugada(Map<String, dynamic> datosJugada) {
    datosJugada['accion'] = 'jugada';
    _enviar(datosJugada);
  }

  void reclamarZona(String idZona, int turnoLocal) {
    _enviar({
      'accion': 'reclamar_zona',
      'idZona': idZona,
      'turno': turnoLocal
    });
  }

  void rendirse() {
    _enviar({'accion': 'rendirse'});
    desconectar();
  }

  void _enviar(Map<String, dynamic> datos) {
    if (_canal != null) {
      _canal!.sink.add(jsonEncode(datos));
    }
  }

  void desconectar() {
    _canal?.sink.close();
    _canal = null;
    
    _controladorStream?.close();
    _controladorStream = null;
  }

  void declararListo() {
    _enviar({'accion': 'listo_para_jugar'});
  }

  void tirarDadosGlobales() {
    _enviar({'accion': 'tirar_dados'});
  }

  void terminarTurno() {
    _enviar({'accion': 'terminar_turno'});
  }
}