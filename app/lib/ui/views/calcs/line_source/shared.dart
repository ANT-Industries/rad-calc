import 'package:signals/signals_flutter.dart';
//import 'dart:math' as math;

List<({double x, double y})> buildChartData({
  required ReadonlySignal<double> exposureRate1,
  required ReadonlySignal<double> exposureRate2,
  required ReadonlySignal<double> distance1,
  required ReadonlySignal<double> distance2,
}) {
  final results = <({double x, double y})>[];

  final er1 = exposureRate1();
  final er2 = exposureRate2();
  final d1 = distance1();
  final d2 = distance2();

  results.add((
    y: er1,
    x: d1,
  ));

  int increments = (d1.isNaN || d1.isInfinite) ? 0 : d1.toInt();
  for (var i = 0; i < increments; i++) {
    double slope(double x) {
      return (er2 - er1) / (d2 - d1) * (x - d1) + er1;
    }

    results.add((
      y: slope(i.toDouble()),
      x: i.toDouble(),
    ));
  }

  results.add((
    y: er2,
    x: d2.toDouble(),
  ));

  return results;
}
