import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;

class Chart extends HookWidget {
  Chart({
    super.key,
    required this.label,
    required this.source,
  });

  final String label;
  final ReadonlySignal<List<({double x, double y})>> source;

  @override
  Widget build(BuildContext context) {
    final src = useExistingSignal(source);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Watch((context) {
          final colors = Theme.of(context).colorScheme;
          return Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRect(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 400,
                  maxWidth: double.infinity,
                ),
                child: charts.LineChart(
                  [
                    charts.Series<({double x, double y}), double>(
                      id: label,
                      domainFn: (data, _) => data.x,
                      measureFn: (data, _) => data.y,
                      data: src.watch(context),
                      seriesColor:
                          charts.ColorUtil.fromDartColor(colors.primary),
                    ),
                  ],
                  animate: true,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
