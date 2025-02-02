import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

import 'double_input.dart';

enum ActivityType {
  dps('dps', 'DPS'),
  dpm('dpm', 'DPM'),
  ci('Ci', 'Curies'),
  pCi('pCi', 'Pico Curies'),
  nCi('nCi', 'Nano Curies'),
  uCi('uCi', 'Micro Curies'),
  mCi('mCi', 'Milli Curies'),
  bq('Bq', 'Becquerels'),
  kBq('kBq', 'Kilo Becquerels'),
  mBq('MBq', 'Mega Becquerels'),
  gBq('GBq', 'Giga Becquerels'),
  tBq('TBq', 'Tera Becquerels');

  const ActivityType(this.unit, this.displayName);
  final String unit;
  final String displayName;
}

class ActivityInput extends DoubleInput {
  const ActivityInput({
    super.key,
    required super.value,
    required super.label,
  });

  @override
  Widget build(BuildContext context) {
    final options = useSignal(ActivityType.values);
    final selected = useSignal<ActivityType>(ActivityType.ci);

    final raw = useExistingSignal(value);
    final controller = useTextEditingController(
      text: convertFromCuries(
        selected.value,
        raw.value ?? 0,
      ).toStringAsPrecision(3),
    );

    useSignalEffect(() {
      selected.value;
      controller.text = untracked(() => convertFromCuries(
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
        selected.value = value as ActivityType;
      },
    );

    if (super.readonly) {
      return ListTile(
        title: Text(label),
        subtitle: SelectableText(raw.value == null
            ? 'N/A'
            : convertToCuries(
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
            target.value = convertToCuries(
              selected.value,
              num.tryParse(value!)?.toDouble() ?? 0,
            );
          }
        },
        onChanged: (value) {
          final target = this.value;
          if (target is Signal<double?>) {
            target.value = convertToCuries(
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

double dpsToBq(double val) => val;

double bqToDps(double val) => val;

double bqToCi(double val) => val * 3.7e10;

double ciToBq(double val) => val / 3.7e10;

double convertToCuries(ActivityType type, double val) {
  return switch (type) {
    ActivityType.dps => bqToDps(bqToCi(val)),
    ActivityType.dpm => val / 2.22e12,
    ActivityType.ci => val,
    ActivityType.pCi => val * 1e12,
    ActivityType.nCi => val * 1e9,
    ActivityType.uCi => val * 1e6,
    ActivityType.mCi => val * 1e3,
    ActivityType.bq => bqToCi(val),
    ActivityType.kBq => bqToCi(val) / 1e3,
    ActivityType.mBq => bqToCi(val) / 1e6,
    ActivityType.gBq => bqToCi(val) / 1e9,
    ActivityType.tBq => bqToCi(val) / 1e12,
  };
}

double convertFromCuries(ActivityType type, double val) {
  return switch (type) {
    ActivityType.dps => ciToBq(dpsToBq(val)),
    ActivityType.dpm => val * 2.22e12,
    ActivityType.ci => val,
    ActivityType.pCi => val / 1e12,
    ActivityType.nCi => val / 1e9,
    ActivityType.uCi => val / 1e6,
    ActivityType.mCi => val / 1e3,
    ActivityType.bq => ciToBq(val),
    ActivityType.kBq => ciToBq(val) * 1e3,
    ActivityType.mBq => ciToBq(val) * 1e6,
    ActivityType.gBq => ciToBq(val) * 1e9,
    ActivityType.tBq => ciToBq(val) * 1e12,
  };
}
