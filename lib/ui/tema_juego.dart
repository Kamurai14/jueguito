import 'package:flutter/material.dart';

class TemaJuego {
  static Color obtenerColorZona(String idZona) {
    if (idZona.startsWith('AM')) return Colors.amber[400]!;
    if (idZona.startsWith('AZ')) return Colors.blue[400]!;
    if (idZona.startsWith('VE')) return Colors.green[400]!;
    if (idZona.startsWith('MO')) return Colors.purple[400]!;
    if (idZona.startsWith('RO')) return Colors.red[400]!;
    
    return Colors.grey[400]!; 
  }
}