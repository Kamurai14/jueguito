import 'package:flutter/material.dart';

class PantallaReglas extends StatelessWidget {
  const PantallaReglas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Cómo jugar Brilliant'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTarjetaSeccion(
            titulo: '1. Objetivo del Juego',
            icono: Icons.flag,
            contenido: 'El objetivo es obtener la mayor cantidad de puntos llenando las zonas de color de tu tablero. '
                'Quien llene una zona primero obtiene la puntuación máxima de esa zona. Los siguientes jugadores en llenarla obtendrán menos puntos.',
          ),
          const SizedBox(height: 12),
          _buildTarjetaSeccion(
            titulo: '2. Preparación (Fase Inicial)',
            icono: Icons.grid_on,
            contenido: 'Antes de comenzar a tirar los dados, cada jugador debe colocar 6 números iniciales en las casillas marcadas '
                'en su tablero. Estos números servirán como "anclas" o puntos de partida para el resto de la partida.',
          ),
          const SizedBox(height: 12),
          _buildTarjetaSeccion(
            titulo: '3. Desarrollo del Turno',
            icono: Icons.casino,
            contenido: 'En cada turno, el servidor tira dos dados de 6 caras. Todos los jugadores usarán esos mismos dos números.\n\n'
                'Debes colocar ambos números en tu tablero siguiendo la regla de colocación. Si no puedes colocar un número, pierdes ese dado en este turno.',
          ),
          const SizedBox(height: 12),
          _buildTarjetaSeccion(
            titulo: '4. Reglas de Colocación',
            icono: Icons.ads_click,
            contenido: 'Todo número nuevo que coloques en el tablero debe ir obligatoriamente en una casilla vacía que esté '
                'adyacente (ortogonal o diagonalmente) a un número que ya esté colocado en el tablero.',
          ),
          const SizedBox(height: 12),
          _buildTarjetaZonas(),
          const SizedBox(height: 12),
          _buildTarjetaSeccion(
            titulo: '6. Fin de la Partida',
            icono: Icons.sports_score,
            contenido: 'La partida termina cuando un jugador alcanza el límite de puntos establecido (dependiendo de la cantidad de jugadores) '
                'o cuando se agota el número máximo de turnos de supervivencia. El jugador con más puntos al finalizar es el ganador.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTarjetaSeccion({required String titulo, required IconData icono, required String contenido}) {
    return Card(
      color: Colors.blueGrey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              contenido,
              style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarjetaZonas() {
    return Card(
      color: Colors.blueGrey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.format_color_fill, color: Colors.amber, size: 28),
                SizedBox(width: 12),
                Text(
                  '5. Restricciones de Zonas',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Para que una zona se considere válida y otorgue puntos, debe cumplir con su regla matemática específica:',
              style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 16),
            _buildFilaReglaZona('=', 'Iguales', 'Todos los números en esta zona deben ser exactamente el mismo.'),
            _buildFilaReglaZona('≠', 'Diferentes', 'No puede haber números repetidos dentro de esta zona.'),
            _buildFilaReglaZona('?', 'Libre', 'Puedes colocar cualquier número, sin restricciones.'),
            _buildFilaReglaZona('XO', 'Máximo 2', 'Un número no puede repetirse más de 2 veces en esta zona.'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilaReglaZona(String simbolo, String titulo, String descripcion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blueGrey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white30),
            ),
            alignment: Alignment.center,
            child: Text(
              simbolo,
              style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(descripcion, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}