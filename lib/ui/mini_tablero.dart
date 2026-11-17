import 'package:flutter/material.dart';
import 'package:jueguito/capa_zonas.dart';
import 'package:jueguito/ui/tema_juego.dart';

class MiniTablero extends StatelessWidget {
  final List<dynamic> valores;
  final CapaZonas capa;
  final double tamanoCasilla;

  const MiniTablero({super.key, required this.valores, required this.capa, this.tamanoCasilla = 10.0});

  @override
  Widget build(BuildContext context) {
    // Si aún no nos llega el tablero, mostramos un cuadrito gris cargando
    if (valores.isEmpty || valores.length < 49) {
      return Container(
        width: (tamanoCasilla * 7) + 7,
        height: (tamanoCasilla * 7) + 7,
        decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(4)),
        child: const Center(child: Icon(Icons.more_horiz, size: 16, color: Colors.white54)),
      );
    }
    
    return Container(
      width: (tamanoCasilla * 7) + 7, 
      height: (tamanoCasilla * 7) + 7,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54, width: 1.5),
        color: Colors.black,
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemCount: 49,
        itemBuilder: (context, index) {
          int x = index % 7;
          int y = 6 - (index ~/ 7);
          String idZona = capa.obtenerIdZona(x, y);
          dynamic valor = valores[index];

          return Container(
            color: TemaJuego.obtenerColorZona(idZona, 0).withValues(alpha: 0.8),
            child: Center(
              child: valor != null
                  ? Text(
                      valor.toString(),
                      style: TextStyle(
                        fontSize: tamanoCasilla * 0.7, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.black87
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}