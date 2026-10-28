import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicioAuth {
  // ATENCIÓN: Si pruebas en Web o Windows usa 'localhost'. 
  // Si pruebas en un emulador de Android, usa '10.0.2.2' en lugar de 'localhost'.
  final String _baseUrl = 'http://localhost:8080';

  Future<void> probarConexion() async {
    try {
      print('Intentando conectar con el servidor...');
      final url = Uri.parse('$_baseUrl/login');
      
      // Hacemos la petición POST a nuestra ruta de prueba
      final respuesta = await http.post(url);

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body);
        print('✅ ¡Conexión exitosa!');
        print('Mensaje: ${datos['mensaje']}');
        print('Token JWT: ${datos['token']}');
      } else {
        print('❌ Error del servidor: Código ${respuesta.statusCode}');
      }
    } catch (e) {
      print('❌ Error de conexión: ¿El servidor está corriendo? Detalles: $e');
    }
  }
}