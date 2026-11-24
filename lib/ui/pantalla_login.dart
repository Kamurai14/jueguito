import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/auth_bloc.dart';
import 'package:jueguito/auth_event.dart';
import 'package:jueguito/servicios/servicio_auth.dart';
import 'package:jueguito/utils/validador_auth.dart';
import 'package:jueguito/ui/fondo_animado_brilliant.dart';

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

  InputDecoration _decoracionCampo({
    required String label,
    required String hint,
    required IconData icono,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      prefixIcon: Icon(icono, color: Colors.white70),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.07),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 2),
      ),
    );
  }

  Widget _buildLogo() {
    Widget cuadrito(Color color) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 8,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            cuadrito(const Color(0xFFFF6B00)),
            const SizedBox(width: 6),
            cuadrito(const Color(0xFFE30059)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            cuadrito(const Color(0xFF00A8E8)),
            const SizedBox(width: 6),
            cuadrito(const Color(0xFF4CAF50)),
          ],
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFB703), Color(0xFFFF6B00), Color(0xFFE30059)],
          ).createShader(bounds),
          child: const Text(
            'BRILLIANT',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _estaRegistrando ? 'Crea tu cuenta de jugador' : 'Inicia sesión para jugar',
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoAnimadoBrilliant(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 32),

                    // Tarjeta del formulario
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16212C).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _controladorUsuario,
                            style: const TextStyle(color: Colors.white),
                            decoration: _decoracionCampo(
                              label: 'Usuario',
                              hint: _estaRegistrando
                                  ? '3-15 letras, números o _ (ej. ivan_24)'
                                  : 'Ingresa tu usuario',
                              icono: Icons.person,
                            ),
                          ),
                          const SizedBox(height: 16),

                          TextField(
                            controller: _controladorPassword,
                            obscureText: _ocultarPassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: _decoracionCampo(
                              label: 'Contraseña',
                              hint: _estaRegistrando
                                  ? 'Mín. 6 caracteres, sin espacios (ej. clave123)'
                                  : 'Ingresa tu contraseña',
                              icono: Icons.lock,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _ocultarPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.white60,
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
                            curve: Curves.easeInOut,
                            height: _estaRegistrando ? 74 : 0,
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: TextField(
                                controller: _controladorConfirmarPassword,
                                obscureText: _ocultarConfirmarPassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: _decoracionCampo(
                                  label: 'Confirmar Contraseña',
                                  hint: 'Repite tu contraseña',
                                  icono: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _ocultarConfirmarPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white60,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _ocultarConfirmarPassword =
                                            !_ocultarConfirmarPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          _cargando
                              ? const CircularProgressIndicator(
                                  color: Color(0xFFFF6B00),
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF6B00),
                                        Color(0xFFE30059),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF6B00)
                                            .withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: _procesarFormulario,
                                    child: Text(
                                      _estaRegistrando ? 'CREAR CUENTA' : 'ENTRAR',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ),

                          const SizedBox(height: 12),

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
                              style: const TextStyle(
                                color: Color(0xFFFFB703),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton.icon(
                      onPressed: () =>
                          context.read<AuthBloc>().add(EntrarComoInvitado()),
                      icon: const Icon(Icons.person_outline, color: Colors.white54),
                      label: const Text(
                        'Jugar como Invitado',
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}