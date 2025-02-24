import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

import '../calculators/base_calc.dart';
import 'double_input.dart';
import '../lookup_data/hvl_data.dart';


class HvlInput extends DoubleInput {
  const HvlInput({
    super.key,
    required super.value,
    required super.label,
  });

  static HvlInput fromCoreValue(CoreValue<double> value) {
    return HvlInput(
      value: value.source,
      label: value.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = useSignal(DoseType.values);
    final selected = useSignal<DoseType>(DoseType.rem);

    final raw = useExistingSignal(value);
    final controller = useTextEditingController(
      text: convertFromRem(
        selected.value,
        raw.value ?? 0,
      ).toStringAsPrecision(3),
    );

    useSignalEffect(() {
      selected.value;
      controller.text = untracked(() => convertFromRem(
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
        selected.value = value as DoseType;
      },
    );

    if (super.readonly) {
      return ListTile(
        title: Text(label),
        subtitle: SelectableText(raw.value == null
            ? 'N/A'
            : convertToRem(
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
            target.value = convertToRem(
              selected.value,
              num.tryParse(value!)?.toDouble() ?? 0,
            );
          }
        },
        onChanged: (value) {
          final target = this.value;
          if (target is Signal<double?>) {
            target.value = convertToRem(
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

double convertToRem(DoseType type, double val) {
  return switch (type) {
    DoseType.rem => val,
    DoseType.mrem => val / 1000,
    DoseType.urem => val / 1000 / 1000,
  };
}

double convertFromRem(DoseType type, double val) {
  return switch (type) {
    DoseType.rem => val,
    DoseType.mrem => val * 1000,
    DoseType.urem => val * 1000 * 1000,
  };
}
