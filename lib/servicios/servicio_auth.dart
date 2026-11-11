import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ServicioAuth {
 final bool _esProduccion = true; 
  
  // URL dinámica para que funcione tanto en Windows como en el Emulador Android
  String get _baseUrl {
    if (_esProduccion) return 'https://servidor-jueguito-brilliant.onrender.com';
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8080'; // Ruta especial para emulador
    return 'http://127.0.0.1:8080'; // Ruta para escritorio Windows
  }

  final _almacenamientoSeguro = const FlutterSecureStorage();

  // Función para registrar usuario
  Future<Map<String, dynamic>> registrar(String usuario, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/registro');
      final respuesta = await http.post(
        url,
        body: jsonEncode({'usuario': usuario, 'password': password}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('El servidor tardó demasiado en responder'),
      );
      
      final datos = jsonDecode(respuesta.body);
      
      if (respuesta.statusCode == 200) {
        return {'exito': true, 'mensaje': datos['mensaje']};
      } else {
        return {'exito': false, 'mensaje': datos['error'] ?? 'Error desconocido'};
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión con el servidor'};
    }
  }

  // Función para iniciar sesión y GUARDAR el token
  Future<Map<String, dynamic>> login(String usuario, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/login');
      final respuesta = await http.post(
        url,
        body: jsonEncode({'usuario': usuario, 'password': password}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('El servidor tardó demasiado en responder'),
      );
      
      final datos = jsonDecode(respuesta.body);
      
      if (respuesta.statusCode == 200) {
        // ¡Aquí guardamos el token de forma encriptada en el dispositivo!
        await _almacenamientoSeguro.write(key: 'jwt_token', value: datos['token']);
        await _almacenamientoSeguro.write(key: 'usuario_actual', value: usuario);
        return {'exito': true, 'token': datos['token']};
      } else {
        return {'exito': false, 'mensaje': datos['error'] ?? 'Credenciales inválidas'};
      }
    } catch (e) {
      print('=== ERROR EN FLUTTER ===');
      print(e);
      return {'exito': false, 'mensaje': 'Fallo interno: $e'};
    }
  }

  // Verifica si hay un token guardado en el teléfono
  Future<bool> tieneSesionActiva() async {
    String? token = await _almacenamientoSeguro.read(key: 'jwt_token');
    return token != null;
  }

  // Borra el token (Para el botón de Cerrar Sesión)
  Future<void> cerrarSesion() async {
    await _almacenamientoSeguro.delete(key: 'jwt_token');
    await _almacenamientoSeguro.delete(key: 'usuario_actual');
  }

  // Pide al servidor borrar la cuenta usando el token de sesión
  Future<Map<String, dynamic>> borrarCuenta() async {
    try {
      String? token = await _almacenamientoSeguro.read(key: 'jwt_token');
      if (token == null) return {'exito': false, 'mensaje': 'No hay sesión activa'};

      final url = Uri.parse('$_baseUrl/borrar-cuenta');
      final respuesta = await http.delete(
        url,
        // Aquí le enviamos el token al servidor como si fuera un "gafete" de identidad
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('El servidor tardó demasiado en responder'),
      );
      
      if (respuesta.statusCode == 200) {
        await cerrarSesion(); // Si se borró en el server, borramos el token del celular
        return {'exito': true};
      } else {
        final datos = jsonDecode(respuesta.body);
        return {'exito': false, 'mensaje': datos['error'] ?? 'Error al borrar cuenta'};
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión con el servidor'};
    }
  }

  Future<String?> obtenerUsuarioActual() async {
  return await _almacenamientoSeguro.read(key: 'usuario_actual');
}
  
}