import 'dart:math';
import 'package:flutter/material.dart';

class FondoAnimadoBrilliant extends StatefulWidget {
  final Widget child;

  const FondoAnimadoBrilliant({super.key, required this.child});

  @override
  State<FondoAnimadoBrilliant> createState() => _FondoAnimadoBrilliantState();
}

class _FondoAnimadoBrilliantState extends State<FondoAnimadoBrilliant>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_PiezaFondo> _piezas;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    final rand = Random(42);
    final colores = [
      const Color(0xFFFF6B00), // Naranja Brilliant
      const Color(0xFFE30059), // Rosa Brilliant
      const Color(0xFF00A8E8), // Azul
      const Color(0xFF4CAF50), // Verde
      const Color(0xFF9C27B0), // Morado
      const Color(0xFFFFC107), // Amarillo
    ];

    _piezas = List.generate(18, (i) {
      return _PiezaFondo(
        x: rand.nextDouble(),
        y: rand.nextDouble(),
        tamano: 26.0 + rand.nextDouble() * 44.0,
        velocidad: 0.35 + rand.nextDouble() * 0.65,
        rotacionInicial: rand.nextDouble() * pi * 2,
        direccionRotacion: rand.nextBool() ? 1.0 : -1.0,
        color: colores[i % colores.length],
        opacidad: 0.08 + rand.nextDouble() * 0.12,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Capa 1: Degradado de fondo con profundidad
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.3),
              radius: 1.2,
              colors: [
                Color(0xFF1E2D3D),
                Color(0xFF101820),
                Color(0xFF090D12),
              ],
            ),
          ),
        ),
        // Capa 2: Piezas flotantes animadas
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _PintorPiezasFondo(
                  piezas: _piezas,
                  progreso: _controller.value,
                ),
              );
            },
          ),
        ),
        // Capa 3: Contenido de la pantalla
        widget.child,
      ],
    );
  }
}

class _PiezaFondo {
  final double x;
  final double y;
  final double tamano;
  final double velocidad;
  final double rotacionInicial;
  final double direccionRotacion;
  final Color color;
  final double opacidad;

  _PiezaFondo({
    required this.x,
    required this.y,
    required this.tamano,
    required this.velocidad,
    required this.rotacionInicial,
    required this.direccionRotacion,
    required this.color,
    required this.opacidad,
  });
}

class _PintorPiezasFondo extends CustomPainter {
  final List<_PiezaFondo> piezas;
  final double progreso;

  _PintorPiezasFondo({required this.piezas, required this.progreso});

  @override
  void paint(Canvas canvas, Size size) {
    for (final pieza in piezas) {
      final double dx = pieza.x * size.width;
      // Movimiento continuo hacia arriba con reinicio suave
      final double yNorm = (pieza.y - progreso * pieza.velocidad) % 1.0;
      final double dy = (yNorm < 0 ? yNorm + 1.0 : yNorm) * (size.height + 120) - 60;
      final double angulo =
          pieza.rotacionInicial + (progreso * pi * 2 * pieza.direccionRotacion);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(angulo);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: pieza.tamano,
        height: pieza.tamano,
      );
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

      final paintRelleno = Paint()
        ..color = pieza.color.withValues(alpha: pieza.opacidad)
        ..style = PaintingStyle.fill;

      final paintBorde = Paint()
        ..color = pieza.color.withValues(alpha: pieza.opacidad + 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawRRect(rrect, paintRelleno);
      canvas.drawRRect(rrect, paintBorde);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PintorPiezasFondo oldDelegate) =>
      oldDelegate.progreso != progreso;
}