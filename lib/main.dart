import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jueguito/auth_bloc.dart';
import 'package:jueguito/auth_event.dart';
import 'package:jueguito/auth_state.dart';
import 'package:jueguito/ui/pantalla_carga.dart';
import 'package:jueguito/ui/pantalla_login.dart';
import 'package:jueguito/ui/pantalla_seleccion_mapas.dart';

void main() {
  runApp(
    // Inyectamos el AuthBloc desde la raíz de la app
    BlocProvider(
      create: (context) => AuthBloc()..add(VerificarSesion()),
      child: const MiJuegoApp(),
    ),
  );
}

class MiJuegoApp extends StatelessWidget {
  const MiJuegoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jueguito 7x7',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      // BlocBuilder escucha los cambios de sesión y redibuja toda la app
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthInicial) {
            return const PantallaCarga(); // Muestra el logo mientras revisa el token
          } else if (state is AuthAutenticado || state is AuthInvitado) {
            return const PantallaSeleccionMapas(); // Va directo al juego
          } else {
            return const PantallaLogin(); // Va al login
          }
        },
      ),
    );
  }
}