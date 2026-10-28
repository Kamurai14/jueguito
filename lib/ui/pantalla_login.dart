import 'package:flutter/material.dart';
import 'package:jueguito/servicios/servicio_auth.dart';
// Asegúrate de importar la pantalla de selección de mapas para navegar hacia allá
import 'pantalla_seleccion_mapas.dart'; 

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  // Paleta de colores extraída de la portada del juego "Brilliant"
  final Color colorFondoCrema = const Color(0xFFF8F5EE);
  final Color colorRosaBrilliant = const Color(0xFFE30059);
  final Color colorNaranjaBrilliant = const Color(0xFFFF6B00);
  final Color colorAzulFuerte = const Color(0xFF0055A4);

  final TextEditingController _controladorUsuario = TextEditingController();
  final TextEditingController _controladorPassword = TextEditingController();
  
  bool _estaRegistrando = false;
  bool _cargando = false;

  void _procesarFormulario() async {
    // 1. Validar que no envíen campos vacíos
    final usuario = _controladorUsuario.text.trim();
    final password = _controladorPassword.text.trim();

    if (usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos')),
      );
      return;
    }

    setState(() => _cargando = true);
    
    final servicio = ServicioAuth();
    Map<String, dynamic> resultado;

    // 2. Decidir si registramos o iniciamos sesión
    if (_estaRegistrando) {
      resultado = await servicio.registrar(usuario, password);
      
      if (resultado['exito'] == true) {
        // Si se registra bien, lo pasamos al modo login automáticamente
        setState(() {
          _estaRegistrando = false;
          _cargando = false;
          _controladorPassword.clear(); // Limpiamos contraseña por seguridad
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Cuenta creada! Ahora inicia sesión.'), backgroundColor: Colors.green),
          );
        }
        return; 
      }
    } else {
      resultado = await servicio.login(usuario, password);
      
      if (resultado['exito'] == true) {
        print('Token recibido y validado: ${resultado['token']}');
        // Si el login es exitoso, ¡vamos al menú de mapas!
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaSeleccionMapas()),
          );
        }
        return; 
      }
    }

    // 3. Si hubo algún error (ya sea en login o registro), lo mostramos en pantalla
    setState(() => _cargando = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado['mensaje']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondoCrema, // <-- El fondo cremita relajante
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título con el estilo y color de la caja
                Text(
                  'BRILLIANT',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: colorNaranjaBrilliant,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(color: colorRosaBrilliant.withOpacity(0.5), offset: const Offset(2, 2), blurRadius: 4)
                    ]
                  ),
                ),
                Text(
                  '7x7 PUZZLE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorAzulFuerte,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 50),

                // Campo de Usuario
                TextField(
                  controller: _controladorUsuario,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    labelStyle: TextStyle(color: colorAzulFuerte),
                    filled: true,
                    fillColor: Colors.white, // Fondo blanco puro para que resalte sobre el crema
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.person, color: colorRosaBrilliant),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Contraseña
                TextField(
                  controller: _controladorPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: colorAzulFuerte),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.lock, color: colorRosaBrilliant),
                  ),
                ),
                const SizedBox(height: 32),

                // Botón Principal
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorAzulFuerte, // Contraste azul oscuro de la caja
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: _cargando ? null : _procesarFormulario,
                    child: _cargando 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _estaRegistrando ? 'CREAR CUENTA' : 'ENTRAR',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón para cambiar entre Login y Registro
                TextButton(
                  onPressed: () {
                    setState(() {
                      _estaRegistrando = !_estaRegistrando;
                    });
                  },
                  child: Text(
                    _estaRegistrando 
                        ? '¿Ya tienes cuenta? Inicia sesión aquí' 
                        : '¿No tienes cuenta? Regístrate gratis',
                    style: TextStyle(color: colorRosaBrilliant, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}