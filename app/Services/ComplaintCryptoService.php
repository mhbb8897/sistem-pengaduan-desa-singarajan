<?php

namespace App\Services;

use App\Models\UserSecureProfile;

class ComplaintCryptoService
{
    public static function decryptContent($complaint)
    {
        /* ==========================
         * 1. Ambil Secure Profile User
         * ========================== */
        $profile = UserSecureProfile::where('user_id', $complaint->user_id)->first();

        if (!$profile) {
            return '[SECURE PROFILE TIDAK DITEMUKAN]';
        }

        /* ==========================
         * 2. Decrypt AES Key (RSA)
         * ========================== */
        $privateKey = openssl_pkey_get_private($profile->rsa_private_key);

        if (!$privateKey) {
            return '[RSA PRIVATE KEY INVALID]';
        }

        openssl_private_decrypt(
            base64_decode($complaint->encrypted_aes_key),
            $aesKey,
            $privateKey
        );

        if (empty($aesKey)) {
            return '[AES KEY GAGAL DIDEKRIPSI]';
        }

        /* ==========================
         * 3. Validasi HMAC
         * ========================== */
        $calculatedHmac = hash_hmac(
            'sha256',
            $complaint->encrypted_content,
            $profile->hmac_key
        );

        if (!hash_equals($complaint->hmac_signature, $calculatedHmac)) {
            return '[DATA TELAH DIMODIFIKASI]';
        }

        /* ==========================
         * 4. Decrypt Content (AES)
         * ========================== */
        $plaintext = openssl_decrypt(
            base64_decode($complaint->encrypted_content),
            'AES-256-CBC',
            $aesKey,
            OPENSSL_RAW_DATA,
            base64_decode($complaint->iv)
        );

        return $plaintext ?: '[DEKRIPSI GAGAL]';
    }
}
