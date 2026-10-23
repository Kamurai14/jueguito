import 'package:jueguito/capa_zonas.dart';

class MotorReglas {
  
  // ==========================================================
  // 1. VALIDACIÓN DE JUGADAS (El nuevo cerebro del juego)
  // Reemplaza a tu antiguo archivo tipo.dart
  // ==========================================================
  static bool esJugadaValida(String idZona, int numeroAColocar, List<int> numerosActualesEnZona) {
    
    // REGLAS AZUL (AZ) y BLANCO (BL): Todos los números deben ser iguales al primero
    if (idZona.startsWith('AZ') || idZona.startsWith('BL')) {
      if (numerosActualesEnZona.isNotEmpty) {
        return numeroAColocar == numerosActualesEnZona.first;
      }
      return true; // Si está vacía, el primer número siempre entra
    }

    // REGLA MORADA (MO): Solo puede tener un máximo de 2 números diferentes por zona
    if (idZona.startsWith('MO')) {
      // Obtenemos cuántos números "diferentes" hay actualmente en la zona
      Set<int> numerosUnicos = numerosActualesEnZona.toSet();
      
      // Si el número que queremos poner ya existe en la zona, es válido repetirlo
      if (numerosUnicos.contains(numeroAColocar)) {
        return true;
      }
      // Si es un número nuevo, solo lo dejamos entrar si hay menos de 2 números únicos
      return numerosUnicos.length < 2;
    }

    // REGLA NARANJA 1 (NA1): Solo números del 4 al 6 (pueden repetirse)
    if (idZona.startsWith('NA1')) {
      return numeroAColocar >= 4 && numeroAColocar <= 6;
    }

    // REGLA NARANJA 2 (NA2): Solo números del 1 al 3 (pueden repetirse)
    if (idZona.startsWith('NA2')) {
      return numeroAColocar >= 1 && numeroAColocar <= 3;
    }

    // REGLA VERDE (VE): Cualquier número es válido, se pueden repetir sin límite
    if (idZona.startsWith('VE')) {
      return true;
    }

    // REGLAS ROJO (RO) y AMARILLO (AM): Todos los números tienen que ser diferentes
    if (idZona.startsWith('RO') || idZona.startsWith('AM')) {
      if (numerosActualesEnZona.contains(numeroAColocar)) {
        return false; // Si ya se usó, lo bloqueamos
      }
      return true;
    }

    // Regla de seguridad por defecto
    return true; 
  }
  // ==========================================================
  // 2. SISTEMA DE PUNTUACIONES (Preparado para los 4 mapas)
  // ==========================================================
  static int obtenerPuntosPrimeraVez(String idZona, {TipoMapa mapaActual = TipoMapa.mapa1}) {
    
    // Ejemplo de cómo manejaremos los puntos dinámicos que me mencionaste.
    // Cuando el BLoC nos pase que estamos en el Mapa 2, cambiamos los valores:
    if (mapaActual == TipoMapa.mapa2) {
      if (idZona.startsWith('AM')) return 6;
      if (idZona.startsWith('AZ')) return 5;
      // ... iremos llenando el resto después
    } else if (mapaActual == TipoMapa.mapa3) {
      if (idZona.startsWith('AM')) return 7;
    }

    // Puntuaciones por defecto (Mapa 1 y Mapa 4)
    if (idZona.startsWith('AM')) return 8; // Amarilla
    if (idZona.startsWith('AZ')) return 7; // Azul
    if (idZona.startsWith('RO')) return 6; // Roja
    if (idZona.startsWith('MO')) return 6; // Morada
    if (idZona.startsWith('VE')) return 4; // Verde
    
    // Puntuaciones base para los colores nuevos (ajústalas según tu diseño de juego)
    if (idZona.startsWith('BL')) return 5; // Blanca
    if (idZona.startsWith('NA')) return 6; // Naranja

    return 0;
  }
}