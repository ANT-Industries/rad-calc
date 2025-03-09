import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

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

  @override
  Widget build(BuildContext context) {
    final options = useSignal(TimeType.values);
    final selected = useSignal<TimeType>(TimeType.s);

    final raw = useExistingSignal(value);
    final controller = useTextEditingController(
      text: convertFromSeconds(
        selected.value,
        raw.value ?? 0,
      ).toStringAsPrecision(3),
    );

    useSignalEffect(() {
      selected.value;
      void update() {
        controller.text = convertFromSeconds(
          selected.value,
          raw.value ?? 0,
        ).toString();
      }

      if (super.readonly) {
        update();
      } else {
        untracked(update);
      }
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

    // if (super.readonly) {
    //   return ListTile(
    //     title: Text(label),
    //     subtitle: SelectableText(raw.value == null
    //         ? 'N/A'
    //         : convertToSeconds(
    //             selected.value,
    //             raw.value!,
    //           ).toStringAsPrecision(3)),
    //     trailing: selector,
    //   );
    // }

    return ListTile(
      title: Text(label),
      subtitle: TextFormField(
        controller: controller,
        readOnly: super.readonly,
        validator: (value) {
          if (value == null || value.isEmpty || num.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
        onSaved: (value) {
          final target = this.value;
          if (target is Signal<double?>) {
            target.value = convertToSeconds(
              selected.value,
              num.tryParse(value!)?.toDouble() ?? 0,
            );
          }
        },
        onChanged: (value) {
          final target = this.value;
          if (target is Signal<double?>) {
            target.value = convertToSeconds(
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

double convertToSeconds(TimeType type, double val) {
  return switch (type) {
    TimeType.s => val,
    TimeType.min => val * 60,
    TimeType.hr => val * 60 * 60,
    TimeType.d => val * 60 * 60 * 24,
    TimeType.y => val * 60 * 60 * 24 * 365.25,
  };
}

double convertFromSeconds(TimeType type, double val) {
  return switch (type) {
    TimeType.s => val,
    TimeType.min => val / 60,
    TimeType.hr => val / 60 / 60,
    TimeType.d => val / 60 / 60 / 24,
    TimeType.y => val / 60 / 60 / 24 / 365.25,
  };
}
