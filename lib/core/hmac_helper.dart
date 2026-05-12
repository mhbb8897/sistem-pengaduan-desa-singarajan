import 'dart:convert';
import 'package:crypto/crypto.dart';

String generateHmacSignature({
  required String timestamp,
  required String body,
  required String secretKey,
}) {
  final payload = '$timestamp$body';

  final key = utf8.encode(secretKey);
  final bytes = utf8.encode(payload);

  final hmacSha256 = Hmac(sha256, key);

  return hmacSha256.convert(bytes).toString();
}
