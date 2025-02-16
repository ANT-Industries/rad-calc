import 'persisted_signal.dart';
import 'shared_preferences_store.dart';

class SavedSignal<T> extends PersistedSignal<T> {
  SavedSignal(String key, super.internalValue) : super(key: key, store: _store);

  static final _store = SharedPreferencesStore();
}
