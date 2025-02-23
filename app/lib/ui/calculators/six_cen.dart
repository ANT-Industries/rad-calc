import 'package:app/ui/widgets/energy_input.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:math' as math;

import '../widgets/energy_input.dart';
import '../widgets/double_input.dart';
import '../widgets/activity_input.dart';
import 'base_calc.dart';

BaseCalc buildSixCen() {
  final builder = BaseCalcBuilder('6CEN');

  final C = Input<double>(
    'Activty',
    0.0,
        (val) {
      return ActivityInput(
        label: 'Activity',
        value: val,
      );
    },
  );

  final E = Input<double>(
    'Photon Energy',
    0.0,
        (val) {
      return EnergyInput(
        label: 'Photon Energy',
        value: val,
      );
    },
  );

  final N = Input<double>(
    'Photon Abundance',
    0.0,
        (val) {
      return DoubleInput(
        label: 'Photon Abundance',
        value: val,
      );
    },
  );

  final exposure = Input<double>(
    'Exposure (R/hr)',
    0.0,
        (val) {
      return DoubleInput(
        label: 'Exposure (R/hr)',
        value: val,
      );
    },
  );

  final solveForActivity = Output<double>('Activity', () {
    return safeCalc(() {
      return exposure() / (6 * N() * E());
    }, 0);
  }, (val) {
    return DoubleInput(
      label: 'Activity',
      value: val,
    );
  })
    ..input = C;

  final solveForPhotonEnergy = Output<double>('Photon Energy (MeV)', () {
    return safeCalc(() {
      return exposure() / (6 * C() * N());
    }, 0);
  }, (val) {
    return DoubleInput(
      label: 'Photon Energy (MeV)',
      value: val,
    );
  })
    ..input = E;

  final solveForPhotonAbundance = Output<double>('Photon Abundance', () {
    return safeCalc(() {
      return exposure() / (6 * C() * E());
    }, 0);
  }, (val) {
    return DoubleInput(
      label: 'Photon Abundance',
      value: val,
    );
  })
    ..input = N;

  final solveForExposure = Output<double>('Exposure (R/hr)', () {
    return safeCalc(() {
      return (6 * C() * E() * N());
    }, 0);
  }, (val) {
    return DoubleInput(
      label: 'Exposure (R/hr)',
      value: val,
    );
  })
    ..input = exposure;



  builder.addCalculation('Exposure (R/hr)', Icons.calculate)
    ..inputs.add(C)
    ..inputs.add(E)
    ..inputs.add(N)
    ..outputs.add(solveForExposure);

  builder.addCalculation('Activity', Icons.calculate)
    ..inputs.add(exposure)
    ..inputs.add(E)
    ..inputs.add(N)
    ..outputs.add(solveForActivity);

  builder.addCalculation('Photon Energy (MeV)', Icons.calculate)
    ..inputs.add(exposure)
    ..inputs.add(C)
    ..inputs.add(N)
    ..outputs.add(solveForPhotonEnergy);

  builder.addCalculation('Photon Abundance', Icons.calculate)
    ..inputs.add(exposure)
    ..inputs.add(C)
    ..inputs.add(E)
    ..outputs.add(solveForPhotonAbundance);

  builder.setDefaultCalculation('Exposure (R/hr)');

  return builder.build();
}
