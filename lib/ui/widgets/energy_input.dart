import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

import '../calculators/base_calc.dart';
import 'double_input.dart';

enum EnergyType {
  kev('kev', 'KeV'),
  mev('mev', 'MeV');

  const EnergyType(this.unit, this.displayName);
  final String unit;
  final String displayName;
}

class EnergyInput extends DoubleInput {
  const EnergyInput({
    super.key,
    required super.value,
    required super.label,
  });

  static EnergyInput fromCoreValue(CoreValue<double> value) {
    return EnergyInput(
      value: value.source,
      label: value.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = useSignal(EnergyType.values);
    final selected = useSignal<EnergyType>(EnergyType.mev);

    final raw = useExistingSignal(value);
    final controller = useTextEditingController(
      text: convertFromMeV(
        selected.value,
        raw.value ?? 0,
      ).toStringAsPrecision(3),
    );

    useSignalEffect(() {
      selected.value;
      controller.text = untracked(() => convertFromMeV(
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
        selected.value = value as EnergyType;
      },
    );

    if (super.readonly) {
      return ListTile(
        title: Text(label),
        subtitle: SelectableText(raw.value == null
            ? 'N/A'
            : convertToMeV(
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
            target.value = convertToMeV(
              selected.value,
              num.tryParse(value!)?.toDouble() ?? 0,
            );
          }
        },
        onChanged: (value) {
          final target = this.value;
          if (target is Signal<double?>) {
            target.value = convertToMeV(
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

double convertToMeV(EnergyType type, double val) {
  return switch (type) {
    EnergyType.mev => val,
    EnergyType.kev => val / 1000,
  };
}

double convertFromMeV(EnergyType type, double val) {
  return switch (type) {
    EnergyType.kev => val * 1000,
    EnergyType.mev => val,
  };
}
