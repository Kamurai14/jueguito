import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicioAuth {
  final String _baseUrl = 'http://localhost:8080';

  // 1. Función para registrar usuario
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

  // 2. Función para iniciar sesión
  Future<Map<String, dynamic>> login(String usuario, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/login');
      final respuesta = await http.post(
        url,
        body: jsonEncode({'usuario': usuario, 'password': password}),
      );
      
      final datos = jsonDecode(respuesta.body);
      
      if (respuesta.statusCode == 200) {
        return {'exito': true, 'token': datos['token']};
      } else {
        return {'exito': false, 'mensaje': datos['error'] ?? 'Credenciales inválidas'};
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión con el servidor'};
    }
  }
}