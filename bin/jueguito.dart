import 'package:jueguito/jueguito.dart';

void main() {
  print('--- INICIANDO JUEGO EN CONSOLA ---');
  
  var gridData = StatusGridData();
  
  print('\nEstado de las celdas:');
  for (var cell in gridData.cells) {
    print('Número: ${cell.number} | Estado: ${cell.state.name} | Región: ${cell.region.name}');
  }
}