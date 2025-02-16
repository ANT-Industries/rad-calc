import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rational/rational.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

import '../../data/numbers/rational.dart';
import '../calculators/base_calc.dart';
import 'double_input.dart';

enum TimeType {
  s('s', 'Seconds'),
  min('min', 'Minutes'),
  hr('hr', 'Hours'),
  d('d', 'Days'),
  y('y', 'Years');

  const TimeType(this.unit, this.displayName);
  final String unit;
  final String displayName;
}

class TimeInput extends DoubleInput {
  const TimeInput({
    super.key,
    required super.value,
    required super.label,
  });

  static TimeInput fromCoreValue(CoreValue<Rational> value) {
    return TimeInput(
      value: value.source,
      label: value.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = useSignal(TimeType.values);
    final selected = useSignal<TimeType>(TimeType.s);

    String desc(Rational val) {
      return val.toDecimal(scaleOnInfinitePrecision: 10).toString();
    }

    final raw = useExistingSignal(value);
    final controller = useTextEditingController(
      text: desc(convertFromSeconds(
        selected.value,
        raw.value ?? Rational.zero,
      )),
    );

    useSignalEffect(() {
      selected.value;
      controller.text = untracked(() => desc(convertFromSeconds(
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
        selected.value = value as TimeType;
      },
    );

    if (super.readonly) {
      return ListTile(
        title: Text(label),
        subtitle: SelectableText(raw.value == null
            ? 'N/A'
            : desc(convertToSeconds(
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
            target.value = convertToSeconds(
              selected.value,
              Rational.tryParse(value!) ?? Rational.zero,
            );
          }
        },
        onChanged: (value) {
          final target = this.value;
          if (target is Signal<Rational?>) {
            target.value = convertToSeconds(
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

Rational convertToSeconds(TimeType type, Rational val) {
  return switch (type) {
    TimeType.s => val,
    TimeType.min => val * 60.toRational(),
    TimeType.hr => val * 60.toRational() * 60.toRational(),
    TimeType.d => val * 60.toRational() * 60.toRational() * 24.toRational(),
    TimeType.y => val *
        60.toRational() *
        60.toRational() *
        24.toRational() *
        365.25.toRational(),
  };
}

Rational convertFromSeconds(TimeType type, Rational val) {
  return switch (type) {
    TimeType.s => val,
    TimeType.min => val / 60.toRational(),
    TimeType.hr => val / 60.toRational() / 60.toRational(),
    TimeType.d => val / 60.toRational() / 60.toRational() / 24.toRational(),
    TimeType.y => val /
        60.toRational() /
        60.toRational() /
        24.toRational() /
        365.25.toRational(),
  };
}
