import 'package:flutter/material.dart';
import 'package:jueguito/servicios/servicio_auth.dart';
import 'package:jueguito/ui/pantalla_login.dart';
import 'package:jueguito/ui/pantalla_seleccion_mapas.dart';

class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key});

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  void _verificarSesion() async {
    // Le damos un pequeño delay solo para que la animación de carga se vea fluida
    await Future.delayed(const Duration(milliseconds: 800));
    
    final tieneSesion = await ServicioAuth().tieneSesionActiva();

    if (!mounted) return;

    if (tieneSesion) {
      // Si ya hay token, va directo a los mapas
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaSeleccionMapas()),
      );
    } else {
      // Si no hay token, lo mandamos al Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaLogin()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el mismo color "cremita" de la caja del juego
    return const Scaffold(
      backgroundColor: Color(0xFFF8F5EE),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'BRILLIANT',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF6B00), // Naranja Brilliant
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Color(0xFFE30059)), // Rosa Brilliant
          ],
        ),
      ),
    );
  }
}