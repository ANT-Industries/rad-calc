import 'package:app/ui/widgets/exposure_rate_input.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../widgets/double_input.dart';
import '../widgets/time_input.dart';
import '../widgets/exposure_rate_input.dart';
import '../widgets/exposure_input.dart';
import 'base_calc.dart';

BaseCalc buildStayTime() {
  final builder = BaseCalcBuilder('Stay Time');

  final exposureRate = Input<double>(
    'Exposure Rate',
    0.0,
    (val) {
      return ExposureRateInput(
        label: 'Exposure Rate',
        value: val,
      );
    },
  );

  final allowableExposure = Input<double>(
    'Time',
    10.0,
    (val) {
      return ExposureInput(
        label: 'Allowable Exposure',
        value: val,
      );
    },
  );

   final stayTime = Input<double>(
    'Time',
    10.0,
    (val) {
      return TimeInput(
        label: 'Stay Time',
        value: val,
      );
    },
  );
  final solveForStayTime = Output<double>('Stay Time', () {
    return safeCalc(() {
      return allowableExposure() / exposureRate() * 3600; // convert to seconds
    }, 0);
  }, (val) {
    return TimeInput(
      label: 'Stay Time',
      value: val,
    );
  })
    ..input = stayTime;

  final solveForAllowableExposure = Output<double>('Allowable Exposure', () {
    return safeCalc(() {
      return stayTime() * exposureRate() / 3600; // convert to hours
    }, 0);
  }, (val) {
    return ExposureInput(
      label: 'Allowable Exposure',
      value: val,
    );
  })
    ..input = allowableExposure;

  final solveForExposureRate = Output<double>('Exposure Rate', () {
    return safeCalc(() {
      return allowableExposure() / stayTime() * 3600; // convert to seconds
    }, 0);
  }, (val) {
    return ExposureRateInput(
      label: 'Exposure Rate',
      value: val,
    );
  })
    ..input = exposureRate;

  builder.addCalculation('Stay Time', Icons.timer)
    ..inputs.add(allowableExposure)
    ..inputs.add(exposureRate)
    ..outputs.add(solveForStayTime);

  builder.addCalculation('Allowable Exposure', Icons.calculate)
    ..inputs.add(stayTime)
    ..inputs.add(exposureRate)
    ..outputs.add(solveForAllowableExposure);

  builder.addCalculation('Exposure Rate', Icons.calculate)
    ..inputs.add(allowableExposure)
    ..inputs.add(stayTime)
    ..outputs.add(solveForExposureRate);

  builder.setDefaultCalculation('Stay Time');

  return builder.build();
}
