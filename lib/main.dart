import 'package:flutter/material.dart';
import 'package:jueguito/ui/pantalla_login.dart';

void main() {
  runApp(const MiJuegoApp());
}

class MiJuegoApp extends StatelessWidget {
  const MiJuegoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jueguito 7x7',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const PantallaLogin(),
    );
  }
}