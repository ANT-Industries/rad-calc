import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:math' as math;

import '../widgets/double_input.dart';
import 'base_calc.dart';

BaseCalc buildSixCen() {
  final builder = BaseCalcBuilder('6CEN');

  final C = Input<double>(
    'Curies',
    0.0,
        (val) {
      return DoubleInput(
        label: 'Curies',
        value: val,
      );
    },
  );

  final E = Input<double>(
    'Photon Energy (MeV)',
    0.0,
        (val) {
      return DoubleInput(
        label: 'Photon Energy (MeV)',
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
    'Exposure',
    0.0,
        (val) {
      return DoubleInput(
        label: 'Exposure',
        value: val,
      );
    },
  );

  final solveForCuries = Output<double>('Curies', () {
    return safeCalc(() {
      return exposure() / (6 * N() * E());
    }, 0);
  }, (val) {
    return DoubleInput(
      label: 'Curies',
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

  final solveForExposure = Output<double>('Exposure', () {
    return safeCalc(() {
      return (6 * C() * E() * N());
    }, 0);
  }, (val) {
    return DoubleInput(
      label: 'Exposure',
      value: val,
    );
  })
    ..input = exposure;



  builder.addCalculation('Exposure', Icons.calculate)
    ..inputs.add(C)
    ..inputs.add(E)
    ..inputs.add(N)
    ..outputs.add(solveForExposure);

  builder.addCalculation('Curies', Icons.calculate)
    ..inputs.add(exposure)
    ..inputs.add(E)
    ..inputs.add(N)
    ..outputs.add(solveForCuries);

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

  builder.setDefaultCalculation('Exposure');

  return builder.build();
}
