import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'dart:math' as math;

import '../../../widgets/activity_input.dart';
import '../../../widgets/chart.dart';
import '../../../widgets/time_input.dart';
import '../base.dart';
import 'shared.dart';

class HalfLifeFinalActivity extends BaseCalc {
  HalfLifeFinalActivity({super.key});

  @override
  String get title => 'Half Life (Final Activity)';

  @override
  List<String> get tags => [
        'Half Life',
      ];

  // Inputs
  final initialActivity = signal<double>(0.0);
  final halfLife = signal<double>(0.0);
  final time = signal<double>(0.0);

  // Outputs
  late final finalActivity = computed(() {
    return initialActivity() *
        math.pow(
          math.e,
          ((math.ln2 / halfLife()) * time()) * -1,
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
        label: 'Initial Activity',
        value: initialActivity,
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
        label: 'Final Activity',
        value: finalActivity,
      ),
      Chart(
        label: 'Activity Over Time',
        source: chartData,
      ),
    ];
  }
}
