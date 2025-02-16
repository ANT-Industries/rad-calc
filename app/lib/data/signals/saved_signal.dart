import 'dart:convert';

import 'persisted_signal.dart';
import 'shared_preferences_store.dart';

class SavedSignal<T> extends PersistedSignal<T> {
  SavedSignal(
    String key,
    super.internalValue, {
    T Function(String)? getValue,
    String Function(T)? setValue,
  })  : getValue = getValue ?? ((v) => jsonDecode(v) as T),
        setValue = setValue ?? ((v) => jsonEncode(v)),
        super(key: key, store: _store);

  static final _store = SharedPreferencesStore();

  @override
  T decode(String value) => getValue(value);

  @override
  String encode(T value) => setValue(value);

  final T Function(String) getValue;
  final String Function(T) setValue;
}

class EnumSignal<T extends Enum> extends PersistedSignal<T> {
  EnumSignal(String key, super.val, this.values)
      : super(
          key: key,
          store: _store,
        );

  final List<T> values;

  static final _store = SharedPreferencesStore();

  @override
  T decode(String value) => values.firstWhere((e) => e.name == value);

  @override
  String encode(T value) => value.name;
}
