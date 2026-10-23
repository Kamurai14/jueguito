import 'package:flutter/material.dart';

class TemaJuego {
  static Color obtenerColorZona(String idZona) {
    if (idZona.startsWith('AM')) return Colors.yellowAccent[400]!;
    if (idZona.startsWith('AZ')) return Colors.blue[400]!;
    if (idZona.startsWith('VE')) return Colors.green[400]!;
    if (idZona.startsWith('MO')) return Colors.purple[400]!;
    if (idZona.startsWith('RO')) return Colors.red[400]!;
    
    // ==========================================
    // LOS NUEVOS COLORES PARA LOS MAPAS 2, 3 Y 4
    // ==========================================
    if (idZona.startsWith('NA')) return Colors.deepOrange[400]!; // Naranja
    if (idZona.startsWith('BL')) return Colors.white;        // Blanco
    
    return Colors.grey[400]!; // Color por defecto si algo falla
  }
}