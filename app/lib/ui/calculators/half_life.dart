import 'package:flutter/material.dart';
import 'package:rational/rational.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:math' as math;

import '../../data/numbers/rational.dart';
import '../widgets/activity_input.dart';
import '../widgets/time_input.dart';
import 'base_calc.dart';

BaseCalc buildHalfLife() {
  final builder = BaseCalcBuilder('Half Life');

  final initialActivity = Input<Rational>(
    'Initial Activity',
    Rational.zero,
    (val) {
      return ActivityInput(
        label: 'Initial Activity',
        value: val,
      );
    },
    getValue: Rational.parse,
    setValue: (val) => val.toString(),
  );

  final finalActivity = Input<Rational>(
    'Final Activity',
    Rational.zero,
    (val) {
      return ActivityInput(
        label: 'Final Activity',
        value: val,
      );
    },
    getValue: Rational.parse,
    setValue: (val) => val.toString(),
  );

  final halfLife = Input<Rational>(
    'Half Life',
    Rational.parse('10'),
    (val) {
      return TimeInput(
        label: 'Half Life',
        value: val,
      );
    },
    getValue: Rational.parse,
    setValue: (val) => val.toString(),
  );

  final time = Input<Rational>(
    'Time',
    Rational.parse('10'),
    (val) {
      return TimeInput(
        label: 'Time',
        value: val,
      );
    },
    getValue: Rational.parse,
    setValue: (val) => val.toString(),
  );

  final solveForInitialActivity = Output<Rational>('Initial Activity', () {
    return safeRational(() {
      return finalActivity() *
          math.e.toRational().pow(
                ((math.ln2.toRational() / halfLife()) * time())
                    .toBigInt()
                    .toInt(),
              );
    });
  }, (val) {
    return ActivityInput(
      label: 'Initial Activity',
      value: val,
    );
  })
    ..input = initialActivity;

  final solveForFinalActivity = Output<Rational>('Final Activity', () {
    return safeRational(() {
      return initialActivity() *
          math.e.toRational().pow(
                (((math.ln2.toRational() / halfLife()) * time()) *
                        Rational.fromInt(-1))
                    .toBigInt()
                    .toInt(),
              );
    });
  }, (val) {
    return ActivityInput(
      label: 'Final Activity',
      value: val,
    );
  })
    ..input = finalActivity;

  final solveForHalfLife = Output<Rational>('Half Life', () {
    return safeRational(() {
      return (time() * math.ln2.toRational()) /
          math
              .log(
                (initialActivity() / finalActivity()).toDouble(),
              )
              .toRational();
    });
  }, (val) {
    return TimeInput(
      label: 'Half Life',
      value: val,
    );
  })
    ..input = halfLife;

  final solveForTime = Output<Rational>('Time', () {
    return safeRational(() {
      return (math
              .log((finalActivity() / initialActivity()).toDouble())
              .toRational()) /
          ((math.ln2.toRational() / halfLife()) * Rational.fromInt(-1));
    });
  }, (val) {
    return TimeInput(
      label: 'Time',
      value: val,
    );
  })
    ..input = time;

  Chart activityOverTime({
    required CoreValue<Rational> initialActivity,
    required CoreValue<Rational> finalActivity,
    required CoreValue<Rational> halfLife,
    required CoreValue<Rational> time,
  }) {
    return Chart('Activity Over Time', computed(() {
      final results = <({double x, double y})>[];

      final iA = initialActivity();
      final fA = finalActivity();
      final hL = halfLife();
      final t = time();

      results.add((
        y: iA.toDouble(),
        x: 0,
      ));

      int increments = (t.toDouble().isNaN || t.toDouble().isInfinite)
          ? 0
          : t.toDouble().toInt();
      for (var i = 0; i < increments; i++) {
        double slope(double x) {
          return iA.toDouble() *
              math.pow(
                math.e,
                ((math.ln2 / hL.toDouble()) * x) * -1,
              );
        }

        results.add((
          y: slope(i.toDouble()),
          x: i.toDouble(),
        ));
      }

      results.add((
        y: fA.toDouble(),
        x: t.toDouble(),
      ));

      return results;
    }));
  }

  builder.addCalculation('Initial Activity', Icons.calculate)
    ..inputs.add(finalActivity)
    ..inputs.add(halfLife)
    ..inputs.add(time)
    ..outputs.add(solveForInitialActivity)
    ..charts.add(activityOverTime(
      initialActivity: solveForInitialActivity,
      finalActivity: finalActivity,
      halfLife: halfLife,
      time: time,
    ));

  builder.addCalculation('Final Activity', Icons.calculate)
    ..inputs.add(initialActivity)
    ..inputs.add(halfLife)
    ..inputs.add(time)
    ..outputs.add(solveForFinalActivity)
    ..charts.add(activityOverTime(
      initialActivity: initialActivity,
      finalActivity: solveForFinalActivity,
      halfLife: halfLife,
      time: time,
    ));

  builder.addCalculation('Half Life', Icons.timer)
    ..inputs.add(initialActivity)
    ..inputs.add(finalActivity)
    ..inputs.add(time)
    ..outputs.add(solveForHalfLife)
    ..charts.add(activityOverTime(
      initialActivity: initialActivity,
      finalActivity: finalActivity,
      halfLife: solveForHalfLife,
      time: time,
    ));

  builder.addCalculation('Time', Icons.timer)
    ..inputs.add(initialActivity)
    ..inputs.add(finalActivity)
    ..inputs.add(halfLife)
    ..outputs.add(solveForTime)
    ..charts.add(activityOverTime(
      initialActivity: initialActivity,
      finalActivity: finalActivity,
      halfLife: halfLife,
      time: solveForTime,
    ));

  builder.setDefaultCalculation('Half Life');

  return builder.build();
}
