import 'package:flutter_secure_storage/flutter_secure_storage.dart';


Future<String?> getToken(FlutterSecureStorage storage, String key) async {
  return await storage.read(key: key); // Mengembalikan nullable String
}

Future<void> saveToken(
  FlutterSecureStorage storage,
  String key,
  String value,
) async {
  await storage.write(
    key: key,
    value: value,
  );
}

void deleteToken(FlutterSecureStorage storage) async {
  await storage.delete(key: "access-token");
  await storage.delete(key: "refresh-token");
  await storage.delete(key: "exp");
  await storage.delete(key: "exp-refresh-token");
}
