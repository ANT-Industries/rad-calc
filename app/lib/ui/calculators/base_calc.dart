import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

abstract class BaseCalc extends HookWidget {
  const BaseCalc({super.key});

  String get name;

  Signal<String> get variant;

  Computed<Map<String, String>> get variants;

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

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: CupertinoSlidingSegmentedControl(
            groupValue: selected.value,
            children: {
              for (var key in variants().keys) key: Text(variants()[key]!),
            },
            onValueChanged: (value) {
              selected.value = value!;
            },
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
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
        ),
      ),
    );
  }
}
