import 'package:encrypt/encrypt.dart' as enc;

String encrypt(String data, String keystr) {
  final key = enc.Key.fromUtf8(keystr);
  final iv = enc.IV.fromLength(16);
  final encrypter = enc.Encrypter(enc.AES(key));
  return encrypter.encrypt(data, iv: iv).base64;
}

String decrypt(String data, String keystr) {
  final key = enc.Key.fromUtf8(keystr);
  final iv = enc.IV.fromLength(16);
  final encrypter = enc.Encrypter(enc.AES(key));
  return encrypter.decrypt64(data, iv: iv);
}
