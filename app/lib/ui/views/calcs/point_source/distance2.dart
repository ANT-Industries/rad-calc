
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:math' as math;

import '../../../widgets/distance_input.dart';
import '../../../widgets/exposure_rate_input.dart';
import '../../../widgets/chart.dart';
import '../base.dart';
import 'shared.dart';

class PointSourceDistance2 extends BaseCalc {
  PointSourceDistance2({super.key});

  @override
  String get title => 'Distance 2';

  @override
  List<String> get tags => [
        'Point Source',
      ];

  // Inputs
  final exposureRate1= signal<double>(0.0);
  final exposureRate2 = signal<double>(0.0);
  final distance1 = signal<double>(0.0);
  

  // Outputs
  late final distance2  = computed(() {
    return math.sqrt((exposureRate1()/ exposureRate2()) * 
      math.pow(distance1(),2)
      );
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
