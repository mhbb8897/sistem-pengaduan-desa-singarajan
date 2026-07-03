import 'package:simpedesa/core/constants.dart';
import 'package:simpedesa/data/services/secure_storage_service.dart';

class TokenService {
  Future<void> save({
    required String token,
    required String hmacKey,
    required int expiresIn,
  }) async {
    final expiresAt = DateTime.now()
        .add(Duration(seconds: expiresIn))
        .toIso8601String();

    await SecureStorageService.write(AppConstants.keyAuthToken, token);

    await SecureStorageService.write(AppConstants.keyHmacSession, hmacKey);

    await SecureStorageService.write(AppConstants.keyTokenExpiresAt, expiresAt);
  }

  Future<String?> token() =>
      SecureStorageService.read(AppConstants.keyAuthToken);

  Future<String?> hmacKey() =>
      SecureStorageService.read(AppConstants.keyHmacSession);

  Future<void> clear() async {
    await SecureStorageService.delete(AppConstants.keyAuthToken);

    await SecureStorageService.delete(AppConstants.keyHmacSession);

    await SecureStorageService.delete(AppConstants.keyTokenExpiresAt);
  }
}
