import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

class Grapher extends HookWidget {
  const Grapher({
    super.key,
    required this.name,
    required this.xLabels,
    required this.yLabels,
    required this.width,
    required this.height,
    required this.path,
  });

  final String name;
  final Iterable<String> xLabels;
  final Iterable<String> yLabels;
  final double width;
  final double height;
  final ReadonlySignal<Path> path;

  @override
  Widget build(BuildContext context) {
    final path$ = useExistingSignal(path);
    final xLabels = useMemoized(() => this.xLabels.toList());
    final yLabels = useMemoized(() => this.yLabels.toList());
    return ListTile(
      title: Text(name),
      subtitle: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 400,
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  // left: 50,
                  // top: 50,
                  // right: 50,
                  // bottom: 50,
                  child: CustomPaint(
                    painter: GraphPainter(
                      path$.value,
                      Theme.of(context).colorScheme,
                    ),
                  ),
                ),
                // x axis
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Column(
                    children: [
                      for (var i = xLabels.length - 1; i >= 0; i--)
                        SizedBox(
                          height: height / xLabels.length,
                          child: Container(
                            alignment: Alignment.topLeft,
                            child: Text(xLabels.elementAt(i)),
                          ),
                        ),
                    ],
                  ),
                ),
                // y axis
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      for (var y in yLabels)
                        SizedBox(
                          width: width / yLabels.length,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(y),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final Path path;
  final ColorScheme colors;
  GraphPainter(this.path, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    // clear canvas
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = colors.surface,
    );

    final paint = Paint()
      ..color = colors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
