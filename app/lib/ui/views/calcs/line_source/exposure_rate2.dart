import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:math' as math;


import '../../../widgets/distance_input.dart';
import '../../../widgets/exposure_rate_input.dart';
import '../../../widgets/chart.dart';
import '../base.dart';
import 'shared.dart';

class LineSourceExposureRate2 extends BaseCalc {
  LineSourceExposureRate2({super.key});

  @override
  String get title => 'Exposure Rate 2';

  @override
  List<String> get tags => [
        'Line Source',
      ];

  // Inputs
  final exposureRate1= signal<double>(0.0);
  final distance1 = signal<double>(0.0);
  final distance2 = signal<double>(0.0);
  final length = signal<double>(0.0);

  // Outputs
  late final exposureRate2 = computed(() {
    if (distance1() < distance2()) {
      if (distance1() <= (length() / 2)) {
        return exposureRate1() * (distance1() / distance2());
      } else {
        double exposureRateL2 = exposureRate1() * (distance1() / (length() / 2));
        return exposureRateL2 * math.pow(((length() / 2) / distance2()), 2);
      }
    } if (distance1() > distance2()) { 
      if (distance2() > (length() / 2)) {
        return exposureRate1() * math.pow(distance1() / (length() / 2), 2);
      } else {
        double exposureRateL2 = exposureRate1() * math.pow(distance1() / (length() / 2), 2);
        return exposureRateL2 * ((length() / 2) / distance2());
      }
    } else {
      return exposureRate1();
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
