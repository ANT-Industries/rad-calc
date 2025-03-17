import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

import '../calculators/base_calc.dart';
import 'double_input.dart';

enum ExposureRateType {
  rH('R/hr', 'R/hr'),
  mRH('mR/hr', 'mR/hr'),
  uRH('uR/hr', 'uR/hr');

  const ExposureRateType(this.unit, this.displayName);
  final String unit;
  final String displayName;
}

class ExposureRateInput extends DoubleInput {
  const ExposureRateInput({
    super.key,
    required super.value,
    required super.label,
  });

  static ExposureRateInput fromCoreValue(CoreValue<double> value) {
    return ExposureRateInput(
      value: value.source,
      label: value.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = useSignal(ExposureRateType.values);
    final selected = useSignal<ExposureRateType>(ExposureRateType.rH);

    final raw = useExistingSignal(value);
    final controller = useTextEditingController(
      text: convertFromReontgenPerHour(
        selected.value,
        raw.value ?? 0,
      ).toStringAsPrecision(3),
    );

    useSignalEffect(() {
      selected.value;
      controller.text = untracked(() => convertFromReontgenPerHour(
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
        selected.value = value as ExposureRateType;
      },
    );

    if (super.readonly) {
      return ListTile(
        title: Text(label),
        subtitle: SelectableText(raw.value == null
            ? 'N/A'
            : convertToReontgenPerHour(
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
            target.value = convertToReontgenPerHour(
              selected.value,
              num.tryParse(value!)?.toDouble() ?? 0,
            );
          }
        },
        onChanged: (value) {
          final target = this.value;
          if (target is Signal<double?>) {
            target.value = convertToReontgenPerHour(
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

double convertToReontgenPerHour(ExposureRateType type, double val) {
  return switch (type) {
    ExposureRateType.rH => val,
    ExposureRateType.mRH => val / 1000,
    ExposureRateType.uRH => val / 1000 / 1000,
  };
}

double convertFromReontgenPerHour(ExposureRateType type, double val) {
  return switch (type) {
    ExposureRateType.rH => val,
    ExposureRateType.mRH => val * 1000,
    ExposureRateType.uRH => val * 1000 * 1000,
  };
}
