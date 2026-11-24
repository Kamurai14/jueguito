import 'package:flutter/material.dart';

class PantallaReglas extends StatelessWidget {
  const PantallaReglas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, color: Color(0xFF4CAF50), size: 22),
            SizedBox(width: 8),
            Text(
              'Cómo jugar Brilliant',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.4),
            radius: 1.3,
            colors: [
              Color(0xFF0D2B22),
              Color(0xFF081713),
              Color(0xFF050C0A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                children: [
                  _buildTarjetaSeccion(
                    numero: '01',
                    titulo: 'Objetivo del Juego',
                    icono: Icons.flag_rounded,
                    colorAcento: const Color(0xFF4CAF50),
                    contenido:
                        'El objetivo es obtener la mayor cantidad de puntos llenando las zonas de color de tu tablero. '
                        'Quien llene una zona primero obtiene la puntuación máxima de esa zona. Los siguientes jugadores en llenarla obtendrán menos puntos.',
                  ),
                  const SizedBox(height: 14),
                  _buildTarjetaSeccion(
                    numero: '02',
                    titulo: 'Preparación (Fase Inicial)',
                    icono: Icons.grid_on_rounded,
                    colorAcento: const Color(0xFF00A8E8),
                    contenido:
                        'Antes de comenzar a tirar los dados, cada jugador debe colocar 6 números iniciales en las casillas marcadas '
                        'en su tablero. Estos números servirán como "anclas" o puntos de partida para el resto de la partida.',
                  ),
                  const SizedBox(height: 14),
                  _buildTarjetaSeccion(
                    numero: '03',
                    titulo: 'Desarrollo del Turno',
                    icono: Icons.casino_rounded,
                    colorAcento: const Color(0xFFFFB703),
                    contenido:
                        'En cada turno, el servidor tira dos dados de 6 caras. Todos los jugadores usarán esos mismos dos números.\n\n'
                        'Debes colocar ambos números en tu tablero siguiendo la regla de colocación. Si no puedes colocar un número, pierdes ese dado en este turno.',
                  ),
                  const SizedBox(height: 14),
                  _buildTarjetaSeccion(
                    numero: '04',
                    titulo: 'Reglas de Colocación',
                    icono: Icons.ads_click_rounded,
                    colorAcento: const Color(0xFFE30059),
                    contenido:
                        'Todo número nuevo que coloques en el tablero debe ir obligatoriamente en una casilla vacía que esté '
                        'adyacente a un número que ya esté colocado en el tablero.',
                  ),
                  const SizedBox(height: 14),
                  _buildTarjetaZonas(),
                  const SizedBox(height: 14),
                  _buildTarjetaSeccion(
                    numero: '06',
                    titulo: 'Fin de la Partida',
                    icono: Icons.sports_score_rounded,
                    colorAcento: const Color(0xFFFF6B00),
                    contenido:
                        'La partida termina cuando un jugador alcanza el límite de puntos establecido (dependiendo de la cantidad de jugadores) '
                        'o cuando se agota el número máximo de turnos de supervivencia. El jugador con más puntos al finalizar es el ganador.',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTarjetaSeccion({
    required String numero,
    required String titulo,
    required IconData icono,
    required Color colorAcento,
    required String contenido,
  }) {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorAcento.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorAcento.withValues(alpha: 0.4)),
                ),
                child: Icon(icono, color: colorAcento, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REGLA $numero',
                      style: TextStyle(
                        color: colorAcento,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            contenido,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14.5,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaZonas() {
    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.format_color_fill_rounded, color: Colors.purpleAccent, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REGLA 05',
                      style: TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Restricciones de Zonas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Para que una zona se considere válida y otorgue puntos, debe cumplir con su regla matemática específica:',
            style: TextStyle(color: Colors.white70, fontSize: 14.5, height: 1.5),
          ),
          const SizedBox(height: 16),
          _buildFilaReglaZona(
            '=',
            'Iguales',
            'Todos los números en esta zona deben ser exactamente el mismo.',
            Colors.blue[400]!,
          ),
          _buildFilaReglaZona(
            '≠',
            'Diferentes',
            'No puede haber números repetidos dentro de esta zona.',
            Colors.red[400]!,
          ),
          _buildFilaReglaZona(
            '?',
            'Libre',
            'Puedes colocar cualquier número, sin restricciones.',
            Colors.green[400]!,
          ),
          _buildFilaReglaZona(
            'XO',
            'Máximo 2',
            'Un número no puede repetirse más de 2 veces en esta zona.',
            Colors.purple[400]!,
          ),
        ],
      ),
    );
  }

  Widget _buildFilaReglaZona(
    String simbolo,
    String titulo,
    String descripcion,
    Color colorSimbolo,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorSimbolo.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorSimbolo, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              simbolo,
              style: TextStyle(
                color: colorSimbolo,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descripcion,
                  style: const TextStyle(color: Colors.white70, fontSize: 13.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}