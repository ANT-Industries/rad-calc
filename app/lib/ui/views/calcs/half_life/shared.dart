import 'package:signals/signals_flutter.dart';
import 'dart:math' as math;

List<({double x, double y})> buildChartData({
  required ReadonlySignal<double> initialActivity,
  required ReadonlySignal<double> finalActivity,
  required ReadonlySignal<double> halfLife,
  required ReadonlySignal<double> time,
}) {
  final results = <({double x, double y})>[];

  final iA = initialActivity();
  final fA = finalActivity();
  final hL = halfLife();
  final t = time();

  results.add((
    y: iA,
    x: 0,
  ));

  int increments = (t.isNaN || t.isInfinite) ? 0 : t.toInt();
  for (var i = 0; i < increments; i++) {
    double slope(double x) {
      return iA *
          math.pow(
            math.e,
            ((math.ln2 / hL) * x) * -1,
          );
    }

    results.add((
      y: slope(i.toDouble()),
      x: i.toDouble(),
    ));
  }

  results.add((
    y: fA,
    x: t.toDouble(),
  ));

  return results;
}
