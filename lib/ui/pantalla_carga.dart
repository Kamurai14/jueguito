import 'package:flutter/material.dart';

class PantallaCarga extends StatelessWidget {
  const PantallaCarga({super.key});

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