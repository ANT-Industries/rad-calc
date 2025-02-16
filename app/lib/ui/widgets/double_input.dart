import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rational/rational.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

class DoubleInput extends HookWidget {
  final ReadonlySignal<Rational?> value;
  final String label;

  const DoubleInput({
    super.key,
    required this.value,
    required this.label,
  });

  bool get readonly => value is! Signal;

  @override
  Widget build(BuildContext context) {
    final result = useExistingSignal(value);

    String desc(Rational val) {
      return val.toDecimal(scaleOnInfinitePrecision: 10).toString();
    }

    final controller = useTextEditingController(
      text: result.value == null ? null : desc(result.value!),
    );

    if (readonly) {
      return ListTile(
        title: Text(label),
        subtitle: SelectableText(
          result.value == null ? 'N/A' : desc(result.value!),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final text = result.value?.toString();
            if (text == null) return;
            final data = ClipboardData(text: text);
            await Clipboard.setData(data);
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Copied to clipboard'),
              ),
            );
          },
        ),
      );
    }

    return ListTile(
      title: Text(label),
      subtitle: TextFormField(
        controller: controller,
        readOnly: readonly,
        validator: (value) {
          if (readonly) return null;
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
            target.value = Rational.tryParse(value!);
          }
        },
        onChanged: (value) {
          if (readonly) return;
          final target = this.value;
          if (target is Signal<Rational?>) {
            target.value = Rational.tryParse(value);
          }
        },
        onEditingComplete: () {
          if (readonly) return;
          Form.of(context).save();
        },
      ),
    );
  }
}
