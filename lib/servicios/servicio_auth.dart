import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServicioAuth {
  final String _baseUrl = 'http://localhost:8080';
  final _almacenamientoSeguro = const FlutterSecureStorage();

  // Función para registrar usuario
  Future<Map<String, dynamic>> registrar(String usuario, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/registro');
      final respuesta = await http.post(
        url,
        body: jsonEncode({'usuario': usuario, 'password': password}),
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
      return {'exito': false, 'mensaje': 'Error de conexión con el servidor'};
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