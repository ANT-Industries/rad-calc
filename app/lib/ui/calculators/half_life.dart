import 'package:flutter/cupertino.dart';
import 'package:signals/signals_flutter.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:signals_hooks/signals_hooks.dart';
import 'dart:math' as math;

import '../widgets/activity_input.dart';
import '../widgets/double_input.dart';
import 'base_calc.dart';

class HalfLife extends BaseCalc {
  HalfLife({super.key});

  @override
  String get name => 'Half Life';

  @override
  final variants = computed(() {
    return <String, String>{
      'initial': 'Initial Activity',
      'final': 'Final Activity',
      'half': 'Half Life',
      'time': 'Time',
    };
  });

  @override
  final variant = signal('final');

  final initialActivity = signal<double?>(null);
  final finalActivity = signal<double?>(null);
  final halfLife = signal<double?>(null);
  final time = signal<double?>(null);

  late final nonZeroFinal = computed<double>(() {
    final val = finalActivity() ?? 0;
    // TODO: work out 0 value for final activity
    // return val.clamp(convertToCuries(ActivityType.pCi, 1), double.infinity);
    return val;
  });

  late final initialActivity$ = computed<double?>(() {
    if (variant.value != 'initial') return initialActivity();

    if (halfLife() == null || time() == null || finalActivity() == null) {
      return null;
    }

    final result = nonZeroFinal() *
        math.pow(
          math.e,
          (math.ln2 / halfLife()!) * time()!,
        );
    // initialActivity.value = result;
    return result;
  });

  late final finalActivity$ = computed<double?>(() {
    if (variant.value != 'final') return finalActivity();

    if (halfLife() == null || time() == null || initialActivity() == null) {
      return null;
    }
    final result = initialActivity()! *
        math.pow(
          math.e,
          ((math.ln2 / halfLife()!) * time()!) * -1,
        );
    // finalActivity.value = result;
    return result;
  });

  late final halfLife$ = computed<double?>(() {
    if (variant.value != 'half') return halfLife();

    if (initialActivity() == null ||
        finalActivity() == null ||
        time() == null) {
      return null;
    }
    final result = (time()! * math.ln2) /
        math.log(
          initialActivity()! / nonZeroFinal(),
        );
    // halfLife.value = result;
    return result;
  });

  late final time$ = computed<double?>(() {
    if (variant.value != 'time') return time();

    if (initialActivity() == null ||
        finalActivity() == null ||
        halfLife() == null) {
      return null;
    }

    final result = (math.log(
          nonZeroFinal() / initialActivity()!,
        )) /
        ((math.ln2 / halfLife()!) * -1);
    // time.value = result;
    return result;
  });

  late final chartData$ = computed(() {
    final results = <({double activity, double time})>[];

    final iA = initialActivity$() ?? 0;
    final fA = finalActivity$() ?? 0;
    final hL = halfLife$() ?? 10;
    final t = time$() ?? 10;

    // initial activity = iA
    results.add((
      activity: iA,
      time: 0,
    ));

    int increments = t.toInt();
    for (var i = 0; i < increments; i++) {
      double slope(double x) {
        return iA *
            math.pow(
              math.e,
              ((math.ln2 / hL) * x) * -1,
            );
      }

      results.add((
        activity: slope(i.toDouble()),
        time: i.toDouble(),
      ));
    }

    // final activity = fA;
    results.add((
      activity: fA,
      time: t.toDouble(),
    ));

    return results;
  });

  late Computed<Widget> initialActivityInput = computed(() {
    return ActivityInput(
      key: ValueKey((variant.value, 'initial')),
      label: 'Initial Activity',
      value: variant.value != 'initial' ? initialActivity : initialActivity$,
    );
  });

  late Computed<Widget> finalActivityInput = computed(() {
    return ActivityInput(
      key: ValueKey((variant.value, 'final')),
      label: 'Final Activity',
      value: variant.value != 'final' ? finalActivity : finalActivity$,
    );
  });

  late Computed<Widget> halfLifeInput = computed(() {
    return DoubleInput(
      key: ValueKey((variant.value, 'half')),
      label: 'Half Life',
      value: variant.value != 'half' ? halfLife : halfLife$,
    );
  });

  late Computed<Widget> timeInput = computed(() {
    return DoubleInput(
      key: ValueKey((variant.value, 'time')),
      label: 'Time',
      value: variant.value != 'time' ? time : time$,
    );
  });

  late Computed<Widget> activityOverTime = computed(() => Padding(
        padding: const EdgeInsets.all(8),
        child: ClipRect(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 400,
              maxWidth: double.infinity,
            ),
            child: charts.LineChart(
              [
                charts.Series<({double activity, double time}), double>(
                  id: 'Activity over Time',
                  domainFn: (data, _) => data.time,
                  measureFn: (data, _) => data.activity,
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
      'initial': [
        finalActivityInput(),
        halfLifeInput(),
        timeInput(),
      ],
      'final': [
        initialActivityInput(),
        halfLifeInput(),
        timeInput(),
      ],
      'half': [
        initialActivityInput(),
        finalActivityInput(),
        timeInput(),
      ],
      'time': [
        initialActivityInput(),
        finalActivityInput(),
        halfLifeInput(),
      ],
    };
  });

  @override
  late Computed<Map<String, List<Widget>>> outputs = computed(() {
    return {
      'initial': [
        initialActivityInput(),
        activityOverTime(),
      ],
      'final': [
        finalActivityInput(),
        activityOverTime(),
      ],
      'half': [
        halfLifeInput(),
        activityOverTime(),
      ],
      'time': [
        timeInput(),
        activityOverTime(),
      ],
    };
  });

  @override
  Widget build(BuildContext context) {
    useSignalEffect(() {
      initialActivity.value = initialActivity$();
    });
    useSignalEffect(() {
      finalActivity.value = finalActivity$();
    });
    useSignalEffect(() {
      halfLife.value = halfLife$();
    });
    useSignalEffect(() {
      time.value = time$();
    });
    return super.build(context);
  }
}
