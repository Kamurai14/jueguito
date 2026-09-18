import 'package:jueguito/region.dart';
import 'package:jueguito/tipo.dart';

class CapaZonas {
  final int tamano = 7;
  late final Map<String, ZonaJuego> _zonas;
  late final List<List<String>> _mapa;

  CapaZonas() {
    _inicializarZonas();
    _definirMapa();
  }

  void _inicializarZonas() {
    _zonas = {
      'AM': const ZonaJuego('AM', TipoAmarillo()),
      'AZ1': const ZonaJuego('AZ1', TipoAzul()),
      'AZ2': const ZonaJuego('AZ2', TipoAzul()),
      'VE1': const ZonaJuego('VE1', TipoVerde()),
      'VE2': const ZonaJuego('VE2', TipoVerde()),
      'MO1': const ZonaJuego('MO1', TipoMorado()),
      'MO2': const ZonaJuego('MO2', TipoMorado()),
      'RO1': const ZonaJuego('RO1', TipoRojo()),
      'RO2': const ZonaJuego('RO2', TipoRojo()),
    };
  }

  void _definirMapa() {
    // La plantilla que se superpone al tablero de 7x7
    _mapa = [
      ['AM', 'VE1', 'AZ1', 'MO1', 'MO1', 'MO1', 'AM'], // Y = 6
      ['VE1', 'VE1', 'AZ1', 'AZ1', 'MO1', 'MO1', 'VE2'], // Y = 5
      ['VE1', 'RO1', 'RO1', 'AZ1', 'MO1', 'VE2', 'VE2'], // Y = 4
      ['VE1', 'RO1', 'MO2', 'AM', 'VE2', 'VE2', 'VE2'], // Y = 3
      ['VE1', 'RO1', 'MO2', 'MO2', 'RO2', 'RO2', 'AZ2'], // Y = 2
      ['RO1', 'RO1', 'MO2', 'RO2', 'RO2', 'AZ2', 'AZ2'], // Y = 1
      ['AM', 'MO2', 'MO2', 'RO2', 'RO2', 'AZ2', 'AM'], // Y = 0
    ];
  }

  ZonaJuego obtenerZonaEn(Coordenada c) {
    int matrizY = (tamano - 1) - c.y;
    int matrizX = c.x;
    
    String idZona = _mapa[matrizY][matrizX];
    return _zonas[idZona]!;
  }
}