import 'package:flutter/material.dart';
import 'package:jueguito/servicios/servicio_auth.dart';
import 'package:jueguito/ui/pantalla_seleccion_mapas.dart';
import 'package:jueguito/utils/validador_auth.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _controladorUsuario = TextEditingController();
  final _controladorPassword = TextEditingController();
  final _controladorConfirmarPassword = TextEditingController();
  bool _estaRegistrando = false;
  bool _cargando = false;

  @override
  void dispose() {
    _controladorUsuario.dispose();
    _controladorPassword.dispose();
    _controladorConfirmarPassword.dispose();
    super.dispose();
  }

  void _procesarFormulario() async {
    final usuario = _controladorUsuario.text.trim();
    final password = _controladorPassword.text.trim();
    final confirmarPassword = _controladorConfirmarPassword.text.trim();

    // 1. Usar el validador extraído
    if (_estaRegistrando) {
      final error = ValidadorAuth.validarRegistro(usuario, password, confirmarPassword);
      if (error != null) {
        _mostrarError(error);
        return;
      }
    } else {
      // Para login normal, solo checamos que no estén vacíos
      if (usuario.isEmpty || password.isEmpty) {
        _mostrarError('Por favor, llena todos los campos obligatorios.');
        return;
      }
    }

    setState(() => _cargando = true);
    final servicio = ServicioAuth();
    Map<String, dynamic> resultado;

    // 2. Procesar Registro o Login
    if (_estaRegistrando) {
      resultado = await servicio.registrar(usuario, password);
      
      if (resultado['exito'] == true) {
        setState(() {
          _estaRegistrando = false;
          _cargando = false;
          _controladorPassword.clear();
          _controladorConfirmarPassword.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Cuenta creada! Ahora inicia sesión.'), 
              backgroundColor: Colors.green
            ),
          );
        }
        return; 
      }
    } else {
      resultado = await servicio.login(usuario, password);
      
      if (resultado['exito'] == true) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PantallaSeleccionMapas()),
          );
        }
        return; 
      }
    }

    setState(() => _cargando = false);
    _mostrarError(resultado['mensaje']);
  }

  void _mostrarError(String mensaje) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EE), // Crema Brilliant
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'BRILLIANT',
                style: TextStyle(
                  fontSize: 40, 
                  fontWeight: FontWeight.w900, 
                  color: Color(0xFFFF6B00) // Naranja
                ),
              ),
              const SizedBox(height: 40),
              
              TextField(
                controller: _controladorUsuario,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _controladorPassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),

              // Animación simple para mostrar/ocultar el campo de confirmar contraseña
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _estaRegistrando ? 70 : 0,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: TextField(
                    controller: _controladorConfirmarPassword,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              _cargando 
                ? const CircularProgressIndicator(color: Color(0xFFE30059))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0055A4), // Azul profundo
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _procesarFormulario,
                    child: Text(
                      _estaRegistrando ? 'Crear Cuenta' : 'Entrar', 
                      style: const TextStyle(fontSize: 18)
                    ),
                  ),
                  
              TextButton(
                onPressed: () {
                  setState(() {
                    _estaRegistrando = !_estaRegistrando;
                    _controladorConfirmarPassword.clear();
                  });
                },
                child: Text(
                  _estaRegistrando 
                    ? '¿Ya tienes cuenta? Inicia sesión' 
                    : '¿No tienes cuenta? Regístrate',
                  style: const TextStyle(color: Color(0xFFE30059)), // Rosa Brilliant
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}