import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum SecureStorage {
  loginToken;

  static const storage = FlutterSecureStorage();

  Future<String?> get() async => await storage.read(key: name);

  Future<void> set(final String value) async =>
      await storage.write(key: name, value: value);

  Future<void> clear() async => await storage.delete(key: name);
}
