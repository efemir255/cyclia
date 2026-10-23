import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provides the key that encrypts the on-device database.
///
/// A random 256-bit key is generated on first launch and kept in the
/// platform keystore (Android Keystore / iOS Keychain), so the database file
/// alone is useless if copied off the device.
class DatabaseKeyStore {
  DatabaseKeyStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _keyName = 'cyclia_db_key';

  Future<String> obtainKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) return existing;
    final key = _randomHex(32);
    await _storage.write(key: _keyName, value: key);
    return key;
  }

  Future<void> deleteKey() => _storage.delete(key: _keyName);

  static String _randomHex(int bytes) {
    final random = Random.secure();
    return List.generate(
      bytes,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}
