import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:signals/signals_flutter.dart';
import 'package:signals_hooks/signals_hooks.dart';

class DoubleInput extends HookWidget {
  final ReadonlySignal<double?> value;
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
    if (readonly) {
      return ListTile(
        title: Text(label),
        subtitle: Text(result.value?.toStringAsPrecision(3) ?? 'N/A'),
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
    final controller = useTextEditingController(text: result.value?.toString());
    return ListTile(
      title: Text(label),
      subtitle: TextFormField(
        controller: controller,
        readOnly: readonly,
        validator: (value) {
          if (readonly) return null;
          if (value == null || value.isEmpty || num.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
        onSaved: (value) {
          final target = this.value;
          if (target is Signal<double?>) {
            target.value = num.parse(value!).toDouble();
          }
        },
        onChanged: (value) {
          if (readonly) return;
          final target = this.value;
          if (target is Signal<double?>) {
            target.value = num.tryParse(value)?.toDouble();
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
