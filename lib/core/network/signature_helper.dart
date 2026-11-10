import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class SignatureHelper {
  // Shared transaction secret key for anti-tampering verification
  static const String secretKey = 'super-secret-transaction-key-2026';
  static const _uuid = Uuid();

  /// Generates the required anti-tampering headers:
  /// X-Signature: HMAC-SHA256(METHOD:PATH:TIMESTAMP:SHA256(BODY))
  /// X-Timestamp: ISO 8601 UTC timestamp
  /// Idempotency-Key: UUID v4
  static Map<String, String> generateTransactionHeaders({
    required String method,
    required String path,
    required Map<String, dynamic> body,
    String? idempotencyKey,
  }) {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final bodyString = jsonEncode(body);
    final bodyHash = sha256.convert(utf8.encode(bodyString)).toString();

    // Normalized path (e.g. /api/v1/transactions/topup)
    final normalizedPath = path.startsWith('/api') ? path : '/api/v1$path';
    final stringToSign = '${method.toUpperCase()}:$normalizedPath:$timestamp:$bodyHash';

    final hmacSha256 = Hmac(sha256, utf8.encode(secretKey));
    final signature = hmacSha256.convert(utf8.encode(stringToSign)).toString();

    return {
      'X-Signature': signature,
      'X-Timestamp': timestamp,
      'Idempotency-Key': idempotencyKey ?? _uuid.v4(),
    };
  }
}
