import 'package:clienterest/yolo/Detection.dart';
import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<Detection> detections;

  BoundingBoxPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    // Obtener los límites de la imagen
    double imageWidth = size.width;
    double imageHeight = size.height;

    detections.forEach((detection) {
      final bbox = detection.bbox;
      double x = bbox['x']!.toDouble();
      double y = bbox['y']!.toDouble();
      double width = bbox['width']!.toDouble();
      double height = bbox['height']!.toDouble();
      final confidence = detection.conf;

      // Verificar y ajustar las coordenadas x e y si están fuera de los límites

      if (x < 0) {
        width += x; // Reducir el ancho del cuadro delimitador
        x = 0; // Establecer x en el límite izquierdo
      }
      if (y < 0) {
        height += y; // Reducir la altura del cuadro delimitador
        y = 0; // Establecer y en el límite superior
      }
      if (x + width > imageWidth) {
        width = imageWidth - x; // Reducir el ancho del cuadro delimitador
      }
      if (y + height > imageHeight) {
        height = imageHeight - y; // Reducir la altura del cuadro delimitador
      }

      // Dibujar el cuadro delimitador con las coordenadas ajustadas
      Rect detectionRect = Rect.fromLTWH(x, y, width, height);

      Paint paint = Paint()..color = Colors.red;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0;
      canvas.drawRect(detectionRect, paint);
      // Ahora, para determinar que es cada detección,
      // pintamos el ID al lado de cada recuadro
      //TODO: Parsear de id a nombre String

      TextSpan span = TextSpan(
        text:
            'ClassID: ${detection.classId}\n Confidence: ${(confidence * 100).toStringAsFixed(2)}%',
        style: const TextStyle(
            color: Colors.black, backgroundColor: Colors.white, fontSize: 12),
      );
      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        // Offset: Representa una posición en un espacio bidimensional
        Offset(
          // Posición X del cuadro delimitador
          x,
          // Posición Y del cuadro delimitador
          y - 20, // Mover el texto un poco arriba
        ),
      );
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
