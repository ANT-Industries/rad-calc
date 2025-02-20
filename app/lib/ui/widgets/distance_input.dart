import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

import '../calculators/base_calc.dart';
import 'double_input.dart';

enum DistanceType {
  inch('inch', 'Inch'),
  foot('foot', 'Foot'),
  yard('yard', 'Yard'),
  cm('cm', 'Centimeter'),
  m('m', 'Meter');

  const DistanceType(this.unit, this.displayName);
  final String unit;
  final String displayName;
}

class DistanceInput extends DoubleInput {
  const DistanceInput({
    super.key,
    required super.value,
    required super.label,
  });

  static DistanceInput fromCoreValue(CoreValue<double> value) {
    return DistanceInput(
      value: value.source,
      label: value.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = useSignal(DistanceType.values);
    final selected = useSignal<DistanceType>(DistanceType.cm);

    final raw = useExistingSignal(value);
    final controller = useTextEditingController(
      text: convertFromCentimeters(
        selected.value,
        raw.value ?? 0,
      ).toStringAsPrecision(3),
    );

    useSignalEffect(() {
      selected.value;
      controller.text = untracked(() => convertFromCentimeters(
            selected.value,
            raw.value ?? 0,
          ).toString());
    });

    final Widget selector = DropdownButton(
      items: options.value
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e.displayName),
            ),
          )
          .toList(),
      value: selected.value,
      onChanged: (value) {
        selected.value = value as DistanceType;
      },
    );

    if (super.readonly) {
      return ListTile(
        title: Text(label),
        subtitle: SelectableText(raw.value == null
            ? 'N/A'
            : convertToCentimeters(
                selected.value,
                raw.value!,
              ).toStringAsPrecision(3)),
        trailing: selector,
      );
    }

    return ListTile(
      title: Text(label),
      subtitle: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty || num.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
        onSaved: (value) {
          final target = this.value;
          if (target is Signal<double?>) {
            target.value = convertToCentimeters(
              selected.value,
              num.tryParse(value!)?.toDouble() ?? 0,
            );
          }
        },
        onChanged: (value) {
          final target = this.value;
          if (target is Signal<double?>) {
            target.value = convertToCentimeters(
              selected.value,
              num.tryParse(value)?.toDouble() ?? 0,
            );
          }
        },
        onEditingComplete: () {
          Form.of(context).save();
        },
        decoration: InputDecoration(
          suffix: selector,
        ),
      ),
    );
  }
}

double convertToCentimeters(DistanceType type, double val) {
  return switch (type) {
    DistanceType.cm => val,
    DistanceType.m => val * 100,
    DistanceType.inch => val * 2.54,
    DistanceType.foot => val * 2.54 * 12,
    DistanceType.yard => val * 2.54 * 12 *3,
  };
}

double convertFromCentimeters(DistanceType type, double val) {
  return switch (type) {
    DistanceType.cm => val,
    DistanceType.m => val / 100,
    DistanceType.inch => val / 2.54,
    DistanceType.foot => val / 2.54 / 12,
    DistanceType.yard => val / 2.54 / 12 / 3,
  };
}
