import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:math' as math;

import '../widgets/activity_input.dart';
import '../widgets/double_input.dart';
import '../widgets/time_input.dart';
import 'base_calc.dart';

BaseCalc buildHalfLife() {
  final builder = BaseCalcBuilder('Half Life');

  final initialActivity = Input<double>(
    'Initial Activity',
    0.0,
    (val) {
      return ActivityInput(
        label: 'Initial Activity',
        value: val,
      );
    },
  );

  final finalActivity = Input<double>(
    'Final Activity',
    0.0,
    (val) {
      return ActivityInput(
        label: 'Final Activity',
        value: val,
      );
    },
  );

  final halfLife = Input<double>(
    'Half Life',
    10.0,
    (val) {
      return TimeInput(
        label: 'Half Life',
        value: val,
      );
    },
  );

  final time = Input<double>(
    'Time',
    10.0,
    (val) {
      return TimeInput(
        label: 'Time',
        value: val,
      );
    },
  );
//test?
  final solveForInitialActivity = Output<double>('Initial Activity', () {
    return safeCalc(() {
      return finalActivity() *
          math.pow(
            math.e,
            (math.ln2 / halfLife()) * time(),
          );
    }, 0);
  }, (val) {
    return ActivityInput(
      label: 'Initial Activity',
      value: val,
    );
  })
    ..input = initialActivity;

  final solveForFinalActivity = Output<double>('Final Activity', () {
    return safeCalc(() {
      return initialActivity() *
          math.pow(
            math.e,
            ((math.ln2 / halfLife()) * time()) * -1,
          );
    }, 0);
  }, (val) {
    return ActivityInput(
      label: 'Final Activity',
      value: val,
    );
  })
    ..input = finalActivity;

  final solveForHalfLife = Output<double>('Half Life', () {
    return safeCalc(() {
      return (time() * math.ln2) /
          math.log(
            initialActivity() / finalActivity(),
          );
    }, 0);
  }, (val) {
    return DoubleInput(
      label: 'Half Life',
      value: val,
    );
  })
    ..input = halfLife;

  final solveForTime = Output<double>('Time', () {
    return safeCalc(() {
      return (math.log(
            finalActivity() / initialActivity(),
          )) /
          ((math.ln2 / halfLife()) * -1);
    }, 0);
  }, (val) {
    return DoubleInput(
      label: 'Time',
      value: val,
    );
  })
    ..input = time;

  Chart activityOverTime({
    required CoreValue<double> initialActivity,
    required CoreValue<double> finalActivity,
    required CoreValue<double> halfLife,
    required CoreValue<double> time,
  }) {
    return Chart('Activity Over Time', computed(() {
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
