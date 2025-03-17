import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:math' as math;


import '../../../widgets/distance_input.dart';
import '../../../widgets/exposure_rate_input.dart';
import '../../../widgets/chart.dart';
import '../base.dart';
import 'shared.dart';

class PointSourceExposureRate2 extends BaseCalc {
  PointSourceExposureRate2({super.key});

  @override
  String get title => 'Exposure Rate 2';

  @override
  List<String> get tags => [
        'Point Source',
      ];

  // Inputs
  final exposureRate1= signal<double>(0.0);
  final distance1 = signal<double>(0.0);
  final distance2 = signal<double>(0.0);

  // Outputs
  late final exposureRate2 = computed(() {
    return (exposureRate1() * 
      math.pow((distance1()/ distance2()), 2));
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
      DistanceInput(
        label: 'Distance 1',
        value: distance1,
      ),
      DistanceInput(
        label: 'Distance 2',
        value: distance2,
      ),
    ];
  }

  @override
  List<Widget> buildOutputs(BuildContext context) {
    return [
      ExposureRateInput(
        label: 'Exposure Rate 2',
        value: exposureRate2,
      ),
      Chart(
        label: 'Activity Over Time',
        source: chartData,
      ),
    ];
  }
}
