import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart' as cipher;

import 'cyclia_repository.dart';
import 'database_key.dart';

/// Thrown when the database exists but can't be decrypted, e.g. because the
/// keystore entry was lost after a device restore.
class DatabaseUnreadableException implements Exception {
  DatabaseUnreadableException(this.cause);

  final Object cause;

  @override
  String toString() => 'DatabaseUnreadableException: $cause';
}

const _fileName = 'cyclia.db';

/// Opens the SQLCipher-encrypted database used on devices.
Future<SqlCycliaRepository> openEncryptedRepository(
  DatabaseKeyStore keys,
) async {
  final path = p.join(await cipher.getDatabasesPath(), _fileName);
  final key = await keys.obtainKey();
  try {
    final db = await cipher.openDatabase(
      path,
      password: key,
      version: SqlCycliaRepository.schemaVersion,
      onCreate: SqlCycliaRepository.createSchema,
    );
    return SqlCycliaRepository(db);
  } catch (e) {
    throw DatabaseUnreadableException(e);
  }
}

/// Deletes the database file and its key. Used to recover from an
/// unreadable database; all data is lost.
Future<void> wipeEncryptedDatabase(DatabaseKeyStore keys) async {
  final path = p.join(await cipher.getDatabasesPath(), _fileName);
  await cipher.deleteDatabase(path);
  await keys.deleteKey();
}
