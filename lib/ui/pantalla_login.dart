import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/auth_bloc.dart';
import 'package:jueguito/auth_event.dart';
import 'package:jueguito/servicios/servicio_auth.dart';
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
  bool _ocultarPassword = true;
  bool _ocultarConfirmarPassword = true;

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

    if (_estaRegistrando) {
      final error = ValidadorAuth.validarRegistro(usuario, password, confirmarPassword);
      if (error != null) {
        _mostrarError(error);
        return;
      }
    } else {
      if (usuario.isEmpty || password.isEmpty) {
        _mostrarError('Por favor, llena todos los campos obligatorios.');
        return;
      }
    }

    final authBloc = context.read<AuthBloc>();
    final mensajero = ScaffoldMessenger.of(context);

    setState(() => _cargando = true);
    final servicio = ServicioAuth();
    Map<String, dynamic> resultado;

    if (_estaRegistrando) {
      resultado = await servicio.registrar(usuario, password);

      if (resultado['exito'] == true) {
        final resultadoLogin = await servicio.login(usuario, password);

        if (resultadoLogin['exito'] == true) {
          mensajero.showSnackBar(
            const SnackBar(
              content: Text('Cuenta creada. Entrando a Brilliant...'),
              backgroundColor: Colors.green,
            ),
          );
          authBloc.add(IniciarSesionEvent(usuario));
          return;
        } else {
          resultado = resultadoLogin;
        }
      }
    } else {
      resultado = await servicio.login(usuario, password);

      if (resultado['exito'] == true) {
        authBloc.add(IniciarSesionEvent(usuario));
        return;
      }
    }

    if (mounted) {
      setState(() => _cargando = false);
      mensajero.showSnackBar(
        SnackBar(
          content: Text(resultado['mensaje'] ?? 'Error desconocido'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      backgroundColor: const Color(0xFFF8F5EE),
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
                  color: Color(0xFFFF6B00),
                ),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _controladorUsuario,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  hintText: _estaRegistrando
                      ? 'Sin espacios, mín. 4 caracteres (ej. ivan_24)'
                      : 'Ingresa tu usuario',
                  hintStyle: const TextStyle(color: Colors.black45, fontSize: 13),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _controladorPassword,
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: _estaRegistrando
                      ? 'Mín. 6 caracteres, sin espacios (ej. clave123)'
                      : 'Ingresa tu contraseña',
                  hintStyle: const TextStyle(color: Colors.black45, fontSize: 13),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _ocultarPassword = !_ocultarPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _estaRegistrando ? 70 : 0,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: TextField(
                    controller: _controladorConfirmarPassword,
                    obscureText: _ocultarConfirmarPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      hintText: 'Repite tu contraseña',
                      hintStyle: const TextStyle(color: Colors.black45, fontSize: 13),
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarConfirmarPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _ocultarConfirmarPassword = !_ocultarConfirmarPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _cargando
                  ? const CircularProgressIndicator(color: Color(0xFFE30059))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0055A4),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _procesarFormulario,
                      child: Text(
                        _estaRegistrando ? 'Crear Cuenta' : 'Entrar',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),

              TextButton(
                onPressed: () {
                  setState(() {
                    _estaRegistrando = !_estaRegistrando;
                    _controladorConfirmarPassword.clear();
                    _ocultarPassword = true;
                    _ocultarConfirmarPassword = true;
                  });
                },
                child: Text(
                  _estaRegistrando
                      ? '¿Ya tienes cuenta? Inicia sesión'
                      : '¿No tienes cuenta? Regístrate',
                  style: const TextStyle(color: Color(0xFFE30059)),
                ),
              ),

              TextButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(EntrarComoInvitado()),
                child: const Text(
                  'Jugar como Invitado',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}