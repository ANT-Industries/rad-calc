import 'package:app/ui/widgets/exposure_rate_input.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:math' as math;


import '../widgets/double_input.dart';
import '../widgets/distance_input.dart';
import '../widgets/exposure_rate_input.dart';
import 'base_calc.dart';

BaseCalc buildPlaneSource() {
  final builder = BaseCalcBuilder('Plane Source');
  
  final radius = Input<double>(
    'radius',
    10.0,
    (val) {
      return DistanceInput(
        label: 'Effective radius',
        value: val,
      );
    },
  );

  final exposureRate1 = Input<double>(
    'Exposure Rate 1',
    1,
    (val) {
      return ExposureRateInput(
        label: 'Exposure Rate 1',
        value: val,
      );
    },
  );

  final exposureRate2 = Input<double>(
    'Exposure Rate 2',
    10,
    (val) {
      return ExposureRateInput(
        label: 'Exposure Rate 2',
        value: val,
      );
    },
  );

  final distance1 = Input<double>(
    'Distance 1',
    5.0,
    (val) {
      return DistanceInput(
        label: 'Distance 1',
        value: val,
      );
    },
  );

  final distance2 = Input<double>(
    'Distance 2',
    100.0,
    (val) {
      return DistanceInput(
        label: 'Distance 2',
        value: val,
      );
    },
  );

  // final solveForexposureRate1 = Output<double>('Exposure Rate 1', () {
  //   return safeCalc(() {
  //   if (distance1()<= (radius() / 2)) {
  //     return exposureRate2() * (distance2() / distance1());
  //   } else {
  //     double exposureRateL2 = exposureRate2() * (distance2() / (radius() / 2));
  //     return exposureRateL2  * math.pow(((radius() / 2) / distance1()), 2);
  //   }
  // }, 0);
  // }, (val) {
  //   return ExposureRateInput(
  //     label: 'Exposure Rate 1',
  //     value: val,
  //   );
  // })
  //   ..input = exposureRate1;

  final solveForexposureRate2 = Output<double>('Exposure Rate 2', () {
  return safeCalc(() {
    if (distance1() < distance2()) {
      if (distance2() <= (radius() * 0.1)) {
        return exposureRate1();
      } else if (distance2() > (radius() * 0.1) && distance2() <= (radius() * 0.7) && distance1() <= (radius() * 0.1)) {
        return exposureRate1() / 3;
      } else if (distance2() >= (radius() * 0.7) && distance1() <= (radius() * 0.7)) {
      return exposureRate1() * math.pow((radius()* 0.7) / distance2(), 2);
      } else if (distance1() >= (radius() * 0.7) ) {
        return exposureRate1() * math.pow(distance1() / distance2(), 2);
      } else {
        return exposureRate1();
      }
    } else if (distance1() > distance2()) { 
      if (distance1() <= (radius() * 0.1)) {
        return exposureRate1();
      } else if (distance1() > (radius() * 0.1) && distance1() <= (radius() * 0.7) && distance2() <= (radius() * 0.1)) {
        return exposureRate1() / 3;
      } else if (distance2() >= (radius() * 0.7) && distance2() <= (radius() * 0.7)) {
        return exposureRate1() * math.pow(distance1() / distance2(), 2);
      } else {  
        return exposureRate1();
      }
    } else {
      return exposureRate1();
    }
  }, 0);
}, (val) {
  return ExposureRateInput(
    label: 'Exposure Rate 2',
    value: val,
  );
})..input = exposureRate2;

  // final solveFordistance1 = Output<double>('Distance 1', () {
  // return safeCalc(() {
  //   if (exposureRate1() > exposureRate2()) {
  //     if (distance2() <= (radius() / 2)) {   
  //       return (exposureRate2() / exposureRate1()) * distance2();
  //     }
  //     else{
  //     double exposureRateL2 = exposureRate2() * math.pow((distance2()/(radius()/2)),2);
  //     return (exposureRateL2/ exposureRate1()) * (radius() / 2);
  //     }
  //   } if (exposureRate1() < exposureRate2()) {                                                                                                                                                                                                                      
  //     if (distance1() <= (radius() / 2)) {
  //       return (exposureRate2() / exposureRate1()) * distance2();
  //     }
  //     else{
  //     double exposureRateL2 = exposureRate2() * (distance2() / (radius() / 2));
  //     return math.sqrt((exposureRateL2/ exposureRate1()) * 
  //     math.pow(distance2(),2));
  //     }
  //   }
  //   else{
  //     return distance2();
  //   }
  //     }, 0);
  // }, (val) {
  //     return DistanceInput(
  //       label: 'Distance 1',
  //       value: val,
  //     );
  // })..input = distance1;

  final solveFordistance2 = Output<double>('Distance 2', () {
  return safeCalc(() {
    if (exposureRate2() > exposureRate1()) {
      if (distance1() <= (radius() / 2)) {   
        return (exposureRate1() / exposureRate2()) * distance1();
      }
      else{
      double exposureRateL2 = exposureRate1() * math.pow((distance1()/(radius()/2)),2);
      return (exposureRateL2/ exposureRate2()) * (radius() / 2);
      }
    } if (exposureRate2() < exposureRate1()) {                                                                                                                                                                                                                      
      if (distance2() <= (radius() / 2)) {
        return (exposureRate1() / exposureRate2()) * distance1();
      }
      else{
      double exposureRateL2 = exposureRate1() * (distance1() / (radius() / 2));
      return math.sqrt((exposureRateL2/ exposureRate2()) * 
      math.pow(distance1(),2));
      }
    }
    else{
      return distance1();
    }
      }, 0);
  }, (val) {
      return DistanceInput(
        label: 'Distance 2',
        value: val,
      );
  })..input = distance2;


  Chart activityOverdistance2({
    required CoreValue<double> exposureRate1,
    required CoreValue<double> exposureRate2,
    required CoreValue<double> distance1,
    required CoreValue<double> distance2,
  }) {
    return Chart('Exposure Over Distance', computed(() {
  final results = <({double x, double y})>[];

  final er1 = exposureRate1();
  final d1 = distance1();
  final d2 = distance2();

  if (d1 <= 0 || d2 <= d1 || d2.isNaN || d2.isInfinite) {
    return results; // Return empty if distances are invalid
  }

  results.add((x: d1.toDouble(), y: er1)); // Start at d1

  int increments = (d2 - d1).toInt();
  for (var i = 1; i <= increments; i++) {
    double x = d1 + i.toDouble(); // Distance increases
    double y = er1 * math.pow((d1 / x), 2); // Exposure decreases
    results.add((x: x, y: y)); // Correct axis assignment
  }

  return results;
}));
  }

  // builder.addCalculation('Exposure Rate 1', Icons.calculate)
  //   ..inputs.add(radius)
  //   ..inputs.add(exposureRate2)
  //   ..inputs.add(distance1)
  //   ..inputs.add(distance2)
  //   ..outputs.add(solveForexposureRate1)
  //   ..charts.add(activityOverdistance2(
  //     exposureRate1: solveForexposureRate1,
  //     exposureRate2: exposureRate2,
  //     distance1: distance1,
  //     distance2: distance2,
  //   ));

  builder.addCalculation('Exposure Rate 2', Icons.calculate)
    ..inputs.add(radius)
    ..inputs.add(exposureRate1)
    ..inputs.add(distance1)
    ..inputs.add(distance2)
    ..outputs.add(solveForexposureRate2)
    ..charts.add(activityOverdistance2(
      exposureRate1: exposureRate1,
      exposureRate2: solveForexposureRate2,
      distance1: distance1,
      distance2: distance2,
    ));

  // builder.addCalculation('Distance 1', Icons.calculate)
  //   ..inputs.add(radius)
  //   ..inputs.add(exposureRate1)
  //   ..inputs.add(exposureRate2)
  //   ..inputs.add(distance2)
  //   ..outputs.add(solveFordistance1)
  //   ..charts.add(activityOverdistance2(
  //     exposureRate1: exposureRate1,
  //     exposureRate2: exposureRate2,
  //     distance1: solveFordistance1,
  //     distance2: distance2,
  //   ));

  builder.addCalculation('Distance 2', Icons.calculate)
    ..inputs.add(radius)
    ..inputs.add(exposureRate1)
    ..inputs.add(exposureRate2)
    ..inputs.add(distance1)
    ..outputs.add(solveFordistance2)
    ..charts.add(activityOverdistance2(
      exposureRate1: exposureRate1,
      exposureRate2: exposureRate2,
      distance1: distance1,
      distance2: solveFordistance2,
    ));

  builder.setDefaultCalculation('Exposure Rate 2');

  return builder.build();
}
