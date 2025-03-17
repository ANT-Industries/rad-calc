import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

import '../calculators/base_calc.dart';
import 'double_input.dart';

enum ExposureType {
  r('R', 'R'),
  mR('mR', 'mR'),
  uR('uR', 'uR');

  const ExposureType(this.unit, this.displayName);
  final String unit;
  final String displayName;
}

class ExposureInput extends DoubleInput {
  const ExposureInput({
    super.key,
    required super.value,
    required super.label,
  });

  static ExposureInput fromCoreValue(CoreValue<double> value) {
    return ExposureInput(
      value: value.source,
      label: value.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = useSignal(ExposureType.values);
    final selected = useSignal<ExposureType>(ExposureType.r);

    final raw = useExistingSignal(value);
    final controller = useTextEditingController(
      text: convertFromReontgen(
        selected.value,
        raw.value ?? 0,
      ).toStringAsPrecision(3),
    );

    useSignalEffect(() {
      selected.value;
      controller.text = untracked(() => convertFromReontgen(
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
        selected.value = value as ExposureType;
      },
    );

    if (super.readonly) {
      return ListTile(
        title: Text(label),
        subtitle: SelectableText(raw.value == null
            ? 'N/A'
            : convertToReontgen(
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
            target.value = convertToReontgen(
              selected.value,
              num.tryParse(value!)?.toDouble() ?? 0,
            );
          }
        },
        onChanged: (value) {
          final target = this.value;
          if (target is Signal<double?>) {
            target.value = convertToReontgen(
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

double convertToReontgen(ExposureType type, double val) {
  return switch (type) {
    ExposureType.r => val,
    ExposureType.mR => val / 1000,
    ExposureType.uR => val / 1000 / 1000,
  };
}

double convertFromReontgen(ExposureType type, double val) {
  return switch (type) {
    ExposureType.r => val,
    ExposureType.mR => val * 1000,
    ExposureType.uR => val * 1000 * 1000,
  };
}
