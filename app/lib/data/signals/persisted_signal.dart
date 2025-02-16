import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:signals/signals_flutter.dart';

import 'key_value_store.dart';

class PersistedSignal<T> extends FlutterSignal<T> with PersistedSignalMixin<T> {
  PersistedSignal(
    super.internalValue, {
    super.autoDispose,
    super.debugLabel,
    required this.key,
    required this.store,
  });

  @override
  String key;

  @override
  final KeyValueStore store;
}

mixin PersistedSignalMixin<T> on Signal<T> {
  String get key;
  KeyValueStore get store;

  bool loaded = false;

  Future<void> init() async {
    try {
      final val = await load();
      super.value = val;
    } catch (e) {
      debugPrint('Error loading persisted signal: $e');
    } finally {
      loaded = true;
    }
  }

  @override
  T get value {
    if (!loaded) init().ignore();
    return super.value;
  }

  @override
  set value(T value) {
    super.value = value;
    save(value).ignore();
  }

  Future<T> load() async {
    final val = await store.getItem(key);
    if (val == null) return value;
    return decode(val);
  }

  Future<void> save(T value) async {
    final str = encode(value);
    await store.setItem(key, str);
  }

  T decode(String value) => jsonDecode(value);

  String encode(T value) => jsonEncode(value);
}
