import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServicioMultiplayer {
  WebSocketChannel? _canal;
  final bool _esProduccion = false;
  final _almacenamientoSeguro = const FlutterSecureStorage();

  // URL dinámica para WebSockets (ws:// en lugar de http://)
  String get _wsUrl {
    if (_esProduccion) return 'wss://api.tujuego.com/ws';
    if (!kIsWeb && Platform.isAndroid) return 'ws://10.0.2.2:8080/ws';
    return 'ws://127.0.0.1:8080/ws';
  }

  // Stream expuesto para que la UI reaccione instantáneamente
  Stream<dynamic>? get streamMensajes => _canal?.stream;

  Future<bool> conectar() async {
    try {
      final token = await _almacenamientoSeguro.read(key: 'jwt_token');
      if (token == null) return false;

      final urlFinal = Uri.parse('$_wsUrl?token=$token');
      _canal = WebSocketChannel.connect(urlFinal);
      return true;
    } catch (e) {
      return false;
    }
  }

  void crearSala() {
    _enviar({'accion': 'crear_sala'});
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
  }
}