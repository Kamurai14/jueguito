import 'package:flutter/material.dart';

class TemaJuego {
  static Color _obtenerColorBase(String idZona) {
    if (idZona.startsWith('AM')) return Colors.yellowAccent[400]!;
    if (idZona.startsWith('AZ')) return Colors.blue[400]!;
    if (idZona.startsWith('VE')) return Colors.green[400]!;
    if (idZona.startsWith('MO')) return Colors.purple[400]!;
    if (idZona.startsWith('RO')) return Colors.red[400]!;
    if (idZona.startsWith('NA')) return Colors.deepOrange[400]!; 
    if (idZona.startsWith('BL')) return Colors.white;        
    
    return Colors.grey[400]!; // Por defecto
  }

  static Color obtenerColorZona(String idZona, int vecesReclamada) {
    Color colorBase = _obtenerColorBase(idZona);

    // Atenuación progresiva dependiendo del estado global de la zona
    switch (vecesReclamada) {
      case 0:
        return colorBase; // 100% vivo (Nadie ha puntuado)
      case 1:
        return colorBase.withValues(alpha: 0.7); // 1 jugador ya puntuó
      case 2:
        return colorBase.withValues(alpha: 0.4); // 2 jugadores ya puntuaron
      case 3:
      default:
        return colorBase.withValues(alpha: 0.15); // Agotada (3 o más)
    }
  }
}