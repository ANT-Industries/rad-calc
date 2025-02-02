import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals_hooks/signals_hooks.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;

import 'dart:math' as math;

import '../widgets/activity_input.dart';
import '../widgets/double_input.dart';
import 'base_calc.dart';

class HalfLife extends BaseCalc {
  const HalfLife({super.key});

  @override
  String get name => 'Half Life';

  @override
  Widget build(BuildContext context) {
    final options = useSignal(<String, String>{
      'initial': 'Initial Activity',
      'final': 'Final Activity',
      'half': 'Half Life',
      'time': 'Time',
    });
    final selected = useSignal('final');
    final formKey = useMemoized(() => GlobalKey<FormState>());

    useSignalEffect(() {
      selected.value;
      formKey.currentState?.reset();
    });

    final initialActivity = useSignal<double?>(null);
    final finalActivity = useSignal<double?>(null);
    final halfLife = useSignal<double?>(null);
    final time = useSignal<double?>(null);

    final initialActivity$ = useComputed<double?>(() {
      if (selected.value != 'initial') return initialActivity();

      if (halfLife() == null || time() == null || finalActivity() == null) {
        return null;
      }
      return finalActivity()! *
          math.pow(
            math.e,
            (math.ln2 / halfLife()!) * time()!,
          );
    });

    final finalActivity$ = useComputed<double?>(() {
      if (selected.value != 'final') return finalActivity();

      if (halfLife() == null || time() == null || initialActivity() == null) {
        return null;
      }
      return initialActivity()! *
          math.pow(
            math.e,
            ((math.ln2 / halfLife()!) * time()!) * -1,
          );
    });

    final halfLife$ = useComputed<double?>(() {
      if (selected.value != 'half') return halfLife();

      if (initialActivity() == null ||
          finalActivity() == null ||
          time() == null) {
        return null;
      }
      return (time()! * math.ln2) /
          math.log(
            initialActivity()! / finalActivity()!,
          );
    });

    final time$ = useComputed<double?>(() {
      if (selected.value != 'time') return time();

      if (initialActivity() == null ||
          finalActivity() == null ||
          halfLife() == null) {
        return null;
      }
      return (math.log(
            finalActivity()! / initialActivity()!,
          )) /
          ((math.ln2 / halfLife()!) * -1);
    });

    final chartData$ = useComputed(() {
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

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            CupertinoSlidingSegmentedControl(
              groupValue: selected.value,
              children: {
                for (var key in options.value.keys)
                  key: Text(options.value[key]!),
              },
              onValueChanged: (value) {
                selected.value = value!;
              },
            ),
            ActivityInput(
              key: ValueKey((selected.value, 'initial')),
              label: 'Initial Activity',
              value: selected.value != 'initial'
                  ? initialActivity
                  : initialActivity$,
            ),
            ActivityInput(
              key: ValueKey((selected.value, 'final')),
              label: 'Final Activity',
              value: selected.value != 'final' ? finalActivity : finalActivity$,
            ),
            DoubleInput(
              key: ValueKey((selected.value, 'half')),
              label: 'Half Life',
              value: selected.value != 'half' ? halfLife : halfLife$,
            ),
            DoubleInput(
              key: ValueKey((selected.value, 'time')),
              label: 'Time',
              value: selected.value != 'time' ? time : time$,
            ),
            Padding(
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
            ),
          ],
        ),
      ),
    );
  }
}
