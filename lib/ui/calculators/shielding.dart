import 'package:app/ui/widgets/exposure_input.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:math' as math;

import '../widgets/exposure_input.dart';
import '../widgets/double_input.dart';
import '../widgets/time_input.dart';
import 'base_calc.dart';

BaseCalc buildShielding() {
  final builder = BaseCalcBuilder('Shielding');

  final initialExposure = Input<double>(
    'Initial Exposure',
    0.0,
    (val) {
      return ExposureInput(
        label: 'Initial Exposure',
        value: val,
      );
    },
  );

  final finalExposure = Input<double>(
    'Final Exposure',
    0.0,
    (val) {
      return ExposureInput(
        label: 'Final Exposure',
        value: val,
      );
    },
  );

  final numHVL = Input<double>(
    'Number of HVL',
   0.0,
    (val) {
      return DoubleInput(
        label: 'Number of HVL',
        value: val,
      );
    },
  );

  final solveForInitialExposure = Output<double>('Initial Exposure', () {
    return safeCalc(() {
      return finalExposure() /
          math.pow(
            .5, (numHVL()));
    }, 0);
  }, (val) {
    return ExposureInput(
      label: 'Initial Exposure',
      value: val,
    );
  })
    ..input = initialExposure;

  final solveForFinalExposure = Output<double>('Final Exposure', () {
    return safeCalc(() {
      return initialExposure() *
          math.pow(
            .5, (numHVL()));
    }, 0);
  }, (val) {
    return ExposureInput(
      label: 'Final Exposure',
      value: val,
    );
  })
    ..input = finalExposure;



  Chart dropoffOverHVL({
    required CoreValue<double> initialExposure,
    required CoreValue<double> finalExposure,
    required CoreValue<double> numHVL,

  }) {
    return Chart('dropoff Over HVL', computed(() {
      final results = <({double x, double y})>[];

      final iE = initialExposure();
      final fE = finalExposure();
      final nHVL = numHVL();


      results.add((
        y: iE,
        x: 0,
      ));

      int increments = (nHVL.isNaN || nHVL.isInfinite) ? 0 : nHVL.toInt();
      for (var i = 0; i < increments; i++) {
        double slope(double x) {
          return iE *
              math.pow(
                math.e,
                ((math.ln2 / nHVL) * x) * -1,
              );
        }

        results.add((
          y: slope(i.toDouble()),
          x: i.toDouble(),
        ));
      }

      results.add((
        y: fE,
        x: nHVL.toDouble(),
      ));

      return results;
    }));
  }

  builder.addCalculation('Initial Exposure', Icons.calculate)
    ..inputs.add(finalExposure)
    ..inputs.add(numHVL)
    ..outputs.add(solveForInitialExposure)
    ..charts.add(dropoffOverHVL(
      initialExposure: solveForInitialExposure,
      finalExposure: solveForFinalExposure,
      numHVL: numHVL,
    ));

  builder.addCalculation('Final Exposure', Icons.calculate)
    ..inputs.add(initialExposure)
    ..inputs.add(numHVL)
    ..outputs.add(solveForFinalExposure)
    ..charts.add(dropoffOverHVL(
      initialExposure: solveForInitialExposure,
      finalExposure: solveForFinalExposure,
      numHVL: numHVL,
    ));

  builder.setDefaultCalculation('Final Exposure');

  return builder.build();
}
