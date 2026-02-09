<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;
use phpseclib3\Crypt\AES;
use phpseclib3\Crypt\RSA;

class Complaint extends Model
{
    protected $guarded = [];

    protected $fillable = [
        'user_id',
        'title',
        'category',
        'status',
        'encrypted_content',
        'encrypted_aes_key',
        'iv',
    ];

    /**
     * Accessor untuk mendekripsi data secara otomatis.
     * Dipanggil di Filament dengan: decrypted_content.nama_field
     */
    public function getDecryptedContentAttribute()
    {
        // Jika data masih kosong (misal saat baru create), return array kosong
        if (! $this->encrypted_content || ! $this->encrypted_aes_key) {
            return [];
        }

        try {
            // 1. Load Private Key dari Storage
            $path = storage_path('app/private.pem');

            if (! file_exists($path)) {
                return ['error' => 'Private key tidak ditemukan di server.'];
            }

            $privateKeyString = file_get_contents($path);
            $privateKey = RSA::load($privateKeyString);

            // 2. Dekripsi Kunci AES menggunakan RSA
            // Kunci AES ini yang sebelumnya dienkripsi oleh Public Key di Flutter
            $decryptedAesKey = $privateKey->decrypt(base64_decode($this->encrypted_aes_key));

            // 3. Dekripsi Konten menggunakan AES-CBC
            $aes = new AES('cbc');
            $aes->setKey($decryptedAesKey);
            $aes->setIV(base64_decode($this->iv));

            $decryptedJson = $aes->decrypt(base64_decode($this->encrypted_content));

            // Return dalam bentuk array agar bisa dibaca Filament (dot notation)
            return json_decode($decryptedJson, true) ?? [];

        } catch (\Exception $e) {
            // Jika gagal dekripsi (misal kunci salah), berikan pesan error di dashboard
            return [
                'lokasi' => 'Gagal dekripsi',
                'deskripsi' => 'Kesalahan sistem: '.$e->getMessage(),
            ];
        }
    }

    // Relation
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function messages()
    {
        return $this->hasMany(ComplaintMessage::class);
    }
}
