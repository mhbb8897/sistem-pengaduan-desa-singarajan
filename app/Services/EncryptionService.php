<?php

namespace App\Services;

use phpseclib3\Crypt\AES;
use phpseclib3\Crypt\Random;
use phpseclib3\Crypt\RSA;

class EncryptionService
{
    public static function encryptComplaintData(array $data)
    {
        // 1. Load Public Key (Gunakan public key, bukan private!)
        $path = storage_path('app/public.pem');
        if (! file_exists($path)) {
            throw new \Exception('Public key tidak ditemukan.');
        }
        $publicKey = RSA::load(file_get_contents($path));

        // 2. Generate Kunci AES & IV secara acak (32 bytes untuk AES-256)
        $aesKey = Random::string(32);
        $iv = Random::string(16);

        // 3. Enkripsi Konten (JSON) menggunakan AES-CBC
        $aes = new AES('cbc');
        $aes->setKey($aesKey);
        $aes->setIV($iv);

        $jsonContent = json_encode($data);
        $encryptedContent = $aes->encrypt($jsonContent);

        // 4. Enkripsi Kunci AES menggunakan RSA (Public Key)
        // Ini agar hanya pemegang Private Key yang bisa membukanya
        $encryptedAesKey = $publicKey->encrypt($aesKey);

        return [
            'encrypted_content' => base64_encode($encryptedContent),
            'encrypted_aes_key' => base64_encode($encryptedAesKey),
            'iv' => base64_encode($iv),
        ];
    }
}
