import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:math' as math;

import '../../../widgets/activity_input.dart';
import '../../../widgets/chart.dart';
import '../../../widgets/time_input.dart';
import '../base.dart';
import 'shared.dart';

class HalfLifeInitialActivity extends BaseCalc {
  HalfLifeInitialActivity({super.key});

  @override
  String get title => 'Initial Activity';

  @override
  List<String> get tags => [
        'Half Life',
      ];

  // Inputs
  final finalActivity = signal<double>(0.0);
  final halfLife = signal<double>(0.0);
  final time = signal<double>(0.0);

  // Outputs
  late final initialActivity = computed(() {
    return finalActivity() *
        math.pow(
          math.e,
          (math.ln2 / halfLife()) * time(),
        );
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
        label: 'Final Activity',
        value: finalActivity,
      ),
      TimeInput(
        label: 'Half Life',
        value: halfLife,
      ),
      TimeInput(
        label: 'Time',
        value: time,
      ),
    ];
  }

  @override
  List<Widget> buildOutputs(BuildContext context) {
    return [
      ActivityInput(
        label: 'Initial Activity',
        value: initialActivity,
      ),
      Chart(
        label: 'Activity Over Time',
        source: chartData,
      ),
    ];
  }
}
