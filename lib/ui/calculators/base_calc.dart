import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;

class BaseCalcBuilder {
  static late BaseCalcBuilder current;
  String name;
  String seed = '';

  BaseCalcBuilder(this.name) {
    current = this;
  }

  List<BaseCalculation> _calculations = [];
  BaseCalculation? _defaultCalculation;

  BaseCalcWidget build() {
    final base = BaseCalcWidget(this);
    // for (final calc in calculations) {
    //   for (final core in calc.inputs) {
    //     core.source.key = '${core.source.key}|$seed';
    //   }
    // }
    return base;
  }

  BaseCalculation addCalculation(String name, IconData icon) {
    final calc = BaseCalculation(name, icon);
    _calculations.add(calc);
    _defaultCalculation ??= calc;
    return calc;
  }

  void setDefaultCalculation(String name) {
    _defaultCalculation = _calculations.firstWhere((calc) => calc.name == name);
  }

  BaseCalculation get defaultCalc => _defaultCalculation ?? _calculations.first;

  List<BaseCalculation> get calculations => _calculations;
}

typedef CoreValueBuilder<T extends ReadonlySignal> = Widget Function(T);

abstract class CoreValue<V> {
  ReadonlySignal<V> get source;

  String get label;

  CoreValueBuilder<ReadonlySignal<V>> get builder;

  V call() => source.value;

  Widget build() {
    return Watch(
      key: ValueKey(source),
      (context) => builder(source),
    );
  }
}

T safeCalc<T extends num>(T Function() cb, T fallback) {
  try {
    final result = cb();
    if (result.isNaN) return fallback;
    return result.isFinite ? result : fallback;
  } catch (e) {
    return fallback;
  }
}

class Input<T> extends CoreValue<T> {
  @override
  Signal<T> source;

  @override
  String label;

  @override
  CoreValueBuilder<ReadonlySignal<T>> builder;

  Input(this.label, T initialValue, this.builder)
      : source = signal<T>(
          // '${BaseCalcBuilder.current.name}|$label',
          initialValue,
        );
}

class Output<T> extends CoreValue<T> {
  @override
  ReadonlySignal<T> source;

  @override
  String label;

  @override
  CoreValueBuilder<ReadonlySignal<T>> builder;

  Output(this.label, T Function() cb, this.builder) : source = computed<T>(cb);

  Input<T>? input;
}

class Chart {
  String label;
  ReadonlySignal<List<({double x, double y})>> source;
  Chart(this.label, this.source);

  Widget build() {
    return Watch((context) {
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
                  domainFn: (data, _) => data.y,
                  measureFn: (data, _) => data.x,
                  data: source.watch(context),
                  seriesColor: charts.ColorUtil.fromDartColor(colors.primary),
                ),
              ],
              animate: true,
            ),
          ),
        ),
      );
    });
  }
}

class BaseCalculation<R> {
  String name;
  IconData icon;
  BaseCalculation(this.name, this.icon);
  List<Input> inputs = [];
  List<Output> outputs = [];
  List<Chart> charts = [];
}

class BaseCalcWidget extends BaseCalc {
  final BaseCalcBuilder base;
  BaseCalcWidget(this.base, {super.key});

  @override
  String get name => base.name;

  @override
  late Signal<String> variant = signal(base.defaultCalc.name);

  @override
  late Computed<Map<String, String>> variants = computed(() {
    return {
      for (var calc in base.calculations) calc.name: calc.name,
    };
  });

  @override
  late Computed<Map<String, IconData>> icons = computed(() {
    return {
      for (var calc in base.calculations) calc.name: calc.icon,
    };
  });

  @override
  late Computed<Map<String, List<Widget>>> inputs = computed(() {
    return {
      for (var calc in base.calculations)
        calc.name: [
          for (var input in calc.inputs) input.build(),
        ],
    };
  });

  @override
  late Computed<Map<String, List<Widget>>> outputs = computed(() {
    return {
      for (var calc in base.calculations)
        calc.name: [
          for (var output in calc.outputs) output.build(),
          for (var chart in calc.charts) chart.build(),
        ],
    };
  });

  @override
  Widget build(BuildContext context) {
    useSignalEffect(() {
      final current = variant.value;
      batch(() {
        for (final calc in base.calculations) {
          if (current == calc.name) {
            for (final output in calc.outputs.where((e) => e.input != null)) {
              output.input!.source.value = output.source.value;
            }
          }
        }
      });
    });
    return super.build(context);
  }
}

abstract class BaseCalc extends HookWidget {
  const BaseCalc({super.key});

  String get name;

  Signal<String> get variant;

  Computed<Map<String, String>> get variants;

  Computed<Map<String, IconData>> get icons;

  Computed<Map<String, List<Widget>>> get inputs;

  Computed<Map<String, List<Widget>>> get outputs;

  @override
  Widget build(BuildContext context) {
    final selected = useExistingSignal(variant);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final variants = useExistingSignal(this.variants);
    final inputs = useExistingSignal(this.inputs);
    final outputs = useExistingSignal(this.outputs);

    useSignalEffect(() {
      selected.value;
      formKey.currentState?.reset();
    });
    Widget child = Form(
      key: formKey,
      child: LayoutBuilder(
        builder: (context, dimens) {
          if (dimens.maxWidth > 800) {
            return Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var input in inputs()[selected()]!)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: input,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var output in outputs()[selected()]!)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: output,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                for (var input in inputs()[selected()]!)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: input,
                  ),
                const Divider(),
                for (var output in outputs()[selected()]!)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: output,
                  ),
              ],
            ),
          );
        },
      ),
    );
    if (variants().length >= 2) {
      return LayoutBuilder(
        builder: (context, dimens) {
          if (dimens.maxWidth > 600) {
            return Scaffold(
              appBar: AppBar(
                title: Text(name),
              ),
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex:
                        variants().keys.toList().indexOf(selected.value),
                    onDestinationSelected: (index) {
                      selected.value = variants().keys.toList()[index];
                    },
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (var key in variants().keys)
                        NavigationRailDestination(
                          label: Text(variants()[key]!),
                          icon: Icon(icons()[key]!),
                        ),
                    ],
                  ),
                  Expanded(child: child),
                ],
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(name),
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: variants().keys.toList().indexOf(selected.value),
              onDestinationSelected: (index) {
                selected.value = variants().keys.toList()[index];
              },
              destinations: [
                for (var key in variants().keys)
                  NavigationDestination(
                    label: variants()[key]!,
                    icon: Icon(icons()[key]!),
                  ),
              ],
            ),
            body: child,
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CupertinoSlidingSegmentedControl(
                groupValue: selected.value,
                children: {
                  for (var key in variants().keys) key: Text(variants()[key]!),
                },
                onValueChanged: (value) {
                  selected.value = value!;
                },
              ),
              const Divider(),
              for (var input in inputs()[selected()]!)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: input,
                ),
              const Divider(),
              for (var output in outputs()[selected()]!)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: output,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
