import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rational/rational.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

import '../../data/numbers/rational.dart';
import '../calculators/base_calc.dart';
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

  static ActivityInput fromCoreValue(CoreValue<Rational> value) {
    return ActivityInput(
      value: value.source,
      label: value.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = useSignal(ActivityType.values);
    final selected = useSignal<ActivityType>(ActivityType.ci);

    String desc(Rational val) {
      return val.toDecimal(scaleOnInfinitePrecision: 10).toString();
    }

    final raw = useExistingSignal(value);
    final controller = useTextEditingController(
      text: desc(convertFromCuries(
        selected.value,
        raw.value ?? Rational.zero,
      )),
    );

    useSignalEffect(() {
      selected.value;
      controller.text = untracked(() => desc(convertFromCuries(
            selected.value,
            raw.value ?? Rational.zero,
          )));
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
            : desc(convertToCuries(
                selected.value,
                raw.value!,
              ))),
        trailing: selector,
      );
    }

    return ListTile(
      title: Text(label),
      subtitle: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null ||
              value.isEmpty ||
              Rational.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
        onSaved: (value) {
          final target = this.value;
          if (target is Signal<Rational?>) {
            target.value = convertToCuries(
              selected.value,
              Rational.tryParse(value!) ?? Rational.zero,
            );
          }
        },
        onChanged: (value) {
          final target = this.value;
          if (target is Signal<Rational?>) {
            target.value = convertToCuries(
              selected.value,
              Rational.tryParse(value) ?? Rational.zero,
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

Rational dpsToBq(Rational val) => val;

Rational bqToDps(Rational val) => val;

Rational bqToCi(Rational val) => val * 3.7e10.toRational();

Rational ciToBq(Rational val) => val / 3.7e10.toRational();

Rational convertToCuries(ActivityType type, Rational val) {
  return switch (type) {
    ActivityType.dps => bqToDps(bqToCi(val)),
    ActivityType.dpm => val / 2.22e12.toRational(),
    ActivityType.ci => val,
    ActivityType.pCi => val * 1e12.toRational(),
    ActivityType.nCi => val * 1e9.toRational(),
    ActivityType.uCi => val * 1e6.toRational(),
    ActivityType.mCi => val * 1e3.toRational(),
    ActivityType.bq => bqToCi(val),
    ActivityType.kBq => bqToCi(val) / 1e3.toRational(),
    ActivityType.mBq => bqToCi(val) / 1e6.toRational(),
    ActivityType.gBq => bqToCi(val) / 1e9.toRational(),
    ActivityType.tBq => bqToCi(val) / 1e12.toRational(),
  };
}

Rational convertFromCuries(ActivityType type, Rational val) {
  return switch (type) {
    ActivityType.dps => ciToBq(dpsToBq(val)),
    ActivityType.dpm => val * 2.22e12.toRational(),
    ActivityType.ci => val,
    ActivityType.pCi => val / 1e12.toRational(),
    ActivityType.nCi => val / 1e9.toRational(),
    ActivityType.uCi => val / 1e6.toRational(),
    ActivityType.mCi => val / 1e3.toRational(),
    ActivityType.bq => ciToBq(val),
    ActivityType.kBq => ciToBq(val) * 1e3.toRational(),
    ActivityType.mBq => ciToBq(val) * 1e6.toRational(),
    ActivityType.gBq => ciToBq(val) * 1e9.toRational(),
    ActivityType.tBq => ciToBq(val) * 1e12.toRational(),
  };
}
