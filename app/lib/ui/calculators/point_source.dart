import 'package:flutter/cupertino.dart';
import 'package:signals/signals_flutter.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:signals_hooks/signals_hooks.dart';
import 'dart:math' as math;

import '../widgets/double_input.dart';
import 'base_calc.dart';

class PointSource extends BaseCalc {
  PointSource({super.key});

  @override
  String get name => 'Point Source';

  @override
  final variants = computed(() {
    return <String, String>{
      'exposureRate1': 'Exposure Rate 1',
      'exposureRate2': 'Exposure Rate 2',
      'distance1': 'Distance 1',
      'distance2': 'Distance 2',
    };
  });

  @override
  final variant = signal('exp_rate_2');

  final exposureRate1 = signal<double?>(null);
  final exposureRate2 = signal<double?>(null);
  final distance1 = signal<double?>(null);
  final distance2 = signal<double?>(null);

  late final nonZeroFinal = computed<double>(() {
    final val = exposureRate2() ?? 0;
    // TODO: work out 0 value for final activity
    // return val.clamp(convertToCuries(ActivityType.pCi, 1), double.infinity);
    return val;
  });

  late final exposureRate1$ = computed<double?>(() {
    if (variant.value != 'exposureRate1') return exposureRate1();

    if (exposureRate2() == null || distance1() == null || distance2() == null) {
      return null;
    }

    final result = (exposureRate2()! * math.pow(distance2()!/ distance1()!, 2));
    return result;
  });

  late final exposureRate2$ = computed<double?>(() {
    if (variant.value != 'exposureRate2') return exposureRate2();

    if (exposureRate1() == null || distance1() == null || distance2() == null) {
      return null;
    }

    final result = (exposureRate1()! * math.pow(distance2()!/ distance1()!, 2));
    return result;
  });

  late final distance1$ = computed<double?>(() {
    if (variant.value != 'distance1') return distance1();

    if (exposureRate2() == null || exposureRate1() == null || distance2() == null) {
      return null;
    }

    final result = math.sqrt((exposureRate2()!/ exposureRate1()!) * math.pow(distance2()!,2));
  
    return result;
  });

  late final distance2$ = computed<double?>(() {
    if (variant.value != 'distance2') return distance2();

    if (exposureRate2() == null || exposureRate1() == null || distance1() == null) {
      return null;
    }

    final result  = math.sqrt((exposureRate1()!/ exposureRate2()!) * math.pow(distance1()!,2));
    return result;
  });

  late final chartData$ = computed(() {
    final results = <({double exposure, double distance})>[];

    final eR1 = exposureRate1$() ?? 0;
    final eR2 = exposureRate2$() ?? 0;
    final d1 = distance1$() ?? 10;
    final d2 = distance2$() ?? 10;

    // initial activity = iA
    results.add((
      exposure: eR1,
      distance: 0,
    ));

    int increments = d1.toInt();
    for (var i = 0; i < increments; i++) {
      double slope(double x) {
        return eR1 * math.pow((d1 / d2),2);
      }

      results.add((
        exposure: slope(i.toDouble()),
        distance: i.toDouble(),
      ));
    }

    // final activity = fA;
    results.add((
      exposure: eR2,
      distance: d2.toDouble(),
    ));

    return results;
  });

  late Computed<Widget> exposureRate1Input = computed(() {
    return DoubleInput(
      key: ValueKey((variant.value, 'exposureRate1')),
      label: 'Exposure Rate 1',
      value: variant.value != 'exposure1' ? exposureRate1 : exposureRate1$,
    );
  });

  late Computed<Widget> exposureRate2Input = computed(() {
    return DoubleInput(
      key: ValueKey((variant.value, 'exposureRate2')),
      label: 'Exposure Rate 2',
      value: variant.value != 'exposure2' ? exposureRate2 : exposureRate2$,
    );
  });

  late Computed<Widget> distance1Input = computed(() {
    return DoubleInput(
      key: ValueKey((variant.value, 'distance1')),
      label: 'Distance 1',
      value: variant.value != 'distance1' ? distance1 : distance1$,
    );
  });

  late Computed<Widget> distance2Input = computed(() {
    return DoubleInput(
      key: ValueKey((variant.value, 'distance2')),
      label: 'Distance 2',
      value: variant.value != 'distance2' ? distance2 : distance2$,
    );
  });

  late Computed<Widget> exposureOverDistance = computed(() => Padding(
        padding: const EdgeInsets.all(8),
        child: ClipRect(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 400,
              maxWidth: double.infinity,
            ),
            child: charts.LineChart(
              [
                charts.Series<({double exposure, double distance}), double>(
                  id: 'Activity over Time',
                  domainFn: (data, _) => data.distance,
                  measureFn: (data, _) => data.exposure,
                  data: chartData$.value,
                ),
              ],
              animate: true,
            ),
          ),
        ),
      ));

  @override
  late Computed<Map<String, List<Widget>>> inputs = computed(() {
    return {
      'exposureRate1': [
        exposureRate2Input(),
        distance1Input(),
        distance2Input(),
      ],
      'exposureRate2': [
        exposureRate1Input(),
        distance1Input(),
        distance2Input(),
      ],
      'distance1': [
        exposureRate1Input(),
        exposureRate2Input(),
        distance2Input(),
      ],
      'distance2': [
        exposureRate1Input(),
        exposureRate2Input(),
        distance1Input(),
      ],
    };
  });

  @override
  late Computed<Map<String, List<Widget>>> outputs = computed(() {
    return {
      'exposureRate1': [
        exposureRate1Input(),
        exposureOverDistance(),
      ],
      'exposureRate2': [
        exposureRate2Input(),
        exposureOverDistance(),
      ],
      'distance1': [
        distance1Input(),
        exposureOverDistance(),
      ],
      'distance2': [
        distance2Input(),
        exposureOverDistance(),
      ],
    };
  });

  @override
  Widget build(BuildContext context) {
    useSignalEffect(() {
      exposureRate1.value = exposureRate1$();
    });
    useSignalEffect(() {
      exposureRate2.value = exposureRate2$();
    });
    useSignalEffect(() {
      distance1.value = distance1$();
    });
    useSignalEffect(() {
      distance2.value = distance2$();
    });
    return super.build(context);
  }
}
