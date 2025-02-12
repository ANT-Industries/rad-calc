abstract class KeyValueStore {
  Future<void> setItem(String key, String value);
  Future<String?> getItem(String key);
  Future<void> removeItem(String key);
}
