import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals_hooks/signals_hooks.dart';

import 'dart:math' as math;

import '../widgets/activity_input.dart';
import '../widgets/double_input.dart';
import '../widgets/graph.dart';
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

    final graphSize = useSignal<Size>(const Size(800, 400));

    final path$ = useComputed(() {
      final path = Path();
      final size = graphSize.value;

      int resolution = 1;

      final iA = initialActivity$() ?? 0;
      final fA = finalActivity$() ?? 0;
      final hL = halfLife$() ?? 10;
      final t = time$() ?? 10;

      final maxActivity = math.max(iA, fA);
      final maxTime = t;

      final xScale = size.width / maxTime;
      final yScale = size.height / maxActivity;

      Offset point(double x, double y) {
        return Offset(x * xScale, size.height - y * yScale);
      }

      double slope(double x) {
        return iA *
            math.pow(
              math.e,
              ((math.ln2 / hL) * x) * -1,
            );
      }

      // start value = initial activity
      path.moveTo(point(0, iA).dx, point(0, iA).dy);

      // calculate slope of curve based on resolution
      for (var i = 0; i < maxTime; i += resolution) {
        path.lineTo(
          point(i.toDouble(), slope(i.toDouble())).dx,
          point(i.toDouble(), slope(i.toDouble())).dy,
        );
      }

      // final value = final activity
      path.lineTo(point(t, fA).dx, point(t, fA).dy);

      // path.moveTo(0, 0);
      // path.lineTo(size.width, size.height);

      // // -- debug grid --
      // // draw x axis
      // for (var i = 0; i < xDivisions; i++) {
      //   path.moveTo(i * resolution.toDouble(), 0);
      //   path.lineTo(i * resolution.toDouble(), size.height);
      // }

      // // draw y axis
      // for (var i = 0; i < yDivisions; i++) {
      //   path.moveTo(0, i * resolution.toDouble());
      //   path.lineTo(size.width, i * resolution.toDouble());
      // }

      return path;
    });

    useReassemble(path$.recompute);

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
            // const Divider(),
            // ElevatedButton(
            //   onPressed: () {
            //     if (formKey.currentState!.validate()) {
            //       formKey.currentState!.save();
            //     }
            //   },
            //   child: const Text('Calculate'),
            // ),
            Grapher(
              name: 'Activity over Time',
              width: graphSize.value.width,
              height: graphSize.value.height,
              yLabels: timeLabels(halfLife$() ?? 10),
              xLabels: activityLabels(initialActivity$() ?? 10),
              path: path$,
            ),
          ],
        ),
      ),
    );
  }
}

Iterable<String> activityLabels(double initialActivity) sync* {
  for (var i = 0; i < 4; i++) {
    yield (i * initialActivity / 3).toStringAsFixed(0);
  }
}

Iterable<String> timeLabels(double halfLife) sync* {
  // max = 6 * half life
  final max = 6 * halfLife;
  for (var i = 0; i < 6; i++) {
    yield (i * max / 5).toStringAsFixed(2);
  }
}
