class MotorReglas {
  
  static int obtenerPuntosPrimeraVez(String idZona) {
    if (idZona.startsWith('AM')) return 8; // Amarilla
    if (idZona.startsWith('AZ')) return 7; // Azul
    if (idZona.startsWith('RO')) return 6; // Roja
    if (idZona.startsWith('MO')) return 6; // Morada
    if (idZona.startsWith('VE')) return 4; // Verde
    return 0;
  }
  
}