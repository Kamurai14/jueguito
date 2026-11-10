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

    // REGLA NARANJA (NA): Arriba (NA1) solo 4-6, Abajo (NA2) solo 1-3
    if (idZona == 'NA1') {
      return numeroAColocar >= 4 && numeroAColocar <= 6;
    }
    if (idZona == 'NA2') {
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
  // 2. SISTEMA DE PUNTUACIONES (Empates y Lugares Dinámicos)
  // ==========================================================
  static int obtenerPuntos(String idZona, int lugar, {TipoMapa mapaActual = TipoMapa.mapa1}) {
    // Si llegan después del 3er lugar, ya no hay puntos
    if (lugar < 1 || lugar > 3) return 0; 
    
    // Función auxiliar para no repetir código (Índice 0 = 1ro, Índice 1 = 2do...)
    int p(int p1, int p2, int p3) => [p1, p2, p3][lugar - 1];
    
    if (idZona.startsWith('AZ')) {
      if (mapaActual == TipoMapa.mapa4) return p(8, 6, 4);
      return p(7, 5, 3);
    }
    
    if (idZona.startsWith('MO')) {
      if (mapaActual == TipoMapa.mapa3 || mapaActual == TipoMapa.mapa4) return p(7, 5, 3);
      return p(6, 4, 2);
    }
    
    if (idZona.startsWith('VE')) {
      if (mapaActual == TipoMapa.mapa3) return p(6, 5, 4);
      if (mapaActual == TipoMapa.mapa4) return p(3, 2, 1);
      return p(4, 3, 2);
    }
    
    if (idZona.startsWith('AM')) {
      if (mapaActual == TipoMapa.mapa2) return p(6, 4, 2);
      if (mapaActual == TipoMapa.mapa3) return p(7, 5, 3);
      return p(8, 6, 4); 
    }
    
    if (idZona.startsWith('RO')) {
      return p(6, 4, 2); // Rojo siempre vale igual
    }
    
    if (idZona.startsWith('BL')) {
      if (mapaActual == TipoMapa.mapa2) return p(3, 2, 1);
      if (mapaActual == TipoMapa.mapa3) return p(8, 6, 4);
      return 0; 
    }
    
    if (idZona.startsWith('NA')) {
      if (mapaActual == TipoMapa.mapa4) return p(6, 4, 3);
      return 0;
    }
    
    return 0;
  }
}