
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:math' as math;

import '../../../widgets/distance_input.dart';
import '../../../widgets/exposure_rate_input.dart';
import '../../../widgets/chart.dart';
import '../base.dart';
import 'shared.dart';

class LineSourceDistance2 extends BaseCalc {
  LineSourceDistance2({super.key});

  @override
  String get title => 'Distance 2';

  @override
  List<String> get tags => [
        'Line Source',
      ];

  // Inputs
  final exposureRate1= signal<double>(0.0);
  final exposureRate2 = signal<double>(0.0);
  final distance1 = signal<double>(0.0);
  final length = signal<double>(0.0);
  

  // Outputs
  late final distance2  = computed(() {
    if (exposureRate2() > exposureRate1()) {
      if (distance1() <= (length() / 2)) {   
        return (exposureRate1() / exposureRate2()) * distance1();
      }
      else{
      double exposureRateL2 = exposureRate1() * math.pow((distance1()/(length()/2)),2);
      return (exposureRateL2/ exposureRate2()) * (length() / 2);
      }
    } if (exposureRate2() < exposureRate1()) {                                                                                                                                                                                                                      
      if (distance1() <= (length() / 2)) {
        return (exposureRate1() / exposureRate2()) * distance1();
      }
      else{
      double exposureRateL2 = exposureRate1() * (distance1() / (length() / 2));
      return math.sqrt((exposureRateL2/ exposureRate2()) * 
      math.pow(distance1(),2));
      }
    }
    else{
      return distance1();
    }
  });

  late final chartData = computed(() {
    return buildChartData(
      exposureRate1: exposureRate1,
      exposureRate2: exposureRate2,
      distance1: distance1,
      distance2: distance2,
    );
  });

  @override
  List<Widget> buildInputs(BuildContext context) {
    return [
      ExposureRateInput(
        label: 'Exposure Rate 1',
        value: exposureRate1,
      ),
      ExposureRateInput(
        label: 'Exposure Rate 2',
        value: exposureRate2,
      ),
      DistanceInput(
        label: 'Distance 1',
        value: distance1,
      ),
    ];
  }

  @override
  List<Widget> buildOutputs(BuildContext context) {
    return [
      DistanceInput(
        label: 'Distance 2',
        value: distance2,
      ),
      Chart(
        label: 'Exposure Rate vs Distance',
        source: chartData,
      ),
    ];
  }
}
