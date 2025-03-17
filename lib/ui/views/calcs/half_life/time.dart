import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:math' as math;

import '../../../widgets/activity_input.dart';
import '../../../widgets/chart.dart';
import '../../../widgets/time_input.dart';
import '../base.dart';
import 'shared.dart';

class HalfLifeTime extends BaseCalc {
  HalfLifeTime({super.key});

  @override
  String get title => 'Time';

  @override
  List<String> get tags => [
        'Half Life',
      ];

  // Inputs
  final initialActivity = signal<double>(0.0);
  final finalActivity = signal<double>(0.0);
  final halfLife = signal<double>(0.0);

  // Outputs
  late final time = computed(() {
    return (math.log(
          finalActivity() / initialActivity(),
        )) /
        ((math.ln2 / halfLife()) * -1);
  });

  late final chartData = computed(() {
    return buildChartData(
      initialActivity: initialActivity,
      finalActivity: finalActivity,
      halfLife: halfLife,
      time: time,
    );
  });

  @override
  List<Widget> buildInputs(BuildContext context) {
    return [
      ActivityInput(
        label: 'Initial Activity',
        value: initialActivity,
      ),
      ActivityInput(
        label: 'Final Activity',
        value: finalActivity,
      ),
      TimeInput(
        label: 'Half Life',
        value: halfLife,
      ),
    ];
  }

  @override
  List<Widget> buildOutputs(BuildContext context) {
    return [
      TimeInput(
        label: 'Time',
        value: time,
      ),
      Chart(
        label: 'Activity Over Time',
        source: chartData,
      ),
    ];
  }
}
